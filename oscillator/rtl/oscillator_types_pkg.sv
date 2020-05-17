`ifndef OSCILLATOR_TYPES_PKG
`define OSCILLATOR_TYPES_PKG

package oscillator_types_pkg;

  typedef enum logic [1 : 0] {
    OSC_SQUARE_E,
    OSC_TRIANGLE_E,
    OSC_SAW_E,
    OSC_SINE_E
  } osc_waveform_type_t;

endpackage

`endif
