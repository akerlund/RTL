
`ifndef VIP_MATH_PKG
`define VIP_MATH_PKG

package vip_math_pkg;


  function int abs(int value);

    if (value < 0) begin
      abs = -value;
    end
    else begin
      abs = value;
    end

  endfunction


endpackage

`endif
