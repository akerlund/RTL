import cocotb


@cocotb.test()
async def tc_display(dut):
    """Port of sv/tc/tc_display.sv: no DUT interaction, just a message."""
    dut._log.info("I am display")
