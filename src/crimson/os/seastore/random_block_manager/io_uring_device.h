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
  virtual read_ertr::future<> read(
    uint64_t offset,
    bufferptr &bptr);

  virtual write_ertr::future<> write(
    uint64_t offset,
    bufferptr &bptr,
    uint16_t stream = 0);

  virtual discard_ertr::future<> discard(
    uint64_t offset,
    uint64_t len);

  virtual open_ertr::future<> open(
      const std::string& path,
      seastar::open_flags mode) = 0;
  virtual seastar::future<> close() = 0;

private:
  bool io_uring_supported() { return true; };
};
}
