SIM ?= verilator
TOPLEVEL_LANG ?= verilog

VIP_ROOT := $(abspath ../../../submodules/VIP)

VERILOG_SOURCES += $(abspath ../rtl/axi4s_m2s_arbiter.sv)
VERILOG_SOURCES += $(abspath tb/tb_top.sv)
TOPLEVEL := tb_top

PYTHONPATH := $(abspath .):$(VIP_ROOT)/vip_axi4s_agent/py:$(VIP_ROOT)/vip_gauss/py:$(PYTHONPATH)
export PYTHONPATH

MODULE := tc.tc_arb_simple_test

EXTRA_ARGS += --public-flat-rw

include $(shell cocotb-config --makefiles)/Makefile.sim
