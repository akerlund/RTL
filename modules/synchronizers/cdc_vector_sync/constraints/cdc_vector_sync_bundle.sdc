# Bundled-data CDC constraint template for cdc_vector_sync.
#
# The source vector is held stable while the valid toggle crosses to the
# destination domain. Replace clock and pin patterns with the names used after
# elaboration in the integrating project.

set src_clk_period [get_property PERIOD [get_clocks clk_src]]

set_max_delay -datapath_only $src_clk_period \
  -from [get_pins -hierarchical *src_vector_d0_reg*/Q] \
  -to   [get_pins -hierarchical *egr_vector_reg*/D]

set_bus_skew $src_clk_period \
  -from [get_pins -hierarchical *src_vector_d0_reg*/Q] \
  -to   [get_pins -hierarchical *egr_vector_reg*/D]
