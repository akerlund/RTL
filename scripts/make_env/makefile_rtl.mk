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

# Create list of available testcases for module
TC_LIST=$(patsubst %.sv,%,$(shell find ./tc -name tc_*.sv -printf "%f " 2> /dev/null))

# ------------------------------------------------------------------------------
# Verilator variables
# ------------------------------------------------------------------------------

# If $VERILATOR_ROOT isn't in the environment, we assume it is part of a package
# install, and verilator is in your path. Otherwise find the binary relative to
# $VERILATOR_ROOT (such as when inside the git sources).
ifeq ($(VERILATOR_ROOT),)
  VERILATOR          = verilator
  VERILATOR_COVERAGE = verilator_coverage
else
  export VERILATOR_ROOT
  VERILATOR          = $(VERILATOR_ROOT)/bin/verilator
  VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
endif

# Common flags
VERILATOR_FLAGS =
VERILATOR_FLAGS += -cc --exe       # Generate C++ in executable form
VERILATOR_FLAGS += -Os -x-assign 0 # Optimize
VERILATOR_FLAGS += -Wall           # Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -sv             # Enable SystemVerilog parsing
VERILATOR_FLAGS += --assert        # Check SystemVerilog assertions
VERILATOR_FLAGS += --lint-only     # Lint, but do not make output
VERILATOR_FLAGS += --stats
VERILATOR_FLAGS += -Wno-fatal      # Disable fatal exit on warnings

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

build:
	@./scripts/compile.sh $(RUN_DIR) no_tool

synth:
	@./scripts/compile.sh $(RUN_DIR) vivado 0 $(VIV_OOC)

place:
	@./scripts/compile.sh $(RUN_DIR) vivado 1 $(VIV_OOC)

route:
	@./scripts/compile.sh $(RUN_DIR) vivado 2 $(VIV_OOC)

verilate:
ifneq ($(words $(CURDIR)),1)
  $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif
	@./scripts/compile.sh $(RUN_DIR) verilator

list:
	@echo "List of testcases:"
	@for tc in $(TC_LIST); do echo " $$tc"; done

$(TC_LIST): tc_%: ${BUILD_DIR}
	@echo "Will add the TC's later"

clean:
	@echo "Removing ${RUN_DIR}"
	@rm -rf ${RUN_DIR}

