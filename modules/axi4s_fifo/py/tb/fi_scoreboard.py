################################################################################
# pyUVM port of sv/tb/fi_scoreboard.sv.
#
# Two analysis exports (mst/slv), strict FIFO-order tdata compare -- matches
# the SV scoreboard's write_mst_port/write_slv_port/compare() logic.
################################################################################

from __future__ import annotations

from pyuvm import uvm_component, uvm_subscriber


class _SbSub(uvm_subscriber):
  def __init__(self, name, parent, cb):
    super().__init__(name, parent)
    self._cb = cb

  def write(self, item):
    self._cb(item)


class fi_scoreboard(uvm_component):

  def __init__(self, name, parent):
    super().__init__(name, parent)
    self.master_items = []
    self.slave_items = []
    self.number_of_master_items = 0
    self.number_of_slave_items = 0
    self.number_of_compared = 0
    self.number_of_passed = 0
    self.number_of_failed = 0
    self.mst_port = None
    self.slv_port = None

  def build_phase(self):
    self._mst_sub = _SbSub("mst_sub", self, self._write_mst)
    self._slv_sub = _SbSub("slv_sub", self, self._write_slv)
    self.mst_port = self._mst_sub.analysis_export
    self.slv_port = self._slv_sub.analysis_export

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

  def _write_slv(self, item):
    self.number_of_slave_items += 1
    self.slave_items.append(item)
    self._compare()
    self.drop_objection()

  def _compare(self):
    mst_item = self.master_items.pop(0)
    slv_item = self.slave_items.pop(0)

    if mst_item.tdata != slv_item.tdata:
      self.logger.error(f"Packet number ({self.number_of_compared}) mismatches")
      self.number_of_failed += 1
    else:
      self.number_of_passed += 1
    self.number_of_compared += 1
