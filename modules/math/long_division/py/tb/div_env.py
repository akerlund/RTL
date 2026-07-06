from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

N_BITS = 24
Q_BITS = 15
MASK = (1 << N_BITS) - 1
MAX_VALUE = (1 << (N_BITS - 1)) - 1
MIN_VALUE = -(1 << (N_BITS - 1))


def to_signed(value: int, width: int = N_BITS) -> int:
  value &= (1 << width) - 1
  sign = 1 << (width - 1)
  return value - (1 << width) if value & sign else value


def to_unsigned(value: int, width: int = N_BITS) -> int:
  return value & ((1 << width) - 1)


def divide_ref(dividend: int, divisor: int) -> tuple[int, int]:
  dividend = to_signed(dividend)
  divisor = to_signed(divisor)
  if divisor == 0:
    return 0, 1
  quotient = int((dividend << Q_BITS) / divisor)
  overflow = quotient > MAX_VALUE or quotient < MIN_VALUE
  return (0 if overflow else to_unsigned(quotient)), int(overflow)


class DivEnv:
  def __init__(self, dut):
    self.dut = dut

  async def start(self) -> None:
    cocotb.start_soon(Clock(self.dut.clk, 10, unit="ns").start())
    self.dut.rst_n.value = 0
    self.dut.ing_tvalid.value = 0
    self.dut.ing_tdata.value = 0
    self.dut.ing_tlast.value = 0
    self.dut.ing_tid.value = 0
    for _ in range(5):
      await RisingEdge(self.dut.clk)
    self.dut.rst_n.value = 1
    await RisingEdge(self.dut.clk)

  async def divide(self, dividend: int, divisor: int, tid: int = 0) -> tuple[int, int, int]:
    await self._send_word(dividend, 0, tid)
    await self._send_word(divisor, 1, tid)
    for _ in range(20):
      await RisingEdge(self.dut.clk)
      if self.dut.egr_tvalid.value == 1:
        return int(self.dut.egr_tdata.value), int(self.dut.egr_tuser.value), int(self.dut.egr_tid.value)
    raise AssertionError("Timed out waiting for division result")

  async def _send_word(self, value: int, last: int, tid: int) -> None:
    self.dut.ing_tvalid.value = 1
    self.dut.ing_tdata.value = to_unsigned(value)
    self.dut.ing_tlast.value = last
    self.dut.ing_tid.value = tid
    while True:
      await RisingEdge(self.dut.clk)
      if self.dut.ing_tready.value == 1:
        break
    self.dut.ing_tvalid.value = 0
    self.dut.ing_tlast.value = 0
