################################################################################
# pyUVM port of sv/tb/arb_scoreboard.sv.
#
# Four analysis exports (child uvm_subscriber forwarders -- pyuvm requires a
# real uvm_export_base on connect). mst0/mst1/mst2 all push into ONE combined
# master queue (matching the SV scoreboard, which compares strict FIFO order
# across all masters against the single slave stream, not per-master).
################################################################################

from __future__ import annotations

from pyuvm import uvm_component, uvm_subscriber


class _SbSub(uvm_subscriber):
  def __init__(self, name, parent, cb):
    super().__init__(name, parent)
    self._cb = cb

  def write(self, item):
    self._cb(item)


class arb_scoreboard(uvm_component):

  def __init__(self, name, parent):
    super().__init__(name, parent)
    self.master_items = []
    self.slave_items = []
    self.number_of_master_items = 0
    self.number_of_slave_items = 0
    self.number_of_compared = 0
    self.number_of_passed = 0
    self.number_of_failed = 0
    self.mst0_port = None
    self.mst1_port = None
    self.mst2_port = None
    self.slv0_port = None

  def build_phase(self):
    self._mst0_sub = _SbSub("mst0_sub", self, self._write_mst)
    self._mst1_sub = _SbSub("mst1_sub", self, self._write_mst)
    self._mst2_sub = _SbSub("mst2_sub", self, self._write_mst)
    self._slv0_sub = _SbSub("slv0_sub", self, self._write_slv)
    self.mst0_port = self._mst0_sub.analysis_export
    self.mst1_port = self._mst1_sub.analysis_export
    self.mst2_port = self._mst2_sub.analysis_export
    self.slv0_port = self._slv0_sub.analysis_export

  def check_phase(self):
    if self.master_items:
      self.logger.error("There are still items in the Master queue")
    if self.slave_items:
      self.logger.error("There are still items in the Slave queue")
    if self.number_of_failed != 0:
      self.logger.error(f"Test failed! ({self.number_of_failed}) mismatches")
    else:
      self.logger.info(
        f"Test passed ({self.number_of_passed})/({self.number_of_compared}) "
        "finished transfers")

  def assert_empty(self, expected_count=None):
    assert not self.master_items, (
      f"{len(self.master_items)} items still in the Master queue")
    assert not self.slave_items, (
      f"{len(self.slave_items)} items still in the Slave queue")
    if expected_count is not None:
      assert self.number_of_compared == expected_count, (
        f"Compared {self.number_of_compared}, expected {expected_count}")
    assert self.number_of_failed == 0, f"{self.number_of_failed} mismatches"

  def _write_mst(self, item):
    self.number_of_master_items += 1
    self.master_items.append(item)
    self.raise_objection()
    if self.master_items and self.slave_items:
      self._compare()
      self.drop_objection()

  def _write_slv(self, item):
    self.number_of_slave_items += 1
    self.slave_items.append(item)
    if self.master_items and self.slave_items:
      self._compare()
      self.drop_objection()

  def _compare(self):
    mst_item = self.master_items.pop(0)
    slv_item = self.slave_items.pop(0)

    if not _items_equal(mst_item, slv_item):
      self.logger.error(f"Packet number ({self.number_of_compared}) mismatches")
      self.number_of_failed += 1
    else:
      self.number_of_passed += 1
    self.number_of_compared += 1


def _items_equal(a, b):
  return (
    a.tdata == b.tdata and a.tstrb == b.tstrb and a.tkeep == b.tkeep and
    a.tuser == b.tuser and a.tid == b.tid and a.tdest == b.tdest
  )
