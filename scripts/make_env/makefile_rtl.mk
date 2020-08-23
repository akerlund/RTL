# ------------------------------------------------------------------------------
# Common variables
# ------------------------------------------------------------------------------

GIT_ROOT = $(shell git rev-parse --show-toplevel)

# Set build directory to default value if not defined
RUN_DIR?=rundir

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
#VERILATOR_FLAGS += -MMD           # Generate makefile dependencies (not shown as complicates the Makefile)
VERILATOR_FLAGS += -Os -x-assign 0 # Optimize
#VERILATOR_FLAGS += -Wall          # Warn abount lint issues; may not want this on less solid designs
#VERILATOR_FLAGS += --trace        # Make waveforms
VERILATOR_FLAGS += --assert        # Check SystemVerilog assertions
#VERILATOR_FLAGS += --clk clk      # Define the clock port
#VERILATOR_FLAGS += --coverage     # Generate coverage analysis
#VERILATOR_FLAGS += --debug        # Run Verilator in debug mode
#VERILATOR_FLAGS += --gdbbt        # Add this trace to get a backtrace in gdb

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
	@echo "  synthesize      : Run Vivado's synthesis"
	@echo "  verilate        : Run Verilator"
	@echo "  list            : List the module's testcases"
	@echo "  tc_*            : Run testcase tc_*"
	@echo "  clean_verilator : Remove Verilator's files"
	@echo "  clean           : Remove RUN_DIR"
	@echo ""
	@echo "  Make variables:"
	@echo "  ------------------------------------------------------------------------------"
	@echo "  RUN_DIR         : Directory of builds and other runs"
	@echo ""

build:
	@./scripts/compile.sh $(RUN_DIR) no_tool

synthesize:
	@./scripts/compile.sh $(RUN_DIR) vivado_synthesis

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

clean_verilator:
	-rm -rf obj_dir logs *.log *.dmp *.vpd coverage.dat core
