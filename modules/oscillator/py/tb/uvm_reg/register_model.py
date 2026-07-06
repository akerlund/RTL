from __future__ import annotations

from dataclasses import dataclass

Q_BITS = 11


def fixed(value: int) -> int:
  return value << Q_BITS


@dataclass
class OscRegisterModel:
  waveform_select: int = 0
  frequency: int = fixed(500)
  duty_cycle: int = 500

  def write(self, dut) -> None:
    dut.cr_waveform_select.value = self.waveform_select
    dut.cr_frequency.value = self.frequency
    dut.cr_duty_cycle.value = self.duty_cycle

  def configure(self, waveform: int, frequency_hz: int, duty: int) -> None:
    self.waveform_select = waveform
    self.frequency = fixed(frequency_hz)
    self.duty_cycle = duty
