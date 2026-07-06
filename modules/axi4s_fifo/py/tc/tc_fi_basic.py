################################################################################
# pyUVM + cocotb port of sv/tc/tc_fi_basic.sv.
#
# Drives the master with COUNTER tdata / ALL tstrb, 2**16 bursts of up to 128
# beats each -- same traffic profile as the SV testcase. fi_scoreboard checks
# in-order tdata equality between the master and slave streams.
################################################################################

from __future__ import annotations

import cocotb
from cocotb.triggers import RisingEdge

from seq_lib.vip_axi4s_seq import vip_axi4s_seq
from vip_axi4s_types_pkg import Axi4sTdataType, Axi4sTstrbType

from tc.fi_base_test import fi_base_test, run_fi_test, CFG_T


class tc_fi_basic(fi_base_test):

  async def run_phase(self):
    self.raise_objection()
    # Let the mst_agent0 monitor/driver startup (armed in mst_agent0's own
    # run_phase, concurrently with this one) settle for a couple of edges
    # before the sequence starts. Without this, the very first beat of the
    # very first burst can race the monitor's startup and get missed --
    # only reproduces here because this DUT's ing_tready is already high at
    # reset (empty FIFO), so beat 0 can transfer on the first possible edge.
    await RisingEdge(cocotb.top.clk)
    await RisingEdge(cocotb.top.clk)

    seq = vip_axi4s_seq("vip_axi4s_seq0", CFG_T)
    seq.set_tdata_type(Axi4sTdataType.COUNTER)
    seq.set_cfg_burst_length(128, 1)
    seq.set_nr_of_bursts(2**16)
    seq.set_tstrb_type(Axi4sTstrbType.ALL)
    seq.set_log_denominator(64)
    await seq.start(self.tb_env.mst_agent0.sequencer)

    sb = self.tb_env.scoreboard0
    assert sb.number_of_failed == 0, f"{sb.number_of_failed} mismatches"
    self.drop_objection()


@cocotb.test(timeout_time=3600, timeout_unit="sec")
async def tb_fi_basic(dut):
  await run_fi_test(dut, "tc_fi_basic")
