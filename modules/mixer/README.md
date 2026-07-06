# Mixer

Multi-channel fixed-point audio mixer with per-channel gain, routing control,
and output gain.

FuseSoC core name: `akerlund::mixer:0`

## Parameters

| Parameter | Default | Description |
|---|---:|---|
| `AUDIO_WIDTH_P` | 24 | Audio sample width |
| `GAIN_WIDTH_P` | 24 | Gain/control register width |
| `NR_OF_CHANNELS_P` | 4 | Number of input channels |
| `Q_BITS_P` | 7 | Fractional bits in the fixed-point format |

## Verification

The original UVM testbench lives under `sv/`. The cocotb port lives under
`py/` and drives the mixer data/control interface directly with a Python
fixed-point reference model.

| Test | Description |
|---|---|
| `tc_positive_signals` | Deterministic positive fixed-point samples and gains |
| `tc_random_signals` | Randomized samples and gains with stable output routing |

Run the cocotb tests from this module directory:

```sh
refuse cocotb -t tc_positive_signals
refuse cocotb -t tc_random_signals
```
