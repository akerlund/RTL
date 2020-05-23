# Oscillator

![Build Status](https://img.shields.io/badge/build-passing-green)
![Build Status](https://img.shields.io/badge/test-N/A-lightgrey)
![Build Status](https://img.shields.io/badge/synthesis-N/A-lightgrey)
![Build Status](https://img.shields.io/badge/fpga-N/A-lightgrey)

And oscillator module which will have the following waveforms:

- Square
- Triangle
- Saw
- Sine

![Build Status](https://img.shields.io/badge/Square-Simulated-green)
![Build Status](https://img.shields.io/badge/Triangle-Simulated-green)
![Build Status](https://img.shields.io/badge/Saw-Developing-orange)
![Build Status](https://img.shields.io/badge/Sine-Simulated-green)

```python
```

## Triangle


The triangle module has the following instantiation:

```verilog
osc_triangle_top #(
  .DATA_WIDTH_P         ( 24                   ),
  .PERIOD_IN_SYS_CLKS_P ( 2000                 ),
  .COUNTER_WIDTH_P      ( 32                   )
) osc_triangle_top_i0 (
  .clk                  ( clk                  ), // input
  .rst_n                ( rst_n                ), // input
  .osc_triangle         ( wave_triangle        ), // output
  .cr_enable_period     ( '1                   )  // input
);
```

Because we have set the parameter **PERIOD_IN_SYS_CLKS_P** to 2000 we now have a fundamental frequency of the triangle module which we can slow down with the clock enable module which can be controlled with the configuration register **cr_enable_period**. The value of 2000 was derived from:


```verilog
localparam int F100000_HZ_IN_SYS_CLOCK_C = (200000000/100000); // 2000
```

The system clock is assumed to be 200MHz and the desired fundamental frequency of the triangle wave is 100kHz. The first parameter seen above holds the number of system clock periods needed to achieve the 100kHz frequency.

For example, the parameters are used in **osc_triangle_top** like this:

```verilog
// The increment value of the counter depending on the given maximum frequency
localparam int WAVE_AMPLITUDE_INC_C = (2**DATA_WIDTH_P-1) / (PERIOD_IN_SYS_CLKS_P/2);

// The max amplitude of the wave is (minimum amplitude) plus increment size times number of increments
localparam logic signed [DATA_WIDTH_P-1 : 0] WAVE_AMPLITUDE_MAX_C =
  -2**(DATA_WIDTH_P-1) + WAVE_AMPLITUDE_INC_C*PERIOD_IN_SYS_CLKS_P/2;
```

This means that the amplitude will increase by

```python
>>> (2**24-1)/(2000/2)
16777.215
```

16777 every time the clock enable is asserted. The maximum amplitude will be

```python
>>> -2**(24-1)+16777*(2000/2)
8388392.0
```

8388392 and when the triangle has reached this amplitude its amplitude will start to decrease nack to the minimum value it can have.





## Testbench

The test bench is written in UVM and use the APB3 agent located in the **vip** directory.
There will be no scoreboard written as far of as today, instead the waveforms will be verified by eye.

### tc_osc_simple_test

In progress

