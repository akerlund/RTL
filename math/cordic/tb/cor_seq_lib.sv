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

class cordic_positive_radians_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(cordic_positive_radians_seq #(vip_cfg))

  function new(string name = "cordic_positive_radians_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    for (int i = 0; i < 360; i++) begin

      // Increasing the address by number of bytes that were written previously
      axi4s_item = new();

      axi4s_item.burst_size = 1;
      void'(axi4s_item.randomize());

      axi4s_item.tdata[0] = pos_radians[i];

      req = axi4s_item;
      start_item(req);
      finish_item(req);
    end

  endtask

endclass


class cordic_negative_radians_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(cordic_negative_radians_seq #(vip_cfg))

  function new(string name = "cordic_negative_radians_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    for (int i = 0; i < 360; i++) begin

      // Increasing the address by number of bytes that were written previously
      axi4s_item = new();

      axi4s_item.burst_size = 1;
      void'(axi4s_item.randomize());

      axi4s_item.tdata[0] = neg_radians[i];

      req = axi4s_item;
      start_item(req);
      finish_item(req);
    end

  endtask

endclass
