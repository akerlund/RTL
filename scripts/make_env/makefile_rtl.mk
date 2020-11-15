# ------------------------------------------------------------------------------
# Common variables
# ------------------------------------------------------------------------------

MAKE_ROOT?=$(shell git rev-parse --show-toplevel)

# Defaults
RUN_DIR?=$(shell pwd)/rundir
PYRG_DIR?=$(shell pwd)/pyrg
UVM_TR_RECORD?=UVM_HIGH
UVM_VERBOSITY?=LOW
VIV_OOC?=1

# Define Vivado options
VIV_BUILD=0
VIV_SYNTH=1
VIV_ROUTE=2

# Module file list script
MODULE_FILE_LIST=./scripts/compile.sh

# Create list of available testcases for module
TC_LIST=$(patsubst %.sv,%,$(shell find ./tc -name tc_*.sv -printf "%f " 2> /dev/null))


# Tool scripts
RUN_VIVADO=$(MAKE_ROOT)/scripts/vivado/run.sh
RUN_ZYNQ=$(MAKE_ROOT)/scripts/vivado/run_zynq.sh
RUN_XSIM=$(MAKE_ROOT)/scripts/vivado/xsim.sh
RUN_VERILATOR=$(MAKE_ROOT)/scripts/verilator/run.sh
RUN_PYRG=$(MAKE_ROOT)/scripts/pyrg/pyrg.py

export

# ------------------------------------------------------------------------------
# Make targets
# ------------------------------------------------------------------------------

.PHONY: help build synth route zynq pyrg verilate clean $(TC_LIST)

help:
	@echo "  ------------------------------------------------------------------------------"
	@echo "  RTL Common Design - Make Environment"
	@echo "  ------------------------------------------------------------------------------"
	@echo ""
	@echo "  USAGE: make <target> [<make_variable>=some_value]"
	@echo ""
	@echo "  Targets:"
	@echo "  ------------------------------------------------------------------------------"
	@echo "  build    : Compile testbench with Vivado"
	@echo "  synth    : Vivado synthesis"
	@echo "  place    : Vivado synthesis and design place"
	@echo "  route    : Vivado synthesis, design place, routing and bitstream"
	@echo "  zynq     : Export a generated IP inside a block design for ZynQ"
	@echo "  pyrg     : Create register RTL with the module's register yaml file"
	@echo "  verilate : Run Verilator"
	@echo "  list     : List the module's testcases"
	@echo "  tc_*     : Run testcase tc_*"
	@echo "  clean    : Remove RUN_DIR"
	@echo ""
	@echo "  Make variables:"
	@echo "  ------------------------------------------------------------------------------"
	@echo "  RUN_DIR       : Directory of builds and other runs, default is /run"
	@echo "  UVM_VERBOSITY : Verbosity in UVM simulations"
	@echo "  VIV_OOC       : Set Vivado to run out-of-context (OOC) (default enabled)"
	@echo ""

build:
	@$(RUN_VIVADO) $(MODULE_FILE_LIST) $(RUN_DIR) $(VIV_BUILD) $(VIV_OOC)

synth:
	@$(RUN_VIVADO) $(MODULE_FILE_LIST) $(RUN_DIR) $(VIV_SYNTH) $(VIV_OOC)

route:
	@$(RUN_VIVADO) $(MODULE_FILE_LIST) $(RUN_DIR) $(VIV_ROUTE) $(VIV_OOC)

zynq:
	@$(RUN_ZYNQ) $(MAKE_ROOT) $(MODULE_FILE_LIST) $(RUN_DIR)

pyrg:
	@$(RUN_PYRG) $(PYRG_DIR)

verilate:
	@$(RUN_VERILATOR) $(MODULE_FILE_LIST) $(RUN_DIR)

list:
	@echo "List of testcases:"
	@for tc in $(TC_LIST); do echo " $$tc"; done

$(TC_LIST): tc_%: ${RUN_DIR}
	@$(RUN_XSIM) $(RUN_DIR) $(@) $(UVM_VERBOSITY)

clean:
	@echo "Removing ${RUN_DIR}"
	@rm -rf ${RUN_DIR}
