ifneq ($(words $(CURDIR)),1)
  $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

default:
	@echo ""
	@echo "--------------------------------------------------------------------------------"
	@echo "INFO [mk] Verilator"
	@echo "--------------------------------------------------------------------------------"
	@echo ""

	@echo "Verilating ${TOP_FILE}"
	@echo ""
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)
	@echo ""

show-config:
	$(VERILATOR) -V

clean:
	-rm -rf obj_dir logs *.log *.dmp *.vpd coverage.dat core
