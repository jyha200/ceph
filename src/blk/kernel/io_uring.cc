// -*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab

#include "io_uring.h"

#if defined(HAVE_LIBURING)

#include "liburing.h"

#include <sys/epoll.h>
#include <linux/nvme_ioctl.h>
#include "common/debug.h"

#define dout_context cct
#define dout_subsys ceph_subsys_bdev
#undef dout_prefix
#define dout_prefix *_dout << " uring_q "

using std::list;
using std::make_unique;

// TODO Get block size from device
static const size_t BLK_SIZE = 4096;

struct ioring_data {
  struct io_uring io_uring;
  pthread_mutex_t cq_mutex;
  pthread_mutex_t sq_mutex;
  int epoll_fd = -1;
  std::map<int, int> fixed_fds_map;
  bool use_append = false;
  CephContext* cct;
};

struct block_uring_cmd {
  __u32   ioctl_cmd;
  __u32   unused1;
  __u64   unused2[4];
};

struct nvme_user_io_t {
  uint32_t cdw00_09[10];
  uint64_t slba;
  uint32_t nlb  : 16;
  uint32_t rsvd :  4;
  uint32_t dtype  :  4;
  uint32_t rsvd2  :  2;
  uint32_t prinfo :  4;
  uint32_t fua  :  1;
  uint32_t lr :  1;
  uint32_t cdw13_15[3];
};

struct nvme_io_command_t {
  union {
#ifdef NVME_IOCTL_IO64_CMD
    nvme_passthru_cmd64 common;
#else
    nvme_passthru_cmd common;
#endif
    nvme_user_io_t rw;
    uint8_t raw[64];
  };

  enum class opcode {
    FLUSH = 0x0,
    WRITE = 0x1,
    READ = 0x2,
    APPEND = 0x7D,
  };
};

struct uring_priv_t {
  nvme_io_command_t io_cmd = {0,};
  aio_t* aio;
};

// TODO replace self definition to that of liburing library
static const uint32_t IORING_OP_URING_CMD = 40;

static void post_process_append(aio_t *io, uring_priv_t *uring_priv) {
  ceph_assert(io->post_offset_ptr != NULL);
  io->post_offset_ptr[0] = uring_priv->io_cmd.common.result * BLK_SIZE;
}

static int ioring_get_cqe(struct ioring_data *d, unsigned int max,
			  struct aio_t **paio)
{
  struct io_uring *ring = &d->io_uring;
  struct io_uring_cqe *cqe;

  unsigned nr = 0;
  unsigned head;
  io_uring_for_each_cqe(ring, head, cqe) {
    struct aio_t *io = NULL;
    if (d->use_append) {
      uring_priv_t *uring_priv = (uring_priv_t *)(uintptr_t) io_uring_cqe_get_data(cqe);
      io = uring_priv->aio;
      if (io->iocb.aio_lio_opcode == IO_CMD_PWRITEV) {
        post_process_append(io, uring_priv);
      }
      cqe->res = io->length;
      delete uring_priv;
    } else {
      io = (struct aio_t *)(uintptr_t) io_uring_cqe_get_data(cqe);
    }

    io->rval = cqe->res;
    paio[nr++] = io;

    if (nr == max)
      break;
  }
  io_uring_cq_advance(ring, nr);

  return nr;
}

static int find_fixed_fd(struct ioring_data *d, int real_fd)
{
  auto it = d->fixed_fds_map.find(real_fd);
  if (it == d->fixed_fds_map.end())
    return -1;

  return it->second;
}

static void create_passthrough_command(
  io_uring_sqe *sqe,
  int fd,
  uring_priv_t *uring_priv)
{
  nvme_io_command_t *io_cmd = &uring_priv->io_cmd;
  sqe->opcode = IORING_OP_URING_CMD;
  sqe->addr = 4;
  sqe->len = io_cmd->common.data_len;
  sqe->off = reinterpret_cast<uint64_t>(io_cmd);
  sqe->flags = 0;
  sqe->ioprio = 0;
  sqe->user_data = reinterpret_cast<uint64_t>(uring_priv);
  sqe->rw_flags = 0;
  sqe->__pad2[0] = 0;
  sqe->__pad2[1] = 0;
  sqe->__pad2[2] = 0;

  struct block_uring_cmd  *blk_cmd =
    reinterpret_cast<block_uring_cmd *>(&sqe->len);

#ifdef NVME_IOCTL_IO64_CMD
  blk_cmd->ioctl_cmd = NVME_IOCTL_IO64_CMD;
#else
  blk_cmd->ioctl_cmd = NVME_IOCTL_IO_CMD;
#endif
  blk_cmd->unused2[0] = reinterpret_cast<uint64_t>(uring_priv);
}

