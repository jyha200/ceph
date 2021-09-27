// -*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab

#include "osd/osd_types.h"

#include "crimson/os/seastore/circular_bounded_journal_cleaner.h"

namespace crimson::os::seastore {

void CBJournalCleaner::mount(
  size_t _block_size,
  size_t _segment_size,
  size_t _num_segments)
{
  journal_tail_target = journal_seq_t{};
  journal_tail_committed = journal_seq_t{};
  journal_head = journal_seq_t{};

  block_size = _block_size;
  segment_size = _segment_size;
  num_journal_segments = _num_segments;
}

void CBJournalCleaner::init_mkfs(journal_seq_t head)
{
  journal_tail_target = head;
  journal_tail_committed = head;
  journal_head = head;
}

CBJournalCleaner::init_segments_ret CBJournalCleaner::init_segments()
{
  return seastar::do_with(
      std::vector<std::pair<segment_id_t, segment_header_t>>(),
      [this](auto& segments) {
      for (int i = 0 ; i < num_journal_segments ; i++) {
      segments.emplace_back(std::make_pair(i, segment_header_t()));
      }

      return seastar::make_ready_future<
      std::vector<std::pair<segment_id_t, segment_header_t>>>(
          std::move(segments));
      });
}

void CBJournalCleaner::set_journal_headi(journal_seq_t head)
{
  assert(journal_head == journal_seq_t() || head >= journal_head);
  journal_head = head;
  maybe_wake_on_space_used();
}

void CBJournalCleaner::update_journal_tail_target(journal_seq_t target)
{
  logger().debug(
      "{}: {}, current tail target {}",
      __func__,
      target,
      journal_tail_target);
  assert(journal_tail_target == journal_seq_t() || target >= journal_tail_target);
  if (journal_tail_target == journal_seq_t() || target > journal_tail_target) {
    journal_tail_target = target;
  }
  maybe_wake_on_space_used();
  //maybe_wake_gc_blocked_io();
}

void CBJournalCleaner::complete_init()
{
  gc_process.run();
}

void CBJournalCleaner::stop()
{
  gc_process.stop();
}

void CBJournalCleaner::set_extent_callback(ExtentCallbackInterface *cb)
{
  ecb = cb;
}

CBJournalCleaner::gc_cycle_ret CBJournalCleaner::do_gc_cycle()
{
  if (gc_should_run()) {
    return gc_trim_journal(
        ).handle_error(
          crimson::ct_error::assert_all{
          "GCProcess::run encountered invalid error in gc_trim_journal"
          }
          );
  } else {
    return seastar::now();
  }
}

CBJournalCleaner::gc_trim_journal_ret CBJournalCleaner::gc_trim_journal()
{
  return repeat_eagain([this] {
    return ecb->with_transaction_intr(
        Transaction::src_t::CLEANER, [this](auto& t) {
      return rewrite_dirty(t, get_dirty_tail()
      ).si_then([this, &t] {
        return ecb->submit_transaction_direct(t);
      });
    });
  });
}

void CBJournalCleaner::GCProcess::wake()
{
  if (blocking) {
    blocking->set_value();
    blocking = std::nullopt;
  }
}

seastar::future<> CBJournalCleaner::GCProcess::maybe_wait_should_run()
{
  return seastar::do_until(
      [this] {
      cleaner.log_gc_state("GCProcess::maybe_wait_should_run");
      return stopping || cleaner.gc_should_run();
      },
      [this] {
      ceph_assert(!blocking);
      blocking = seastar::promise<>();
      return blocking->get_future();
      });
}

CBJournalCleaner::GCProcess::GCProcess(CBJournalCleaner &cleaner)
  : cleaner(cleaner) { }

void CBJournalCleaner::GCProcess::start()
{
  ceph_assert(!process_join);
  process_join = run();
}

CBJournalCleaner::gc_cycle_ret CBJournalCleaner::GCProcess::stop()
{
  if (!process_join)
    return seastar::now();
  stopping = true;
  wake();
  ceph_assert(process_join);
  auto ret = std::move(*process_join);
  process_join = std::nullopt;
  return ret.then([this] { stopping = false; });
}

CBJournalCleaner::gc_cycle_ret CBJournalCleaner::GCProcess::run_until_halt()
{
  ceph_assert(!process_join);
  return seastar::do_until(
      [this] {
      cleaner.log_gc_state("GCProcess::run_until_halt");
      return !cleaner.gc_should_run();
      },
      [this] {
      return cleaner.do_gc_cycle();
      });
}
 
void CBJournalCleaner::maybe_wake_on_space_used()
{
  if (gc_should_run()) {
    gc_process.wake();
  }
}

bool CBJournalCleaner::gc_should_run()
{
  /* GC is Only for CBJournal area because RBM area is managed by in-place
   * update manner. */
  return get_dirty_tail() > journal_tail_target;
}

journal_seq_t CBJournalCleaner::get_dirty_tail() const
{
  auto ret = journal_head;
  ret.segment_seq -= std::min(
      static_cast<size_t>(ret.segment_seq),
      config.target_journal_segments);
  return ret;
}

CBJournalCleaner::rewrite_dirty_ret CBJournalCleaner::rewrite_dirty(
  Transaction &t,
  journal_seq_t limit)
{
  LOG_PREFIX(CBJournalCleanerCleaner::rewrite_dirty);
  return ecb->get_next_dirty_extents(
    t,
    limit,
    config.journal_rewrite_per_cycle
  ).si_then([=, &t](auto dirty_list) {
    return seastar::do_with(
      std::move(dirty_list),
      [FNAME, this, &t](auto &dirty_list) {
	return trans_intr::do_for_each(
	  dirty_list,
	  [FNAME, this, &t](auto &e) {
	    DEBUGT("cleaning {}", t, *e);

            /* All journal logs are re-written with ool(true) to go RBM area
             * directly. */
            bool ool = true;
	    return ecb->rewrite_extent(t, e, ool);
	  });
      });
  });
}

}
