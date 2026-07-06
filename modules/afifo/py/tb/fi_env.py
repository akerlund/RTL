from __future__ import annotations

import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge

DATA_WIDTH = 32
FIFO_WIDTH = DATA_WIDTH + 1
MASK = (1 << DATA_WIDTH) - 1


class FiScoreboard:
  def __init__(self, dut):
    self.dut = dut
    self.expected = []
    self.number_of_compared = 0
    self.number_of_failed = 0

  def expect(self, value: int) -> None:
    self.expected.append(value)

  def observe(self, value: int) -> None:
    if not self.expected:
      self.number_of_failed += 1
      self.dut._log.error("Unexpected FIFO read 0x%x", value)
      return
    expected = self.expected.pop(0)
    self.number_of_compared += 1
    if value != expected:
      self.number_of_failed += 1
      self.dut._log.error(
        "FIFO mismatch %0d: expected 0x%x, got 0x%x",
        self.number_of_compared, expected, value)

  def check(self, expected_count: int) -> None:
    assert self.number_of_compared == expected_count, (
      f"Compared {self.number_of_compared}, expected {expected_count}")
    assert not self.expected, f"{len(self.expected)} FIFO words were not observed"
    assert self.number_of_failed == 0, f"{self.number_of_failed} FIFO mismatches"

  def clear(self) -> None:
    self.expected.clear()
    self.number_of_compared = 0
    self.number_of_failed = 0


class FiEnv:
  def __init__(self, dut, wp_period_ns: float, rp_period_ns: float):
    self.dut = dut
    self.wp_period_ns = wp_period_ns
    self.rp_period_ns = rp_period_ns
    self.scoreboard = FiScoreboard(dut)

  async def start(self, wp_release_cycles: int = 8, rp_release_cycles: int = 8) -> None:
    cocotb.start_soon(Clock(self.dut.clk_wp, self.wp_period_ns, unit="ns").start())
    cocotb.start_soon(Clock(self.dut.clk_rp, self.rp_period_ns, unit="ns").start())
    cocotb.start_soon(self._read_monitor())

    await self.reset(wp_release_cycles=wp_release_cycles, rp_release_cycles=rp_release_cycles)

  async def reset(self, wp_release_cycles: int = 8, rp_release_cycles: int = 8) -> None:
    self.dut.rst_wp_n.value = 0
    self.dut.rst_rp_n.value = 0
    self.dut.wp_write_en.value = 0
    self.dut.wp_data_in.value = 0
    self.dut.rp_read_en.value = 1
    self.scoreboard.clear()

    for _ in range(wp_release_cycles):
      await RisingEdge(self.dut.clk_wp)
    self.dut.rst_wp_n.value = 1

    for _ in range(rp_release_cycles):
      await RisingEdge(self.dut.clk_rp)
    self.dut.rst_rp_n.value = 1

    await RisingEdge(self.dut.clk_wp)
    await RisingEdge(self.dut.clk_rp)

  async def write_counter_bursts(self, bursts: int, burst_len: int) -> int:
    count = bursts * burst_len
    for idx in range(count):
      last = 1 if ((idx + 1) % burst_len) == 0 else 0
      payload = idx & MASK
      word = (last << DATA_WIDTH) | payload
      self.scoreboard.expect(word)

      while True:
        await RisingEdge(self.dut.clk_wp)
        if self.dut.wp_fifo_full.value == 0:
          self.dut.wp_data_in.value = word
          self.dut.wp_write_en.value = 1
          break
      await RisingEdge(self.dut.clk_wp)
      self.dut.wp_write_en.value = 0
    return count

  def start_random_reader(self, seed: int, min_hold_cycles: int = 1, max_hold_cycles: int = 8) -> None:
    cocotb.start_soon(self._random_read_enable(seed, min_hold_cycles, max_hold_cycles))

  async def wait_for_compares(self, count: int, timeout_rp_cycles: int) -> None:
    for _ in range(timeout_rp_cycles):
      if self.scoreboard.number_of_compared >= count:
        return
      await RisingEdge(self.dut.clk_rp)
    raise AssertionError(
      f"Timed out waiting for {count} FIFO reads, got {self.scoreboard.number_of_compared}")

  async def _read_monitor(self) -> None:
    while True:
      await RisingEdge(self.dut.clk_rp)
      if self.dut.rst_rp_n.value != 1:
        continue
      if self.dut.rp_read_en.value == 1 and self.dut.rp_fifo_empty.value == 0:
        self.scoreboard.observe(int(self.dut.rp_data_out.value))

  async def _random_read_enable(self, seed: int, min_hold_cycles: int, max_hold_cycles: int) -> None:
    rng = random.Random(seed)
    while True:
      self.dut.rp_read_en.value = rng.randint(0, 1)
      for _ in range(rng.randint(min_hold_cycles, max_hold_cycles)):
        await RisingEdge(self.dut.clk_rp)
