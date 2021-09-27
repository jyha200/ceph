// -*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab

#pragma once

namespace crimson::os::seastore {

class ExtentManager {
public:
  using access_ertr = crimson::errorator<
    crimson::ct_error::input_output_error,
    crimson::ct_error::permission_denied,
    crimson::ct_error::invarg,
    crimson::ct_error::enoent>;

  using mount_ertr = access_ertr;
  using mount_ret = access_ertr::future<>;
  virtual mount_ret mount() = 0;

  using mkfs_ertr = access_ertr;
  using mkfs_ret = mkfs_ertr::future<>;
  virtual mkfs_ret mkfs(seastore_meta_t meta) = 0;

  using read_ertr = crimson::errorator<
    crimson::ct_error::input_output_error,
    crimson::ct_error::invarg,
    crimson::ct_error::enoent,
    crimson::ct_error::erange>;
  virtual read_ertr::future<> read(
    paddr_t addr,
    size_t len,
    ceph::bufferptr &out) = 0;
  read_ertr::future<ceph::bufferptr> read(
    paddr_t addr,
    size_t len) {
    auto ptrref = std::make_unique<ceph::bufferptr>(
      buffer::create_page_aligned(len));
    return read(addr, len, *ptrref).safe_then(
      [ptrref=std::move(ptrref)]() mutable {
	return read_ertr::make_ready_future<bufferptr>(std::move(*ptrref));
      });
  }

  virtual const seastore_meta_t &get_meta() const = 0;
  virtual size_t get_size() const = 0;
  virtual size_t get_block_size() const = 0;
  virtual ~ExtentManager() {}
};

using ExtentManagerRef = std::unique_ptr<ExtentManager>;
}
