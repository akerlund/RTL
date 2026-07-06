from __future__ import annotations

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

DATA_WIDTH = 25
MASK = (1 << DATA_WIDTH) - 1


class VecScoreboard:
  def __init__(self, dut):
    self.dut = dut
    self.expected = []
    self.number_of_compared = 0
    self.number_of_failed = 0

  def expect(self, value: int) -> None:
    self.expected.append(value & MASK)

  def observe(self, value: int) -> None:
    value &= MASK
    if not self.expected:
      self.number_of_failed += 1
      self.dut._log.error("Unexpected vector 0x%x", value)
      return
    expected = self.expected.pop(0)
    self.number_of_compared += 1
    if value != expected:
      self.number_of_failed += 1
      self.dut._log.error(
        "Vector mismatch %0d: expected 0x%x, got 0x%x",
        self.number_of_compared, expected, value)

  def check(self, expected_count: int) -> None:
    assert self.number_of_compared == expected_count, (
      f"Compared {self.number_of_compared}, expected {expected_count}")
    assert not self.expected, f"{len(self.expected)} vectors were not observed"
    assert self.number_of_failed == 0, f"{self.number_of_failed} vector mismatches"


class VecEnv:
  def __init__(self, dut, clk0_period_ns: float, clk1_period_ns: float):
    self.dut = dut
    self.clk0_period_ns = clk0_period_ns
    self.clk1_period_ns = clk1_period_ns
    self.scoreboard = VecScoreboard(dut)

  async def start(self) -> None:
    cocotb.start_soon(Clock(self.dut.clk0, self.clk0_period_ns, unit="ns").start())
    cocotb.start_soon(Clock(self.dut.clk1, self.clk1_period_ns, unit="ns").start())
    cocotb.start_soon(self._monitor_dst())

    self.dut.rst0_n.value = 0
    self.dut.rst1_n.value = 0
    self.dut.src_vector.value = 0
    self.dut.src_valid.value = 0
    self.dut.dst_ready.value = 1

    for _ in range(8):
      await RisingEdge(self.dut.clk0)
    for _ in range(8):
      await RisingEdge(self.dut.clk1)
    self.dut.rst0_n.value = 1
    self.dut.rst1_n.value = 1
    await RisingEdge(self.dut.clk0)
    await RisingEdge(self.dut.clk1)

  async def send_counter_bursts(self, bursts: int, burst_len: int) -> int:
    count = bursts * burst_len
    for idx in range(count):
      last = 1 if ((idx + 1) % burst_len) == 0 else 0
      value = ((last << 24) | (idx & ((1 << 24) - 1))) & MASK
      self.scoreboard.expect(value)

      while True:
        await RisingEdge(self.dut.clk0)
        if self.dut.src_ready.value == 1:
          self.dut.src_vector.value = value
          self.dut.src_valid.value = 1
          break
      await RisingEdge(self.dut.clk0)
      self.dut.src_valid.value = 0
    return count

  async def wait_for_compares(self, count: int, timeout_clk0_cycles: int) -> None:
    for _ in range(timeout_clk0_cycles):
      if self.scoreboard.number_of_compared >= count:
        return
      await RisingEdge(self.dut.clk0)
    raise AssertionError(
      f"Timed out waiting for {count} vectors, got {self.scoreboard.number_of_compared}")

  async def _monitor_dst(self) -> None:
    while True:
      await RisingEdge(self.dut.clk0)
      if self.dut.rst0_n.value != 1:
        continue
      if self.dut.dst_valid.value == 1 and self.dut.dst_ready.value == 1:
        self.scoreboard.observe(int(self.dut.dst_vector.value))
