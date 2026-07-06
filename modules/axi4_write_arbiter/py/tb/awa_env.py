from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

ID_WIDTH = 4
ADDR_WIDTH = 16
DATA_WIDTH = 32
STRB_WIDTH = 4


def set_field(signal, index: int, width: int, value: int) -> None:
  current = int(signal.value)
  mask = ((1 << width) - 1) << (index * width)
  signal.value = (current & ~mask) | ((value & ((1 << width) - 1)) << (index * width))


def get_bit(signal, index: int) -> int:
  return (int(signal.value) >> index) & 1


class AwaEnv:
  def __init__(self, dut):
    self.dut = dut

  async def start(self) -> None:
    cocotb.start_soon(Clock(self.dut.clk, 10, unit="ns").start())
    self.dut.rst_n.value = 0
    self.dut.mst_awid.value = 0
    self.dut.mst_awaddr.value = 0
    self.dut.mst_awlen.value = 0
    self.dut.mst_awsize.value = 0
    self.dut.mst_awburst.value = 0
    self.dut.mst_awregion.value = 0
    self.dut.mst_awvalid.value = 0
    self.dut.mst_wdata.value = 0
    self.dut.mst_wstrb.value = 0
    self.dut.mst_wlast.value = 0
    self.dut.mst_wvalid.value = 0
    self.dut.mst_bready.value = 0
    self.dut.slv_awready.value = 0
    self.dut.slv_wready.value = 0
    self.dut.slv_bid.value = 0
    self.dut.slv_bresp.value = 0
    self.dut.slv_bvalid.value = 0
    for _ in range(5):
      await RisingEdge(self.dut.clk)
    self.dut.rst_n.value = 1
    await RisingEdge(self.dut.clk)

  def drive_write_address(self, master: int, awid: int, addr: int, length: int = 0) -> None:
    set_field(self.dut.mst_awid, master, ID_WIDTH, awid)
    set_field(self.dut.mst_awaddr, master, ADDR_WIDTH, addr)
    set_field(self.dut.mst_awlen, master, 8, length)
    set_field(self.dut.mst_awsize, master, 3, 2)
    set_field(self.dut.mst_awburst, master, 2, 1)
    set_field(self.dut.mst_awregion, master, 4, 0)
    self.dut.mst_awvalid.value = int(self.dut.mst_awvalid.value) | (1 << master)

  async def wait_address_forwarded(self, timeout_cycles: int = 40) -> None:
    for _ in range(timeout_cycles):
      await RisingEdge(self.dut.clk)
      if int(self.dut.slv_awvalid.value) & 1:
        return
    raise AssertionError("Write address was not forwarded")

  async def accept_address(self, master: int, timeout_cycles: int = 40) -> None:
    self.dut.slv_awready.value = 1
    for _ in range(timeout_cycles):
      await RisingEdge(self.dut.clk)
      if get_bit(self.dut.mst_awready, master):
        self.dut.mst_awvalid.value = int(self.dut.mst_awvalid.value) & ~(1 << master)
        await RisingEdge(self.dut.clk)
        self.dut.slv_awready.value = 0
        return
    raise AssertionError(f"Write address from master {master} was not accepted")

  async def send_write_data(self, master: int, data: int) -> None:
    set_field(self.dut.mst_wdata, master, DATA_WIDTH, data)
    set_field(self.dut.mst_wstrb, master, STRB_WIDTH, 0xF)
    self.dut.mst_wlast.value = int(self.dut.mst_wlast.value) | (1 << master)
    self.dut.mst_wvalid.value = 0
    self.dut.slv_wready.value = 1
    await RisingEdge(self.dut.clk)
    assert int(self.dut.slv_wvalid.value) == 0
    self.dut.mst_wvalid.value = 1 << master
    for _ in range(20):
      await RisingEdge(self.dut.clk)
      if get_bit(self.dut.mst_wready, master):
        assert int(self.dut.slv_wdata.value) == data
        assert int(self.dut.slv_wvalid.value) == 1
        self.dut.mst_wvalid.value = 0
        self.dut.mst_wlast.value = 0
        self.dut.slv_wready.value = 0
        await RisingEdge(self.dut.clk)
        return
    raise AssertionError(f"Write data from master {master} was not accepted")

  async def send_response(self, master: int, bid: int) -> None:
    self.dut.slv_bid.value = bid
    self.dut.slv_bresp.value = 0
    self.dut.slv_bvalid.value = 1
    self.dut.mst_bready.value = 0
    await RisingEdge(self.dut.clk)
    assert get_bit(self.dut.mst_bvalid, master) == 1
    assert int(self.dut.slv_bready.value) == 0
    self.dut.mst_bready.value = 1 << master
    await RisingEdge(self.dut.clk)
    assert int(self.dut.mst_bid.value) == bid
    assert int(self.dut.slv_bready.value) == 1
    self.dut.slv_bvalid.value = 0
    self.dut.mst_bready.value = 0
    await RisingEdge(self.dut.clk)
