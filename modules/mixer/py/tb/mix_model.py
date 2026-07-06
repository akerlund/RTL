from __future__ import annotations

AUDIO_WIDTH = 24
GAIN_WIDTH = 24
NR_OF_CHANNELS = 4
Q_BITS = 7
ONE = 1 << Q_BITS
AUDIO_MAX = (1 << (AUDIO_WIDTH - 1)) - 1
AUDIO_MIN = -(1 << (AUDIO_WIDTH - 1))


def mask(width: int) -> int:
  return (1 << width) - 1


def to_unsigned(value: int, width: int = AUDIO_WIDTH) -> int:
  return value & mask(width)


def to_signed(value: int, width: int = AUDIO_WIDTH) -> int:
  value &= mask(width)
  sign = 1 << (width - 1)
  return value - (1 << width) if value & sign else value


def float_to_fixed(value: float, q_bits: int = Q_BITS) -> int:
  scaled = int(abs(value) * (1 << q_bits))
  return -scaled if value < 0 else scaled


def fixed_to_float(value: int, width: int = AUDIO_WIDTH, q_bits: int = Q_BITS) -> float:
  return to_signed(value, width) / float(1 << q_bits)


def nq_mul(a: int, b: int, width: int = AUDIO_WIDTH, q_bits: int = Q_BITS) -> int:
  product = to_signed(a, width) * to_signed(b, width)
  shifted = (product & mask(2 * width)) >> q_bits
  return to_signed(shifted, width)


def clip_audio(value: int) -> int:
  return min(max(value, AUDIO_MIN), AUDIO_MAX)


def mix_sample(channel_data: list[int], channel_gain: list[int], channel_pan: list[int],
               output_gain: int) -> tuple[int, int]:
  left_sum = 0
  right_sum = 0

  for data, gain, pan in zip(channel_data, channel_gain, channel_pan):
    gained = nq_mul(data, gain)
    y_left = nq_mul(gained, pan)
    y_right = nq_mul(gained, ONE - pan)

    left_sum += y_left
    right_sum += y_right

  left_sum = clip_audio(left_sum)
  right_sum = clip_audio(right_sum)
  left = nq_mul(left_sum, output_gain)
  right = nq_mul(right_sum, output_gain)
  return to_signed(left), to_signed(right)
