from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from tb.uvm_reg.register_model import OscRegisterModel


class OscEnv:
  def __init__(self, dut):
    self.dut = dut
    self.reg_model = OscRegisterModel()

  async def start(self) -> None:
    cocotb.start_soon(Clock(self.dut.clk, 8, unit="ns").start())
    self.dut.rst_n.value = 0
    self.reg_model.write(self.dut)
    for _ in range(8):
      await RisingEdge(self.dut.clk)
    self.dut.rst_n.value = 1
    for _ in range(8):
      await RisingEdge(self.dut.clk)

  def configure(self, waveform: int, frequency_hz: int, duty: int) -> None:
    self.reg_model.configure(waveform, frequency_hz, duty)
    self.reg_model.write(self.dut)

  async def collect(self, cycles: int) -> list[int]:
    values = []
    for _ in range(cycles):
      await RisingEdge(self.dut.clk)
      values.append(int(self.dut.waveform.value.signed_integer))
    return values

  async def wait_for_activity(self, cycles: int = 5000) -> None:
    values = await self.collect(cycles)
    assert len(set(values)) > 1, "Oscillator waveform did not change"
