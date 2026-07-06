from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

NR_OF_MASTERS = 4
ID_WIDTH = 4
ADDR_WIDTH = 16
DATA_WIDTH = 32


def set_field(signal, index: int, width: int, value: int) -> None:
  current = int(signal.value)
  mask = ((1 << width) - 1) << (index * width)
  signal.value = (current & ~mask) | ((value & ((1 << width) - 1)) << (index * width))


def get_bit(signal, index: int) -> int:
  return (int(signal.value) >> index) & 1


class AraEnv:
  def __init__(self, dut):
    self.dut = dut

  async def start(self) -> None:
    cocotb.start_soon(Clock(self.dut.clk, 10, unit="ns").start())
    self.dut.rst_n.value = 0
    self.dut.mst_arid.value = 0
    self.dut.mst_araddr.value = 0
    self.dut.mst_arlen.value = 0
    self.dut.mst_arsize.value = 0
    self.dut.mst_arburst.value = 0
    self.dut.mst_arregion.value = 0
    self.dut.mst_arvalid.value = 0
    self.dut.mst_rready.value = 0
    self.dut.slv_arready.value = 0
    self.dut.slv_rid.value = 0
    self.dut.slv_rresp.value = 0
    self.dut.slv_rdata.value = 0
    self.dut.slv_rlast.value = 0
    self.dut.slv_rvalid.value = 0
    for _ in range(5):
      await RisingEdge(self.dut.clk)
    self.dut.rst_n.value = 1
    await RisingEdge(self.dut.clk)

  def drive_read_request(self, master: int, arid: int, addr: int, length: int = 0) -> None:
    set_field(self.dut.mst_arid, master, ID_WIDTH, arid)
    set_field(self.dut.mst_araddr, master, ADDR_WIDTH, addr)
    set_field(self.dut.mst_arlen, master, 8, length)
    set_field(self.dut.mst_arsize, master, 3, 2)
    set_field(self.dut.mst_arburst, master, 2, 1)
    set_field(self.dut.mst_arregion, master, 4, 0)
    self.dut.mst_arvalid.value = int(self.dut.mst_arvalid.value) | (1 << master)

  async def wait_address_forwarded(self, master: int, timeout_cycles: int = 40) -> None:
    for _ in range(timeout_cycles):
      await RisingEdge(self.dut.clk)
      if int(self.dut.slv_arvalid.value) & 1:
        return
    raise AssertionError(f"Read request from master {master} was not forwarded")

  async def accept_address(self, master: int, timeout_cycles: int = 40) -> None:
    self.dut.slv_arready.value = 1
    for _ in range(timeout_cycles):
      await RisingEdge(self.dut.clk)
      if get_bit(self.dut.mst_arready, master):
        self.dut.mst_arvalid.value = int(self.dut.mst_arvalid.value) & ~(1 << master)
        await RisingEdge(self.dut.clk)
        self.dut.slv_arready.value = 0
        return
    raise AssertionError(f"Read address from master {master} was not accepted")

  async def send_read_data_with_stall(self, master: int, rid: int, data: int) -> None:
    self.dut.slv_rid.value = rid
    self.dut.slv_rdata.value = data
    self.dut.slv_rresp.value = 0
    self.dut.slv_rlast.value = 1
    self.dut.slv_rvalid.value = 1
    self.dut.mst_rready.value = 0
    await RisingEdge(self.dut.clk)
    assert get_bit(self.dut.mst_rvalid, master) == 1
    assert int(self.dut.slv_rready.value) == 0
    self.dut.mst_rready.value = 1 << master
    await RisingEdge(self.dut.clk)
    assert int(self.dut.mst_rid.value) == rid
    assert int(self.dut.mst_rdata.value) == data
    assert int(self.dut.slv_rready.value) == 1
    self.dut.slv_rvalid.value = 0
    self.dut.slv_rlast.value = 0
    self.dut.mst_rready.value = 0
    await RisingEdge(self.dut.clk)
