################################################################################
# pyUVM port of sv/tc/arb_base_test.sv.
#
# cocotb owns clock/reset (run_arb_test(), below, runs before
# uvm_root().run_test() begins) -- there is no clk_rst_agent/sequence on the
# Python side. This base test is just env plumbing; the traffic testcase
# (tc_arb_simple_test) does its own raise/drop objection.
################################################################################

from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from pyuvm import ConfigDB, uvm_root, uvm_test

from vip_axi4s_config import vip_axi4s_config
from vip_axi4s_if import Axi4sBus
from vip_axi4s_types_pkg import Axi4sCfgT, Axi4sAgentType

from tb.arb_env import arb_env

CFG_T = Axi4sCfgT(TDATA_BYTES_P=2, TID_WIDTH_P=2, TDEST_WIDTH_P=1)

MST_NAMES = ("mst_agent0", "mst_agent1", "mst_agent2")


class arb_base_test(uvm_test):

  def build_phase(self):
    self.tb_env = arb_env("tb_env", self)


async def run_arb_test(dut, test_name):
  """Counterpart of arb_tb_top.sv + arb_base_test.sv's reset sequence."""
  cocotb.start_soon(Clock(dut.clk, 10, unit="ns").start())

  mst_vifs = [Axi4sBus(dut, prefix=f"mst{i}_") for i in range(3)]
  slv_vif = Axi4sBus(dut, prefix="slv_")

  for vif in mst_vifs:
    vif.reset_master()
  slv_vif.reset_slave()

  dut.rst_n.value = 0
  for _ in range(5):
    await RisingEdge(dut.clk)
  dut.rst_n.value = 1
  await RisingEdge(dut.clk)

  mst_cfg = vip_axi4s_config("mst_cfg")
  mst_cfg.min_tvalid_delay_period = 2
  mst_cfg.max_tvalid_delay_period = 10

  slv_cfg = vip_axi4s_config("slv_cfg")
  slv_cfg.min_tready_delay_period = 2
  slv_cfg.max_tready_delay_period = 10
  slv_cfg.vip_axi4s_agent_type = Axi4sAgentType.SLAVE

  ConfigDB().set(None, "*", "cfg_t", CFG_T)

  for name, vif in zip(MST_NAMES, mst_vifs):
    path = f"uvm_test_top.tb_env.{name}"
    ConfigDB().set(None, path, "vif", vif)
    ConfigDB().set(None, path, "cfg", mst_cfg)

  slv_path = "uvm_test_top.tb_env.slv_agent0"
  ConfigDB().set(None, slv_path, "vif", slv_vif)
  ConfigDB().set(None, slv_path, "cfg", slv_cfg)

  await uvm_root().run_test(test_name, keep_set={ConfigDB})