static void create_io_command(
  nvme_io_command_t *io_cmd,
  nvme_io_command_t::opcode opcode,
  uint64_t offset,
  uint64_t length,
  void* buf)
{
  io_cmd->common.opcode = static_cast<uint8_t>(opcode);
  // TODO need to set real nsid
  io_cmd->common.nsid = 1;
  io_cmd->common.addr = reinterpret_cast<uint64_t>(buf);
  io_cmd->common.data_len = length;
  io_cmd->rw.slba = offset / BLK_SIZE;
  io_cmd->rw.nlb = length / BLK_SIZE - 1;
}

static void create_read_command(
  io_uring_sqe *sqe,
  int fd,
  aio_t *io,
  uring_priv_t *uring_priv)
{
  // No vector support for read
  ceph_assert(io->iov.size() == 1);
  create_io_command(
    &uring_priv->io_cmd,
    nvme_io_command_t::opcode::READ,
    io->offset,
    io->length,
    io->iov[0].iov_base);

  create_passthrough_command(sqe, fd, uring_priv);
}

static void create_append_command(
  io_uring_sqe *sqe,
  int fd,
  aio_t *io,
  uring_priv_t *uring_priv)
{
  // No vector support for append
  ceph_assert(io->iov.size() == 1);

  create_io_command(
    &uring_priv->io_cmd,
    nvme_io_command_t::opcode::APPEND,
    io->offset,
    io->length,
    io->iov[0].iov_base);

  create_passthrough_command(sqe, fd, uring_priv);
}

static void init_sqe(struct ioring_data *d, struct io_uring_sqe *sqe,
		     struct aio_t *io)
{
  int fixed_fd = find_fixed_fd(d, io->fd);

  ceph_assert(fixed_fd != -1);
  void *priv = io;

  if (d->use_append) {
    uring_priv_t* uring_priv = new uring_priv_t;
    uring_priv->aio = io;
    priv = uring_priv;
    if (io->iocb.aio_lio_opcode == IO_CMD_PWRITEV) {
      create_append_command(sqe, fixed_fd, io, uring_priv);
    } else if (io->iocb.aio_lio_opcode == IO_CMD_PREADV) {
      create_read_command(sqe, fixed_fd, io, uring_priv);
    } else {
      ceph_assert(0);
    }
  } else {
    if (io->iocb.aio_lio_opcode == IO_CMD_PWRITEV) {
      io_uring_prep_writev(sqe, fixed_fd, &io->iov[0],
        io->iov.size(), io->offset);
    }
    else if (io->iocb.aio_lio_opcode == IO_CMD_PREADV)
      io_uring_prep_readv(sqe, fixed_fd, &io->iov[0],
        io->iov.size(), io->offset);
    else
      ceph_assert(0);
  }

  io_uring_sqe_set_data(sqe, priv);
  io_uring_sqe_set_flags(sqe, IOSQE_FIXED_FILE);
}

static int ioring_queue(struct ioring_data *d, void *priv,
			list<aio_t>::iterator beg, list<aio_t>::iterator end)
{
  struct io_uring *ring = &d->io_uring;
  struct aio_t *io = nullptr;

  ceph_assert(beg != end);

  do {
    struct io_uring_sqe *sqe = io_uring_get_sqe(ring);
    if (!sqe)
      break;

    io = &*beg;
    io->priv = priv;

    init_sqe(d, sqe, io);

  } while (++beg != end);

  if (!io)
    /* Queue is full, go and reap something first */
    return 0;

  return io_uring_submit(ring);
}

static void build_fixed_fds_map(struct ioring_data *d,
				std::vector<int> &fds)
{
  int fixed_fd = 0;
  for (int real_fd : fds) {
    d->fixed_fds_map[real_fd] = fixed_fd++;
  }
}

ioring_queue_t::ioring_queue_t(
  unsigned iodepth_,
  bool hipri_,
  bool sq_thread_,
  CephContext* cct) :
  iodepth(iodepth_),
  hipri(hipri_),
  sq_thread(sq_thread_),
  cct(cct)
{
}

ioring_queue_t::~ioring_queue_t()
{
}

void ioring_queue_t::enable_append()
{
  use_append = true;
  ring_count = cct->_conf->io_uring_ring_count;
  ldout(cct, 1) << __func__ << " set ring_count " << ring_count <<  dendl;
}

