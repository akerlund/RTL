################################################################################
# pyUVM port of sv/tb/arb_env.sv.
#
# No clk_rst_agent -- cocotb owns the clock/reset directly (see
# tc/arb_base_test.py), matching the established convention from the
# vip_axi4_agent pyUVM port.
################################################################################

from __future__ import annotations

from pyuvm import uvm_env

from vip_axi4s_agent import vip_axi4s_agent

from tb.arb_scoreboard import arb_scoreboard


class arb_env(uvm_env):

  def build_phase(self):
    self.mst_agent0 = vip_axi4s_agent("mst_agent0", self)
    self.mst_agent1 = vip_axi4s_agent("mst_agent1", self)
    self.mst_agent2 = vip_axi4s_agent("mst_agent2", self)
    self.slv_agent0 = vip_axi4s_agent("slv_agent0", self)
    self.scoreboard0 = arb_scoreboard("scoreboard0", self)

  def connect_phase(self):
    self.mst_agent0.monitor.tdata_port.connect(self.scoreboard0.mst0_port)
    self.mst_agent1.monitor.tdata_port.connect(self.scoreboard0.mst1_port)
    self.mst_agent2.monitor.tdata_port.connect(self.scoreboard0.mst2_port)
    self.slv_agent0.monitor.tdata_port.connect(self.scoreboard0.slv0_port)
