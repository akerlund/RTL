from __future__ import annotations

from tb.mix_model import fixed_to_float, to_signed


class MixScoreboard:
  def __init__(self, dut):
    self.dut = dut
    self.expected = []
    self.observed = []
    self.number_of_compared = 0
    self.number_of_failed = 0

  def expect(self, left: int, right: int) -> None:
    self.expected.append((left, right))

  def observe(self, left: int, right: int) -> None:
    pair = (to_signed(left), to_signed(right))
    self.observed.append(pair)

    if not self.expected:
      self.number_of_failed += 1
      self.dut._log.error("Unexpected DAC pair left=%0d right=%0d", pair[0], pair[1])
      return

    exp_left, exp_right = self.expected.pop(0)
    self.number_of_compared += 1

    if pair != (exp_left, exp_right):
      self.number_of_failed += 1
      self.dut._log.error(
        "Mixer mismatch %0d: expected L=%0d (%0.5f) R=%0d (%0.5f), got L=%0d (%0.5f) R=%0d (%0.5f)",
        self.number_of_compared,
        exp_left,
        fixed_to_float(exp_left),
        exp_right,
        fixed_to_float(exp_right),
        pair[0],
        fixed_to_float(pair[0]),
        pair[1],
        fixed_to_float(pair[1]),
      )

  def check(self) -> None:
    assert self.number_of_compared > 0, "No DAC samples were compared"
    assert not self.expected, f"{len(self.expected)} expected DAC pairs were not observed"
    assert self.number_of_failed == 0, f"{self.number_of_failed} mixer mismatches"
