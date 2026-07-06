from __future__ import annotations

from dataclasses import dataclass


@dataclass
class IirRegisterModel:
  f0: int = 0
  fs: int = 0
  q: int = 0
  iir_type: int = 0
  bypass: int = 0

  def write(self, dut) -> None:
    dut.cr_iir_f0.value = self.f0
    dut.cr_iir_fs.value = self.fs
    dut.cr_iir_q.value = self.q
    dut.cr_iir_type.value = self.iir_type
    dut.cr_bypass.value = self.bypass

  def configure(self, f0: int, fs: int, q: int, iir_type: int, bypass: int) -> None:
    self.f0 = f0
    self.fs = fs
    self.q = q
    self.iir_type = iir_type
    self.bypass = bypass
