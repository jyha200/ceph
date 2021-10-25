//-*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab

#include "include/buffer.h"
#include "crimson/os/seastore/random_block_manager/nvmedevice.h"
#include "test/crimson/gtest_seastar.h"
#include "include/stringify.h"

using namespace crimson;
using namespace crimson::os;
using namespace crimson::os::seastore;
using namespace nvme_device;

#define TEST_REAL_DEVICE (1)
#if TEST_REAL_DEVICE
#define DEV_NAME "/dev/nvme0n1"
#else
#define DEV_NAME "ramdomblock_manager.test_nvmedevice"
#endif

struct nvdev_test_t : seastar_test_suite_t {
  std::unique_ptr<NVMeBlockDevice> device;
  std::string dev_path;

  static const uint64_t DEV_SIZE = 1024 * 1024 * 1024;

  nvdev_test_t() :
    device(nullptr),
    dev_path(DEV_NAME) {
    int fd = ::open(dev_path.c_str(), O_CREAT|O_RDWR|O_TRUNC, 0644);
    ceph_assert(fd >= 0);
#if !TEST_REAL_DEVICE
    ::ftruncate(fd, DEV_SIZE);
#endif
    ::close(fd);
  }
  ~nvdev_test_t() {
#if !TEST_REAL_DEVICE
    ::unlink(dev_path.c_str());
#endif
  }
};

static const uint64_t BUF_SIZE = 1024;
static const uint64_t BLK_SIZE = 4096;

struct nvdev_test_block_t {
  uint8_t data[BUF_SIZE];

  DENC(nvdev_test_block_t, v, p) {
    DENC_START(1, 1, p);
    for (uint64_t i = 0 ; i < BUF_SIZE; i++)
    {
      denc(v.data[i], p);
    }
    DENC_FINISH(p);
  }
};

WRITE_CLASS_DENC_BOUNDED(
  nvdev_test_block_t
)

TEST_F(nvdev_test_t, write_and_verify_test)
{
  run_async([this] {
    device = NVMeBlockDevice::create<PosixNVMeDevice>();
    device->open(dev_path, seastar::open_flags::rw).unsafe_get();
    nvdev_test_block_t original_data;
    std::minstd_rand0 generator;
    uint8_t value = generator();
    memset(original_data.data, value, BUF_SIZE);
    uint64_t bl_length = 0;
    {
      bufferlist bl;
      encode(original_data, bl);
      bl_length = bl.length();
      auto write_buf = ceph::bufferptr(buffer::create_page_aligned(BLK_SIZE));
      bl.begin().copy(bl_length, write_buf.c_str());
      device->write(0, write_buf).unsafe_get();
    }

    nvdev_test_block_t read_data;
    {
      auto read_buf = ceph::bufferptr(buffer::create_page_aligned(BLK_SIZE));
      device->read(0, read_buf).unsafe_get();
      bufferlist bl;
      bl.push_back(read_buf);
      auto bliter = bl.cbegin();
      decode(read_data, bliter);
    }

    int ret = memcmp(original_data.data, read_data.data, BUF_SIZE);
    device->close().wait();
    ASSERT_TRUE(ret == 0);
    device.reset(nullptr);
  });
}

TEST_F(nvdev_test_t, write_protection_usecase)
{
  run_async([this] {
    device = NVMeBlockDevice::create<PosixNVMeDevice>();
    device->open(dev_path, seastar::open_flags::rw).unsafe_get();
    const uint32_t CHECKSUM_OFFSET = BLK_SIZE * 2;

    // An example use case of write data protection
    // If user wish to protect their data by checksum like CRC32, they should
    // calculate checksum at the write and verify data via checksum at the read
    // in the normal case.
    // However, if the write protection is supported and enabled, user can
    // offload checksum calculation and verification, and omit checksum relative
    // steps.
    bool data_protection_enabled = device->is_data_protection_enabled();
    nvdev_test_block_t original_data;
    memset(original_data.data, 0x8, BUF_SIZE);
    {
      bufferlist bl;
      encode(original_data, bl);
      bl_length = bl.length();
      auto write_buf = ceph::bufferptr(buffer::create_page_aligned(BLK_SIZE));
      bl.begin().copy(bl_length, write_buf.c_str());

      // If data protection is disabled, user should calculate and store
      // checksum.
      if (data_protection_enabled == false) {
        uint32_t checksum = ceph_crc32c(0, original_data.data, BLK_SIZE);
        buffer
        nvdev_test_block_t checksum_data;
        ((uint32_t*)(checksum_data.data))[0] = checksum;
        device->write(BLK_SIZE, write_buf).unsafe_get();
        bufferlist bl;
        encode(checksum_data, bl);
        bl_length = bl.length();
        auto checksum_buf = ceph::bufferptr(buffer::create_page_aligned(BLK_SIZE));
        bl.begin().copy(bl_length, checksum_buf.c_str());
        device->write(CHECKSUM_OFFSET, checksum_buf).unsafe_get();
      }

      device->write(0, write_buf).unsafe_get();
    }

    nvdev_test_block_t read_data;
    {
      auto read_buf = ceph::bufferptr(buffer::create_page_aligned(BLK_SIZE));
      device->read(0, read_buf).unsafe_get();
      bufferlist bl;
      bl.push_back(read_buf);
      auto bliter = bl.cbegin();
      decode(read_data, bliter);

      // If data protection is disabled, user should verify data by reading
      // previously written checksum and calculate new checksum from data
      if (data_protection_enabled == false) {
        nvdev_test_block_t checksum_data;
        auto checksum_buf = ceph::bufferptr(buffer::create_page_aligned(BLK_SIZE));
        device->read(CHECKSUM_OFFSET, checksum_buf).unsafe_get();
        bufferlist bl;
        bl.push_back(checksum_buf);
        auto bliter = bl.cbegin();
        decode(checksum_data, bliter);
        uint32_t written_checksum = ((uint32_t*)(checksum_data.data))[0];
        uint32_t data_checksum = ceph_crc32c(0, read_data.data, BLK_SIZE);
        ASSERT_TRUE(written_checksum == data_checksum);
      }
    }

    printf("block size: %ld\n", device->get_block_size());
    device->close().wait();
    ASSERT_TRUE(true);
    device.reset(nullptr);
  });
}
