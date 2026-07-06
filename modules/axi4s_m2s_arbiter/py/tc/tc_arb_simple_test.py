################################################################################
# pyUVM + cocotb port of sv/tc/tc_arb_simple_test.sv.
#
# Drives all 3 masters concurrently with COUNTER tdata / ALL tstrb / a fixed
# per-master TID (0, 1, 2) / fixed TDEST=0, 1024 bursts of 128 beats each --
# same traffic profile as the SV testcase. arb_scoreboard checks in-order
# equality between the combined master stream and the single slave stream.
################################################################################

from __future__ import annotations

import cocotb
from cocotb.triggers import Combine

from seq_lib.vip_axi4s_seq import vip_axi4s_seq
from vip_axi4s_types_pkg import (
  Axi4sTdataType, Axi4sTstrbType, Axi4sTidType, Axi4sTdestType,
)

from tc.arb_base_test import arb_base_test, run_arb_test, CFG_T


class tc_arb_simple_test(arb_base_test):

  async def run_phase(self):
    self.raise_objection()

    sequencers = (
      self.tb_env.mst_agent0.sequencer,
      self.tb_env.mst_agent1.sequencer,
      self.tb_env.mst_agent2.sequencer,
    )

    tasks = []
    for i, sequencer in enumerate(sequencers):
      seq = vip_axi4s_seq(f"vip_axi4s_seq{i}", CFG_T)
      seq.set_tdata_type(Axi4sTdataType.COUNTER)
      seq.set_cfg_burst_length(128, 1)
      seq.set_tstrb_type(Axi4sTstrbType.ALL)
      seq.set_id_type(Axi4sTidType.RANDOM)
      seq.set_tdest_type(Axi4sTdestType.CUSTOM)
      seq.set_tid(i)
      seq.set_tdest(0)
      seq.set_nr_of_bursts(1024)
      seq.set_log_denominator(4)
      tasks.append(cocotb.start_soon(seq.start(sequencer)))

    await Combine(*tasks)

    sb = self.tb_env.scoreboard0
    sb.assert_empty(expected_count=3 * 1024)
    self.drop_objection()


@cocotb.test(timeout_time=200, timeout_unit="ms")
async def tb_arb_simple_test(dut):
  await run_arb_test(dut, "tc_arb_simple_test")
