################################################################################
# pyUVM + cocotb port of sv/tc/tc_arb_simple_test.sv.
#
# Drives ONE sequence on the slv_agent0 sequencer with tdest randomized across
# the full [0, NR_OF_MASTERS_C-1] range (CUSTOM type falls through to the
# ported item's "else" branch -- a plain random.randint in [min,max], with no
# auto-increment -- so no separate "disable increment" call is needed here,
# unlike the SV VIP's set_enable_tdest_increment(FALSE)).
################################################################################

from __future__ import annotations

import cocotb

from seq_lib.vip_axi4s_seq import vip_axi4s_seq
from vip_axi4s_types_pkg import Axi4sTdataType, Axi4sTstrbType, Axi4sTidType, Axi4sTdestType

from tc.arb_base_test import arb_base_test, run_arb_test, CFG_T, NR_OF_MASTERS_C


class tc_arb_simple_test(arb_base_test):

  async def run_phase(self):
    self.raise_objection()

    seq = vip_axi4s_seq("vip_axi4s_seq0", CFG_T)
    seq.set_tdata_type(Axi4sTdataType.COUNTER)
    seq.set_cfg_burst_length(128, 1)
    seq.set_tstrb_type(Axi4sTstrbType.ALL)
    seq.set_id_type(Axi4sTidType.RANDOM)
    seq.set_tdest_type(Axi4sTdestType.CUSTOM)
    seq.set_tid(0)
    seq.set_nr_of_bursts(1024)
    seq.set_log_denominator(4)
    seq.set_cfg_tdest(NR_OF_MASTERS_C - 1, 0)

    await seq.start(self.tb_env.slv_agent0.sequencer)

    sb = self.tb_env.scoreboard0
    sb.assert_empty(expected_count=1024)
    self.drop_objection()


@cocotb.test(timeout_time=200, timeout_unit="ms")
async def tb_arb_simple_test(dut):
  await run_arb_test(dut, "tc_arb_simple_test")
