import cocotb
from cocotb.triggers import RisingEdge

from tb.ara_env import AraEnv


async def init_m2s(dut) -> None:
  dut.m2s_mst_arid.value = 0
  dut.m2s_mst_araddr.value = 0
  dut.m2s_mst_arlen.value = 0
  dut.m2s_mst_arsize.value = 0
  dut.m2s_mst_arburst.value = 0
  dut.m2s_mst_arregion.value = 0
  dut.m2s_mst_arvalid.value = 0
  dut.m2s_mst_rready.value = 0
  dut.m2s_slv_arready.value = 0
  dut.m2s_slv_rid.value = 0
  dut.m2s_slv_rresp.value = 0
  dut.m2s_slv_rdata.value = 0
  dut.m2s_slv_rlast.value = 0
  dut.m2s_slv_rvalid.value = 0
  await RisingEdge(dut.clk)


@cocotb.test()
async def tc_ara_invalid_region(dut):
  env = AraEnv(dut)
  await env.start()
  await init_m2s(dut)

  dut.m2s_mst_arid.value = 0xB
  dut.m2s_mst_araddr.value = 0x5100
  dut.m2s_mst_arlen.value = 0
  dut.m2s_mst_arsize.value = 2
  dut.m2s_mst_arburst.value = 1
  dut.m2s_mst_arregion.value = 3
  dut.m2s_mst_arvalid.value = 1

  for _ in range(10):
    await RisingEdge(dut.clk)
    if int(dut.m2s_mst_arready.value):
      break
  else:
    raise AssertionError("Invalid ARREGION was not accepted")

  assert int(dut.m2s_slv_arvalid.value) == 0
  dut.m2s_mst_arvalid.value = 0

  for _ in range(10):
    await RisingEdge(dut.clk)
    if int(dut.m2s_mst_rvalid.value):
      break
  else:
    raise AssertionError("DECERR read response was not returned")

  assert int(dut.m2s_mst_rid.value) == 0xB
  assert int(dut.m2s_mst_rresp.value) == 0b11
  assert int(dut.m2s_mst_rdata.value) == 0
  assert int(dut.m2s_mst_rlast.value) == 1
  assert int(dut.m2s_slv_rready.value) == 0

  dut.m2s_mst_rready.value = 1
  await RisingEdge(dut.clk)
  dut.m2s_mst_rready.value = 0
