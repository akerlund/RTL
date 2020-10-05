# ------------------------------------------------------------------------------
# Common variables
# ------------------------------------------------------------------------------

GIT_ROOT = $(shell git rev-parse --show-toplevel)

# Set build directory to default value if not defined
RUN_DIR?=$(shell pwd)/rundir

# Set Vivado to run out-of-context (OOC)
VIV_OOC?=1

# Default UVM parameters
UVM_TR_RECORD?=UVM_HIGH
UVM_VERBOSITY?=LOW

# Module file list script
MODULE_FILE_LIST=./scripts/compile.sh

# Create list of available testcases for module
TC_LIST=$(patsubst %.sv,%,$(shell find ./tc -name tc_*.sv -printf "%f " 2> /dev/null))

# Set default UVM parameter defaults
UVM_VERBOSITY ?= LOW
SIMV_FLAGS    += +UVM_TESTNAME=$@ +UVM_TR_RECORD +UVM_VERBOSITY=$(UVM_VERBOSITY)

# Tool scripts
RUN_VIVADO=$(GIT_ROOT)/scripts/vivado/run.sh
RUN_VERILATOR=$(GIT_ROOT)/scripts/verilator/run.sh

export

# ------------------------------------------------------------------------------
# Make targets
# ------------------------------------------------------------------------------

.PHONY: help build synthesize verilate clean clean_verilator $(TC_LIST)

help:
	@echo "  ------------------------------------------------------------------------------"
	@echo "  RTL Common Design - Make Environment"
	@echo "  ------------------------------------------------------------------------------"
	@echo ""
	@echo "  USAGE: make <target> [<make_variable>=some_value]"
	@echo ""
	@echo "  Targets:"
	@echo "  ------------------------------------------------------------------------------"
	@echo "  synth    : Vivado synthesis"
	@echo "  place    : Vivado synthesis and design place"
	@echo "  route    : Vivado synthesis, design place, routing and bitstream"
	@echo "  verilate : Run Verilator"
	@echo "  list     : List the module's testcases"
	@echo "  tc_*     : Run testcase tc_*"
	@echo "  clean    : Remove RUN_DIR"
	@echo ""
	@echo "  Make variables:"
	@echo "  ------------------------------------------------------------------------------"
	@echo "  RUN_DIR  : Directory of builds and other runs"
	@echo "  VIV_OOC  : Set Vivado to run out-of-context (OOC) (default enabled)"
	@echo ""

synth:
	$(RUN_VIVADO) $(MODULE_FILE_LIST) $(RUN_DIR) 0 $(VIV_OOC)

place:
	@$(RUN_VIVADO) $(MODULE_FILE_LIST) $(RUN_DIR) 1 $(VIV_OOC)

route:
	@$(RUN_VIVADO) $(MODULE_FILE_LIST) $(RUN_DIR) 2 $(VIV_OOC)

verilate:
	@$(RUN_VERILATOR) $(MODULE_FILE_LIST) $(RUN_DIR)

list:
	@echo "List of testcases:"
	@for tc in $(TC_LIST); do echo " $$tc"; done

$(TC_LIST): tc_%: ${BUILD_DIR}
	@echo "Will add the TC's later"

clean:
	@echo "Removing ${RUN_DIR}"
	@rm -rf ${RUN_DIR}