int ioring_queue_t::init_ring(uint32_t i, std::vector<int> &fds)
{
  auto& d = datas[i];
  unsigned flags = 0;
  pthread_mutex_init(&d->cq_mutex, NULL);
  pthread_mutex_init(&d->sq_mutex, NULL);
  d->use_append = use_append;
  d->cct = cct;

  if (hipri)
    flags |= IORING_SETUP_IOPOLL;
  if (sq_thread)
    flags |= IORING_SETUP_SQPOLL;

  int ret = io_uring_queue_init(iodepth, &d->io_uring, flags);
  if (ret < 0)
    return ret;

  ret = io_uring_register_files(&d->io_uring,
			  &fds[0], fds.size());
  if (ret < 0) {
    ret = -errno;
    goto close_ring_fd;
  }

  build_fixed_fds_map(d.get(), fds);

  d->epoll_fd = epoll_create1(0);
  if (d->epoll_fd < 0) {
    ret = -errno;
    goto close_ring_fd;
  }

  struct epoll_event ev;
  ev.events = EPOLLIN;
  ret = epoll_ctl(d->epoll_fd, EPOLL_CTL_ADD, d->io_uring.ring_fd, &ev);
  if (ret < 0) {
    ret = -errno;
    goto close_epoll_fd;
  }

  return 0;

close_epoll_fd:
  close(d->epoll_fd);
close_ring_fd:
  io_uring_queue_exit(&d->io_uring);

  return ret;

}

int ioring_queue_t::init(std::vector<int> &fds)
{
  int ret = 0;
  datas.resize(ring_count);

  for (uint32_t i = 0 ; i < ring_count ; i++) {
    datas[i] = std::make_unique<ioring_data>();
    ret = init_ring(i, fds);
    if (ret < 0) {
      break;
    }
  }
  return ret;
}

void ioring_queue_t::shutdown()
{
  for (uint32_t i = 0 ; i < ring_count ; i++) {
    auto& d = datas[i];
    d->fixed_fds_map.clear();
    close(d->epoll_fd);
    d->epoll_fd = -1;
    io_uring_queue_exit(&d->io_uring);
  }
}

int ioring_queue_t::submit_batch(aio_iter beg, aio_iter end,
                                 uint16_t aios_size, void *priv,
                                 int *retries)
{
  uint32_t ring_idx = get_ring_idx();
  auto& d = datas[ring_idx];
  pthread_mutex_lock(&d->sq_mutex);
  int rc = ioring_queue(d.get(), priv, beg, end);
  pthread_mutex_unlock(&d->sq_mutex);

  return rc;
}

int ioring_queue_t::get_ring_next_completed(
  int timeout_ms,
  aio_t **paio,
  int max,
  uint32_t ring_idx)
{
get_cqe:
  auto& d = datas[ring_idx];
  pthread_mutex_lock(&d->cq_mutex);
  int events = ioring_get_cqe(d.get(), max, paio);
  pthread_mutex_unlock(&d->cq_mutex);

  if (events == 0 && use_append == false) {
    struct epoll_event ev;
    int ret = TEMP_FAILURE_RETRY(epoll_wait(d->epoll_fd, &ev, 1, timeout_ms));
    if (ret < 0)
      events = -errno;
    else if (ret > 0)
      /* Time to reap */
      goto get_cqe;
  }
  ceph_assert(events <= max);
  
  if (events > 0) {
    ldout(cct, 20) << __func__ << " max " << max << " events " << events << dendl;
  }

  return events;
}

int ioring_queue_t::get_next_completed(int timeout_ms, aio_t **paio, int max)
{
  int events = 0;
  for (uint32_t i = 0 ; i < ring_count ; i++) {
    if (events == max) {
      break;
    }
    events += get_ring_next_completed(
      timeout_ms,
      paio + events,
      max - events,
      i);
  }
  ceph_assert(events <= max);
  if (events == 0) {
    usleep(1);
  } else {
    ldout(cct, 20) << __func__ << " max " << max << " events " << events << dendl;
  }

  return events;
}

thread_local int32_t thread_ring_idx = -1;

uint32_t ioring_queue_t::get_ring_idx()
{
  if (use_append) {
    if (thread_ring_idx == -1) {
      uint32_t assigned = (++last_assigned);
      thread_ring_idx = assigned % ring_count;
    }
    return thread_ring_idx;
  } else {
    return 0;
  }
}

bool ioring_queue_t::supported()
{
  struct io_uring ring;
  int ret = io_uring_queue_init(16, &ring, 0);
  if (ret) {
    return false;
  }
  io_uring_queue_exit(&ring);
  return true;
}

#else // #if defined(HAVE_LIBURING)

struct ioring_data {};

ioring_queue_t::ioring_queue_t(unsigned iodepth_, bool hipri_, bool sq_thread_)
{
  ceph_assert(0);
}

ioring_queue_t::~ioring_queue_t()
{
  ceph_assert(0);
}

int ioring_queue_t::init(std::vector<int> &fds)
{
  ceph_assert(0);
}

void ioring_queue_t::shutdown()
{
  ceph_assert(0);
}

int ioring_queue_t::submit_batch(aio_iter beg, aio_iter end,
                                 uint16_t aios_size, void *priv,
                                 int *retries)
{
  ceph_assert(0);
}

int ioring_queue_t::get_next_completed(int timeout_ms, aio_t **paio, int max)
{
  ceph_assert(0);
}

bool ioring_queue_t::supported()
{
  return false;
}

#endif // #if defined(HAVE_LIBURING)
