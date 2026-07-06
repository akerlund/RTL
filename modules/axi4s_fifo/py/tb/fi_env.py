################################################################################
# pyUVM port of sv/tb/fi_env.sv.
#
# No clk_rst_agent -- cocotb owns the clock/reset directly (see
# tc/fi_base_test.py), matching the established convention from the
# vip_axi4_agent pyUVM port.
################################################################################

from __future__ import annotations

from pyuvm import uvm_env

from vip_axi4s_agent import vip_axi4s_agent

from tb.fi_scoreboard import fi_scoreboard


class fi_env(uvm_env):

  def build_phase(self):
    self.mst_agent0 = vip_axi4s_agent("mst_agent0", self)
    self.slv_agent0 = vip_axi4s_agent("slv_agent0", self)
    self.scoreboard0 = fi_scoreboard("scoreboard0", self)

  def connect_phase(self):
    self.mst_agent0.monitor.tdata_port.connect(self.scoreboard0.mst_port)
    self.slv_agent0.monitor.tdata_port.connect(self.scoreboard0.slv_port)
