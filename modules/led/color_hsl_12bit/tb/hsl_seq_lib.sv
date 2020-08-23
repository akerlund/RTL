////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

class hsl_12bit_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(hsl_12bit_seq #(vip_cfg))

  // Sequence parameters
  int unsigned nr_of_bursts = 1;


  logic [11 : 0] hue;
  logic [11 : 0] saturation;
  logic [11 : 0] lightness;

  function new(string name = "hsl_12bit_seq");

    super.new(name);

  endfunction

  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    for (int i = 0; i < nr_of_bursts; i++) begin

      `uvm_info(get_type_name(), $sformatf("Sending number (%0d)", i), UVM_LOW)

      // Increasing the address by number of bytes that were written previously
        axi4s_item = new();

        // hue        = $urandom_range(0, 2**12-1);
        // saturation = $urandom_range(0, 2**12-1);
        // lightness  = $urandom_range(0, 2**12-1);


        axi4s_item.burst_size = 1;
        axi4s_item.randomize();

        // axi4s_item.tdata[7 : 0]   = hue;
        // axi4s_item.tdata[15 : 8]  = saturation;
        // axi4s_item.tdata[23 : 16] = lightness;

        req = axi4s_item;
        start_item(req);
        finish_item(req);

    end

    `uvm_info(get_type_name(), $sformatf("All (%0d) items sent", nr_of_bursts), UVM_LOW)

  endtask

endclass
