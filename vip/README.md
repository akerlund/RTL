# Verification IP (VIP)

![Test Status](https://img.shields.io/badge/test-passes-green)

## VIP for AXI4-S

Generic and parameterizable UVM Agent for stimulating DUTs with AXI4-S interfaces. Example configuration:

```verilog
// Configuration of the AXI4-S VIP
localparam vip_axi4s_cfg_t vip_axi4s_cfg = '{
  AXI_DATA_WIDTH_P : 32,
  AXI_STRB_WIDTH_P : 0,
  AXI_KEEP_WIDTH_P : 0,
  AXI_ID_WIDTH_P   : 2,
  AXI_DEST_WIDTH_P : 0,
  AXI_USER_WIDTH_P : 1
};
```

## VIP for APB3

Generic and parameterizable UVM Agent for stimulating DUTs with APB3 interfaces. Example configuration:

```verilog
// Configuration of the APB3 VIP
localparam vip_apb3_cfg_t vip_apb3_cfg = '{
  APB_ADDR_WIDTH_P : 8,
  APB_DATA_WIDTH_P : 32
};
```


## Miscellaneous

### File Functions

**vip_file_functions_pkg**

```verilog
function string    get_git_root();
function automatic read_file_to_buffer(string file_name, ref string file_buffer [$]);
```

### VIP Math

**vip_math_pkg**

```verilog
function int  abs_int(int value);
function real abs_real(real value);
```

### VIP Fixed Point

**vip_fixed_point_pkg**


```verilog
function int  float_to_fixed_point(real float_number, int q);
function real fixed_point_to_float(int fixed_point, int n, int q);
function real get_max_fixed_point(int n, int q);
function real get_min_fixed_point(int n);
```
