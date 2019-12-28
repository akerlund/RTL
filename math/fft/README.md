# System Verilog FFT with fixed point
This Python script can generate a SystemVerilog FFT module of any size and a
testbench to it.

Because the synthesized versions of the FFT takes up enormous amount of FPGA
logic this project has been halted. I would like to combine this FFT with a
decimation filter in order to decrease the sampling frequency and narrow the
frequency span between the FFT bins.

Another thing to implement is the inverting FFT.


# Documentation

## generate folder

### sv_fft_generator.py
This is the top file. In here you can set the size of the FFT and the test bench.
When you run it it will generate the files under rtl/ and tb/.
