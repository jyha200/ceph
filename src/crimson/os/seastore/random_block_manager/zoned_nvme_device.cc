// -*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab

extern "C" {
#include <libzbd/zbd.h>
}

#include "crimson/common/log.h"
#include "include/buffer.h"

#include "zoned_nvme_device.h"

namespace {
  seastar::logger& logger() {
    return crimson::get_logger(ceph_subsys_filestore);
  }
}

namespace crimson::os::seastore::nvme_device {
open_ertr::future<> ZonedNVMeDevice::open(
    const std::string &in_path,
    seastar::open_flags mode) {
  zbd_info zbd_info;

  // Because libzbd is not supported by SeaStar yet, ZonedNVMeDevice utilizes
  // C-style libzbd.
  fd = zbd_open(in_path.c_str(), O_RDWR | O_DIRECT | O_LARGEFILE, &zbd_info);
  if (fd < 0) {
    logger().error(
      "zoned storage open {} failed ({})",
      in_path,
      strerror(errno));
    return crimson::ct_error::input_output_error::make();
  }
  zone_size = zbd_info.zone_size;

  // User of ZonedNVMeDevice should consider zone size when allocate, reclaim or
  // free device space.
  nr_zones = zbd_info.nr_zones;

  // After getting zone-specific information, start open sequence same with
  // conventional NVMe SSDs.
  return PosixNVMeDevice::open(in_path, mode);
}

seastar::future<> ZonedNVMeDevice::close() {
  return PosixNVMeDevice::close().then([this] () {
    zbd_close(fd);
    return seastar::now();
  });
}

void ZonedNVMeDevice::reset_zone(uint32_t zone) {
  if (nr_zones <= zone) {
    logger().error("requested zone {} exceeds nr_zone {}", zone, nr_zones);
    return;
  }

  int ret = zbd_reset_zones(fd, zone * zone_size, zone_size);
  if (ret < 0) {
    logger().error("reset zone {} failed", zone);
  }
}
}
