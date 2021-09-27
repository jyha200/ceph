// -*- mode:C++; tab-width:8; c-basic-offset:2; indent-tabs-mode:t -*-
// vim: ts=8 sw=2 smarttab

#pragma once

#include <boost/intrusive/set.hpp>

#include "common/ceph_time.h"

#include "osd/osd_types.h"

#include "crimson/common/log.h"
#include "crimson/os/seastore/cached_extent.h"
#include "crimson/os/seastore/journal.h"
#include "crimson/os/seastore/seastore_types.h"
#include "crimson/os/seastore/segment_manager.h"
#include "crimson/os/seastore/transaction.h"
#include "crimson/os/seastore/segment_cleaner.h"

namespace crimson::os::seastore {

class CBJournalCleaner : public SpaceCleaner {
public:
  void mount(
    size_t _block_size,
    size_t _segment_size,
    size_t _num_segments) override;
  void init_mkfs(journal_seq_t head) override; 
  init_segments_ret init_segments() override;
  void complete_init() override;
  void stop() override;
  void set_extent_callback(ExtentCallbackInterface *cb) override;
  
  void set_journal_head(journal_seq_t head) override;
  void update_journal_tail_target(journal_seq_t target) override;
  
  using gc_cycle_ret = seastar::future<>;
  gc_cycle_ret do_gc_cycle();

private:
  /**
   * GCProcess
   *
   * Background gc process.
   */
  class GCProcess {
    std::optional<gc_cycle_ret> process_join;
    CBJournalCleaner &cleaner;
    bool stopping = false;
    std::optional<seastar::promise<>> blocking;

    gc_cycle_ret run();
    void wake();
    seastar::future<> maybe_wait_should_run();

  public:
    GCProcess(CBJournalCleaner &cleaner);
    void start();
    gc_cycle_ret stop();
    gc_cycle_ret run_until_halt();
  } gc_process;

  journal_seq_t journal_tail_target;
  journal_seq_t journal_tail_committed;
  journal_seq_t journal_head;
  ExtentCallbackInterface *ecb = nullptr;

  size_t block_size = 0;
  size_t segment_size = 0;
  num_journal_segments = 0;

  void maybe_wake_on_space_used();
  bool gc_should_run();
  journal_seq_t get_dirty_tail() const;

  gc_trim_journal_ret gc_trim_journal();

  using rewrite_dirty_iertr = work_iertr;
  using rewrite_dirty_ret = rewrite_dirty_iertr::future<>;
  rewrite_dirty_ret rewrite_dirty(
    Transaction &t,
    journal_seq_t limit);
};
using CBJournalCleanerRef = std::unique_ptr<CBJournalCleaner>;

}
