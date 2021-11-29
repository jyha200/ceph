// -*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab

#include <sys/stat.h>

#include "crimson/common/log.h"
#include "include/buffer.h"

#include "io_uring_device.h"

namespace {
  seastar::logger& logger() {
    return crimson::get_logger(ceph_subsys_filestore);
  }
}

namespace crimson::os::seastore::nvme_device {
open_ertr::future<> IOUringNVMeDevice::open(
  const std::string& path,
  seastar::open_flags mode) {

  if (io_uring_supported() == false) {
    logger().error("open: io uring is not supported");
    return crimson::ct_error::input_output_error::make();
  }

  int flag = 0;
  // Submission queue poll
  // With SQPOLL, kernel thread polls submisison queue and submit commands
  // accumulated while polling period. Without SQPOLL, Every command submission
  // incurs interrupt to device. This feature is for submitting command to
  // device with less interrupts.
  flag |= IORING_SETUP_SQPOLL;

  // IO poll
  // With IOPOLL, user should poll completion queue for command completion
  // instead of getting completion from interrupt. Without IOPOLL, every command
  // completion incurs interrupt from device to host. This feature is for
  // command completions with less interrupts.
  flag |= IORING_SETUP_IOPOLL;

  int ret = io_uring_queue_init(QUEUE_DEPTH, &ring, flag);
  if (ret != 0) {
    logger().error("open: io uring queue is not initilized");
    return crimson::ct_error::input_output_error::make();
  }

  // IOUring library requires POSIX file descriptor which is not provided by
  // Seastar library. Therefore, open block device via open system call to get
  // POSIX file descriptor.
  fd = ::open(path.c_str(), static_cast<int>(mode));
  if (fd < 0) {
    logger().error("open: device open failed");
    return crimson::ct_error::input_output_error::make();
  }

  struct stat stat;
  ret = fstat(fd, &stat);
  if (ret < 0) {
    logger().error("open: fstat failed");
    return crimson::ct_error::input_output_error::make();
  }

  block_size = stat.st_blksize;
  size = stat.st_size;

  ret = io_uring_register_files(&ring, &fd, 1);
  if (ret != 0) {
    logger().error("open: linking device file to io uring is failed");
    return crimson::ct_error::input_output_error::make();
  }
  return open_ertr::now();
}

}
