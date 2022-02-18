//-*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab

#pragma once

#include <string.h>

#include "liburing.h"

#include "nvmedevice.h"

namespace ceph {
  namespace buffer {
    class bufferptr;
  }
}

namespace crimson::os::seastore::nvme_device {
class IOUringNVMeDevice : public NVMeBlockDevice {
  io_uring ring;
  static const unsigned QUEUE_DEPTH = 1024;
  int fd;
public:
  read_ertr::future<> read(uint64_t offset, bufferptr &bptr) override;
  write_ertr::future<> write(
    uint64_t offset,
    bufferptr &bptr,
    uint16_t stream = 0) override;

  virtual discard_ertr::future<> discard(
    uint64_t offset,
    uint64_t len) override;

  open_ertr::future<> open(
      const std::string& path,
      seastar::open_flags mode) override;
  seastar::future<> close() override;

private:
  bool io_uring_supported() { return true; };
};
}
