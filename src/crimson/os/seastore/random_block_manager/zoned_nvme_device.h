//-*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab

#pragma once

#include "nvmedevice.h"

namespace crimson::os::seastore::nvme_device {
class ZonedNVMeDevice : PosixNVMeDevice {
  size_t zone_size = 0;
  uint32_t nr_zones = 0;
  int fd;
  
public:
  ZonedNVMeDevice() {}
  ~ZonedNVMeDevice() = default;

  open_ertr::future<> open(
    const std::string &in_path,
    seastar::open_flags mode) override;
  seastar::future<> close() override;

  void reset_zone(uint32_t zone);

  /*
   * Preferred management size
   *
   * For zoned storage, user should be aware of zone size. For example, segment
   * should be sized and algined by zone size to write with consideration of
   * zone's write sequence. Otherwise, for the write violating zone's write
   * sequence, zoned storage returns write failure to user.
   */
   size_t get_zone_size() { return zone_size; }
};
}
