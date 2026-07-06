from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

from tb.mix_model import NR_OF_CHANNELS, float_to_fixed, mix_sample, to_unsigned
from tb.mix_scoreboard import MixScoreboard


class MixEnv:
  def __init__(self, dut):
    self.dut = dut
    self.scoreboard = MixScoreboard(dut)

  async def start(self) -> None:
    cocotb.start_soon(Clock(self.dut.clk, 10, unit="ns").start())
    cocotb.start_soon(self._monitor_dac())

    self.dut.rst_n.value = 0
    self.dut.x_valid.value = 0
    self.dut.dac_ready.value = 1
    self.dut.cmd_mix_clear_dac_min_max.value = 0
    self.set_channel_data([0.0] * NR_OF_CHANNELS)
    self.set_channel_gain([0.0] * NR_OF_CHANNELS)
    self.set_channel_pan([0.0] * NR_OF_CHANNELS)
    self.set_output_gain(0.0)

    for _ in range(5):
      await RisingEdge(self.dut.clk)
    self.dut.rst_n.value = 1
    await RisingEdge(self.dut.clk)

  def set_channel_data(self, values: list[float]) -> None:
    self._set_array("x_data", values)

  def set_channel_gain(self, values: list[float]) -> None:
    self._set_array("cr_mix_channel_gain", values)

  def set_channel_pan(self, values: list[float]) -> None:
    self._set_array("cr_mix_channel_pan", values)

  def set_output_gain(self, value: float) -> None:
    self.dut.cr_mix_output_gain.value = to_unsigned(float_to_fixed(value))

  async def send_sample(self, data: list[float], gain: list[float], pan: list[float],
                        output_gain: float) -> None:
    data_i = [float_to_fixed(v) for v in data]
    gain_i = [float_to_fixed(v) for v in gain]
    pan_i = [float_to_fixed(v) for v in pan]
    output_gain_i = float_to_fixed(output_gain)

    self.set_channel_data(data)
    self.set_channel_gain(gain)
    self.set_channel_pan(pan)
    self.set_output_gain(output_gain)
    self.scoreboard.expect(*mix_sample(data_i, gain_i, pan_i, output_gain_i))

    self.dut.x_valid.value = 1
    await RisingEdge(self.dut.clk)
    self.dut.x_valid.value = 0
    for _ in range(10):
      await RisingEdge(self.dut.clk)

  async def wait_for_compares(self, count: int, timeout_cycles: int = 200) -> None:
    for _ in range(timeout_cycles):
      if self.scoreboard.number_of_compared >= count:
        return
      await RisingEdge(self.dut.clk)
    raise AssertionError(
      f"Timed out waiting for {count} DAC pairs, got {self.scoreboard.number_of_compared}")

  def _set_array(self, prefix: str, values: list[float]) -> None:
    assert len(values) == NR_OF_CHANNELS
    for idx, value in enumerate(values):
      getattr(self.dut, f"{prefix}{idx}").value = to_unsigned(float_to_fixed(value))

  async def _monitor_dac(self) -> None:
    left = None
    while True:
      await RisingEdge(self.dut.clk)
      if self.dut.rst_n.value != 1:
        left = None
        continue
      if self.dut.dac_valid.value != 1 or self.dut.dac_ready.value != 1:
        continue

      data = int(self.dut.dac_data.value)
      if self.dut.dac_last.value == 0:
        left = data
      else:
        assert left is not None, "Saw right DAC sample before left sample"
        self.scoreboard.observe(left, data)
        left = None
