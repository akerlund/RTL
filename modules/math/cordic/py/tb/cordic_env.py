from __future__ import annotations

import math

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

DATA_WIDTH = 16
Q_BITS = DATA_WIDTH - 4
SCALE = 1 << Q_BITS
MASK = (1 << DATA_WIDTH) - 1


def to_signed(value: int, width: int = DATA_WIDTH) -> int:
  value &= (1 << width) - 1
  sign = 1 << (width - 1)
  return value - (1 << width) if value & sign else value


def to_unsigned(value: int, width: int = DATA_WIDTH) -> int:
  return value & ((1 << width) - 1)


def fixed_angle(rad: float) -> int:
  return to_unsigned(round(rad * SCALE))


def fixed_unit(value: float) -> int:
  return to_unsigned(round(value * SCALE))


class CordicEnv:
  def __init__(self, dut):
    self.dut = dut

  async def start(self) -> None:
    cocotb.start_soon(Clock(self.dut.clk, 10, unit="ns").start())
    self.dut.rst_n.value = 0
    self.dut.ing_tvalid.value = 0
    self.dut.ing_tdata.value = 0
    self.dut.ing_tid.value = 0
    self.dut.ing_tuser.value = 0
    for _ in range(5):
      await RisingEdge(self.dut.clk)
    self.dut.rst_n.value = 1
    await RisingEdge(self.dut.clk)

  async def send_angle(self, angle: float, tid: int) -> tuple[int, int, int]:
    self.dut.ing_tdata.value = fixed_angle(angle)
    self.dut.ing_tid.value = tid
    self.dut.ing_tuser.value = 0
    self.dut.ing_tvalid.value = 1
    await RisingEdge(self.dut.clk)
    self.dut.ing_tvalid.value = 0

    for _ in range(80):
      await RisingEdge(self.dut.clk)
      if self.dut.egr_tvalid.value == 1:
        data = int(self.dut.egr_tdata.value)
        cosine = to_signed(data & MASK)
        sine = to_signed(data >> DATA_WIDTH)
        return sine, cosine, int(self.dut.egr_tid.value)
    raise AssertionError("Timed out waiting for CORDIC result")


def check_angle(angle: float, sine: int, cosine: int, tolerance_lsb: int = 8) -> None:
  exp_sine = to_signed(fixed_unit(math.sin(angle)))
  exp_cosine = to_signed(fixed_unit(math.cos(angle)))
  assert abs(sine - exp_sine) <= tolerance_lsb, (
    f"sine mismatch for {angle}: got {sine}, expected {exp_sine}")
  assert abs(cosine - exp_cosine) <= tolerance_lsb, (
    f"cosine mismatch for {angle}: got {cosine}, expected {exp_cosine}")
