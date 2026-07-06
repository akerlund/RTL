import cocotb
from cocotb.triggers import RisingEdge

from tb.awa_env import AwaEnv


async def init_m2s(dut) -> None:
  dut.m2s_mst_awid.value = 0
  dut.m2s_mst_awaddr.value = 0
  dut.m2s_mst_awlen.value = 0
  dut.m2s_mst_awsize.value = 0
  dut.m2s_mst_awburst.value = 0
  dut.m2s_mst_awregion.value = 0
  dut.m2s_mst_awvalid.value = 0
  dut.m2s_mst_wdata.value = 0
  dut.m2s_mst_wstrb.value = 0
  dut.m2s_mst_wlast.value = 0
  dut.m2s_mst_wvalid.value = 0
  dut.m2s_mst_bready.value = 0
  dut.m2s_slv_awready.value = 0
  dut.m2s_slv_wready.value = 0
  dut.m2s_slv_bid.value = 0
  dut.m2s_slv_bresp.value = 0
  dut.m2s_slv_bvalid.value = 0
  await RisingEdge(dut.clk)


@cocotb.test()
async def tc_awa_invalid_region(dut):
  env = AwaEnv(dut)
  await env.start()
  await init_m2s(dut)

  dut.m2s_mst_awid.value = 0xA
  dut.m2s_mst_awaddr.value = 0x4100
  dut.m2s_mst_awlen.value = 0
  dut.m2s_mst_awsize.value = 2
  dut.m2s_mst_awburst.value = 1
  dut.m2s_mst_awregion.value = 3
  dut.m2s_mst_awvalid.value = 1

  for _ in range(10):
    await RisingEdge(dut.clk)
    if int(dut.m2s_mst_awready.value):
      break
  else:
    raise AssertionError("Invalid AWREGION was not accepted")

  assert int(dut.m2s_slv_awvalid.value) == 0
  dut.m2s_mst_awvalid.value = 0

  dut.m2s_mst_wdata.value = 0xCAFE_1200
  dut.m2s_mst_wstrb.value = 0xF
  dut.m2s_mst_wlast.value = 1
  dut.m2s_mst_wvalid.value = 1

  for _ in range(10):
    await RisingEdge(dut.clk)
    if int(dut.m2s_mst_wready.value):
      break
  else:
    raise AssertionError("Write beat for invalid AWREGION was not accepted")

  assert int(dut.m2s_slv_wvalid.value) == 0
  dut.m2s_mst_wvalid.value = 0
  dut.m2s_mst_wlast.value = 0

  for _ in range(10):
    await RisingEdge(dut.clk)
    if int(dut.m2s_mst_bvalid.value):
      break
  else:
    raise AssertionError("DECERR response was not returned")

  assert int(dut.m2s_mst_bid.value) == 0xA
  assert int(dut.m2s_mst_bresp.value) == 0b11
  assert int(dut.m2s_slv_bready.value) == 0

  dut.m2s_mst_bready.value = 1
  await RisingEdge(dut.clk)
  dut.m2s_mst_bready.value = 0
