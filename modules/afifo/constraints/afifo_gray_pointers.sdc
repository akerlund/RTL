# Constrain the Gray-coded pointer bundles so each destination domain observes a
# coherent one-bit transition. Replace the clock names with the design-level
# clock objects used by the integrating project.

set wclk_period [get_property PERIOD [get_clocks wclk]]
set rclk_period [get_property PERIOD [get_clocks rclk]]

set_max_delay -datapath_only $wclk_period \
  -from [get_pins -hierarchical *wclk_wr_gray_reg*/Q] \
  -to   [get_pins -hierarchical *rclk_wr_gray*/D]

set_bus_skew $wclk_period \
  -from [get_pins -hierarchical *wclk_wr_gray_reg*/Q] \
  -to   [get_pins -hierarchical *rclk_wr_gray*/D]

set_max_delay -datapath_only $rclk_period \
  -from [get_pins -hierarchical *rclk_rd_gray_reg*/Q] \
  -to   [get_pins -hierarchical *wclk_rd_gray*/D]

set_bus_skew $rclk_period \
  -from [get_pins -hierarchical *rclk_rd_gray_reg*/Q] \
  -to   [get_pins -hierarchical *wclk_rd_gray*/D]
