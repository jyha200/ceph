// -*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab
/*
 * Ceph - scalable distributed file system
 *
 * Copyright (C) 2014 Red Hat
 * Copyright (C) 2020 Abutalib Aghayev
 *
 * This is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License version 2.1, as published by the Free Software
 * Foundation.  See file COPYING.
 *
 */

#include "HMSMRDevice.h"
extern "C" {
#include <libzbd/zbd.h>
}
#include "common/debug.h"
#include "common/errno.h"
#include "common/blkdev.h"
#include "os/bluestore/BlueStore.h"

#define dout_context cct
#define dout_subsys ceph_subsys_bdev
#undef dout_prefix
#define dout_prefix *_dout << "smrbdev(" << this << " " << path << ") "

using namespace std;

struct hmsmr_cbpriv {
  BlockDevice::aio_callback_t cb;
  void* cbpriv;
  HMSMRDevice* bdev;
  hmsmr_cbpriv(BlockDevice::aio_callback_t cb, void* cbpriv, HMSMRDevice* bdev)
  : cb(cb),
    cbpriv(cbpriv),
    bdev(bdev) { }
};

static void hmsmr_cb(void* priv, void*priv2)
{
  hmsmr_cbpriv* casted_priv = static_cast<hmsmr_cbpriv*>(priv);
  BlueStore::TransContext* trans_context = static_cast<BlueStore::TransContext*>(priv2);
  IOContext* ioc = &trans_context->ioc;
  HMSMRDevice* bdev = casted_priv->bdev;
  bdev->post_write(ioc);

  if (ioc->num_pending > 0) {
  }
  else {
    bdev->post_write2(ioc);
    casted_priv->cb(casted_priv->cbpriv, priv2);
  }
  bdev->do_aio_submit();
}

void HMSMRDevice::post_write2(IOContext* ioc) {
  dout(20) << __func__ << " ioc done " << ioc
    << " pending " << ioc->num_pending.load()
    << " running " << ioc->num_running.load() <<dendl;
}

void HMSMRDevice::post_write(IOContext* ioc) {
  dout(20) << __func__ << " ioc " << ioc
    << " pending " << ioc->num_pending.load()
    << " running " << ioc->num_running.load() <<dendl;
}
HMSMRDevice::HMSMRDevice(CephContext* cct,
    aio_callback_t cb,
    void *cbpriv,
    aio_callback_t d_cb,
    void *d_cbpriv)
  : KernelDevice(cct, hmsmr_cb, new hmsmr_cbpriv(cb, cbpriv, this), d_cb, d_cbpriv)
{
}

bool HMSMRDevice::support(const std::string& path)
{
  return zbd_device_is_zoned(path.c_str()) == 1;
}

int HMSMRDevice::_post_open()
{
  dout(10) << __func__ << dendl;
  zbd_info info;
  zbd_fd = zbd_open(path.c_str(), O_RDWR | O_DIRECT | O_LARGEFILE, &info);
  zbd_fd2 = ::open(path.c_str(), O_RDWR | O_DIRECT | O_LARGEFILE);
  int r;
  if (zbd_fd < 0) {
    r = errno;
    derr << __func__ << " zbd_open failed on " << path << ": "
      << cpp_strerror(r) << dendl;
    return -r;
  }

  nr_zones = info.nr_zones;
  zone_size = info.zone_size;

  if (cct->_conf->contains("bluestore_cns_path")) {
    string cns_path = cct->_conf->bluestore_cns_path;
    cns_fd = ::open(cns_path.c_str(), O_RDWR | O_DIRECT | O_LARGEFILE);
    if (cns_fd < 0) {
      r = errno;
      derr << __func__ << " cns open failed on " << path << ": "
        << cpp_strerror(r) << dendl;
      goto fail;
    }
    BlkDev bdev(cns_fd);
    int64_t conv_size; 
    r = bdev.get_size(&conv_size);
    conventional_region_size = static_cast<uint64_t>(conv_size);
    if (r < 0) {
      goto fail;
    }
  }
  else {
    conventional_region_size = nr_zones * zone_size;
  }

  dout(10) << __func__ << " setting zone size to " << zone_size
    << " and conventional region size to " << conventional_region_size
    << " size: " << get_size() << dendl;

  return 0;

fail:
  zbd_close(zbd_fd);
  zbd_fd = -1;
  if (cns_fd >= 0) {
    ::close(cns_fd);
    cns_fd = -1;
  }
  return r;
}

