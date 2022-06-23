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

#ifndef CEPH_BLK_HMSMRDEVICE_H
#define CEPH_BLK_HMSMRDEVICE_H

#include <atomic>
#include <queue>

#include "include/types.h"
#include "include/interval_set.h"
#include "common/Thread.h"
#include "include/utime.h"

#include "aio/aio.h"
#include "BlockDevice.h"
#include "../kernel/KernelDevice.h"

class HMSMRDevice final : public KernelDevice {
  int zbd_fd = -1;	///< fd for the zoned block device
  int legacy_fd = -1;	///< fd for the zoned block device
  int cns_fd = -1;
  size_t nr_zones = -1;
  std::recursive_mutex write_lock;
  std::list<IOContext*> pending_iocs;

  struct zone_pending_io_t {
    std::list<aio_t> aios;
    std::recursive_mutex lock;
    bool running = false;
  };

  zone_pending_io_t* pending_ios;
  bool support_append_ = false;
  bool support_multi_qd_submission_ = false;

public:
  HMSMRDevice(CephContext* cct, aio_callback_t cb, void *cbpriv,
              aio_callback_t d_cb, void *d_cbpriv);

  static bool support(const std::string& path);
  void print(IOContext* ioc);

  // open/close hooks for libzbd
  int _post_open() override;
  void _pre_close() override;

  // smr-specific methods
  bool is_smr() const final { return true; }
  void reset_all_zones() override;
  void reset_zone(uint64_t zone) override;
  std::vector<uint64_t> get_zones() override;

  int discard(uint64_t offset, uint64_t len) override {
    // discard is a no-op on a zoned device
    return 0;
  }

	void aio_submit(IOContext* ioc) override;
	void do_aio_submit(uint64_t zone, bool completed);

	bool supported_bdev_label() override { return false; }
  bool support_append() const override { return support_append_; }
  bool support_multi_qd_submission() const override { return support_multi_qd_submission_; }
};

#endif //CEPH_BLK_HMSMRDEVICE_H
