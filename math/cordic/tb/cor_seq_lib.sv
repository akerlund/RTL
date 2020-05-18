////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

class cor_360_angles_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(cor_360_angles_seq #(vip_cfg))

  function new(string name = "cor_360_angles_seq");

    super.new(name);

  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    for (int i = 0; i < 360; i++) begin

      // Increasing the address by number of bytes that were written previously
      axi4s_item = new();

      axi4s_item.burst_size = 1;
      void'(axi4s_item.randomize());

      axi4s_item.tdata[0] = test_angles[i];

      req = axi4s_item;
      start_item(req);
      finish_item(req);

    end

  endtask

endclass