int HMSMRDevice::aio_write(
    uint64_t off,
    ceph::buffer::list& bl,
    IOContext *ioc,
    bool buffered,
    int write_hint) {
  int ret = KernelDevice::aio_write(off, bl, ioc, buffered, write_hint);
  return ret;
}

void HMSMRDevice::_pre_close()
{
  if (zbd_fd >= 0) {
    zbd_close(zbd_fd);
    zbd_fd = -1;
  }
  if (cns_fd >= 0) {
    ::close(cns_fd);
    cns_fd = -1;
  }
}

void HMSMRDevice::reset_all_zones()
{
  dout(10) << __func__ << dendl;
  zbd_reset_zones(zbd_fd, conventional_region_size, 0);
}

void HMSMRDevice::reset_zone(uint64_t zone)
{
  dout(10) << __func__ << " zone 0x" << std::hex << zone << std::dec << dendl;
  blk_zone_range range = {.sector = zone * zone_size / 512, .nr_sectors = zone_size / 512};
  if (ioctl(zbd_fd2, BLKRESETZONE, &range) < 0) {
    derr << __func__ << " resetting zone failed for zone 0x" << std::hex
      << zone << std::dec << dendl;
    ceph_abort("zbd_reset_zones failed");

  }
}

std::vector<uint64_t> HMSMRDevice::get_zones()
{
  std::vector<zbd_zone> zones;
  unsigned int num_zones = size / zone_size;
  zones.resize(num_zones);

  int r = zbd_report_zones(zbd_fd, 0, 0, ZBD_RO_ALL, zones.data(), &num_zones);
  if (r != 0) {
    derr << __func__ << " zbd_report_zones failed on " << path << ": "
      << cpp_strerror(errno) << dendl;
    ceph_abort("zbd_report_zones failed");
  }

  std::vector<uint64_t> wp(num_zones);
  for (unsigned i = 0; i < num_zones; ++i) {
    wp[i] = zones[i].wp;
  }
  return wp;
}

void HMSMRDevice::aio_submit(IOContext* ioc) {
  if (ioc->pending_aios.front().iocb.aio_lio_opcode == IO_CMD_PWRITEV) {
    {
      std::lock_guard lock(write_lock);
      if (ioc != pending_iocs.back()) {
        dout(10) << __func__ << " push ioc " << ioc << dendl;
        pending_iocs.push_back(ioc);
      }
      else {
        dout(10) << __func__ << " coflict ioc " << ioc << dendl;
      }
    }
    do_aio_submit();
  }
  else {
    KernelDevice::aio_submit(ioc);
  }
  return;
}

void HMSMRDevice::do_aio_submit() {
  std::lock_guard lock(write_lock);
  if (pending_iocs.size() == 0) {
    dout(10) << __func__ << " no pending ioc" << dendl;
    return;
  }
  auto ioc = pending_iocs.front();
  dout(10) << __func__ << " target pending ioc" <<  ioc <<  dendl;

  if (ioc->num_running.load() > 0) {
    dout(10) << __func__ << " return due to running aio of ioc " << ioc << dendl;
    return;
  }

  if (ioc->num_pending.load() == 0) {
    dout(10) << __func__ << " all aios in ioc " << ioc << " are submitted" << dendl;
    pending_iocs.pop_front();
    if (pending_iocs.size() == 0) {
      dout(10) << __func__ << " no pending ioc" << dendl;
      return;
    }
    ioc = pending_iocs.front();
  }

  list<aio_t>::iterator e = ioc->running_aios.begin();
  auto pending_aio = ioc->pending_aios.front();
  dout(10) << __func__ << " off " << std::hex << pending_aio.offset << " len " << std::hex << pending_aio.length << dendl;
  ioc->running_aios.push_front(pending_aio);
  ioc->pending_aios.pop_front();
  int pending = 1;
  dout(10) << __func__ << " before submission ioc " << ioc
    << " pending " << ioc->num_pending.load()
    << " running " << ioc->num_running.load() <<dendl;

  ioc->num_running++;
  ioc->num_pending--;
  dout(10) << __func__ << " after submission ioc " << ioc
    << " pending " << ioc->num_pending.load()
    << " running " << ioc->num_running.load() <<dendl;

  void* priv = static_cast<void*>(ioc);
  int r, retries = 0;
  assert(pending <= std::numeric_limits<uint16_t>::max());
  r = io_queue->submit_batch(ioc->running_aios.begin(), e,
      pending, priv, &retries);

  if (retries)
    derr << __func__ << " retries " << retries << dendl;
  if (r < 0) {
    derr << " aio submit got " << cpp_strerror(r) << dendl;
    ceph_assert(r == 0);
  }

  return;
}
