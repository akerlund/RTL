SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(shell pwd)/../rtl/dummy.sv
VERILOG_SOURCES += $(shell pwd)/tb/tb_top.sv
TOPLEVEL := tb_top

MODULE := tc.tc_display

include $(shell cocotb-config --makefiles)/Makefile.sim
