from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from tb.uvm_reg.register_model import IirRegisterModel

Q_BITS = 17
ONE = 1 << Q_BITS
N_BITS = 32
MASK = (1 << N_BITS) - 1


def fixed(value: float) -> int:
  scaled = int(abs(value) * ONE)
  return -scaled if value < 0 else scaled


def to_signed(value: int, width: int = N_BITS) -> int:
  value &= (1 << width) - 1
  sign = 1 << (width - 1)
  return value - (1 << width) if value & sign else value


def qmul(a: int, b: int) -> int:
  product = (to_signed(a) * to_signed(b)) & ((1 << (2 * N_BITS)) - 1)
  return to_signed((product >> Q_BITS) & MASK)


class DirectFormIModel:
  def __init__(self, b0: int, b1: int, b2: int, a1: int, a2: int):
    self.b0 = to_signed(b0)
    self.b1 = to_signed(b1)
    self.b2 = to_signed(b2)
    self.a1 = to_signed(a1)
    self.a2 = to_signed(a2)
    self.x1 = 0
    self.x2 = 0
    self.y0 = 0
    self.y1 = 0

  def step(self, x0: int) -> int:
    y00 = qmul(self.b0, x0)
    y00 = to_signed(y00 + qmul(self.b1, self.x1))
    y00 = to_signed(y00 + qmul(self.b2, self.x2))
    y00 = to_signed(y00 - qmul(self.a1, self.y0))
    y = to_signed(y00 - qmul(self.a2, self.y1))
    self.x2 = self.x1
    self.x1 = x0
    self.y1 = self.y0
    self.y0 = y
    return y


class IirEnv:
  def __init__(self, dut):
    self.dut = dut
    self.reg_model = IirRegisterModel()

  async def start(self) -> None:
    cocotb.start_soon(Clock(self.dut.clk, 10, unit="ns").start())
    self.dut.rst_n.value = 0
    self.dut.x_valid.value = 0
    self.dut.x.value = 0
    self.reg_model.write(self.dut)
    for _ in range(8):
      await RisingEdge(self.dut.clk)
    self.dut.rst_n.value = 1
    for _ in range(8):
      await RisingEdge(self.dut.clk)

  def configure(self, f0: int, fs: int, q: int, iir_type: int, bypass: int) -> None:
    self.reg_model.configure(f0, fs, q, iir_type, bypass)
    self.reg_model.write(self.dut)

  async def wait_for_coefficients(self, timeout_cycles: int = 20000) -> None:
    for _ in range(timeout_cycles):
      await RisingEdge(self.dut.clk)
      if int(self.dut.sr_pole_a0.value) != 0 and int(self.dut.sr_zero_b0.value) != 0:
        return
    raise AssertionError("Timed out waiting for IIR coefficient calculation")

  async def send_sample(self, value: float) -> int:
    sample = fixed(value) if isinstance(value, float) else int(value)
    self.dut.x.value = sample
    self.dut.x_valid.value = 1
    await RisingEdge(self.dut.clk)
    self.dut.x_valid.value = 0
    for _ in range(20):
      await RisingEdge(self.dut.clk)
      if self.dut.y_valid.value == 1:
        return int(self.dut.y.value.signed_integer)
    raise AssertionError("Timed out waiting for IIR output")
