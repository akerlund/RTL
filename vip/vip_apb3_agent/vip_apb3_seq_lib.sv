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

// -----------------------------------------------------------------------------
// Base Sequence
//
// Functions for:
//   - Write one word
//   - Write masked, i.e., write bits
//   - Read one word
// -----------------------------------------------------------------------------
class vip_apb3_base_seq #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_apb3_item #(vip_cfg));

  `uvm_object_param_utils(vip_apb3_base_seq #(vip_cfg))

  vip_apb3_item #(vip_cfg) apb_item;


  function new(string name = "vip_apb3_base_seq");

    super.new(name);

  endfunction



  task write_word(logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] paddr,
                  logic [vip_cfg.APB_DATA_WIDTH_P-1 : 0] pwdata,
                  int                                    psel = 0);

    apb_item = new();

    apb_item.paddr  = paddr;
    apb_item.psel   = psel;
    apb_item.pwrite = '1;
    apb_item.pwdata = pwdata;

    req = apb_item;
    start_item(req);
    finish_item(req);

  endtask



  task read_word(logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] paddr,
                 logic [vip_cfg.APB_DATA_WIDTH_P-1 : 0] prdata,
                 int                                    psel = 0);

    apb_item = new();

    apb_item.paddr  = paddr;
    apb_item.psel   = psel;
    apb_item.pwrite = APB_OP_READ_E;

    req = apb_item;
    start_item(req);
    finish_item(req);

    //get_response(rsp);
    //prdata = rsp.prdata;

  endtask



  task write_masked(logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] paddr,
                    logic [vip_cfg.APB_DATA_WIDTH_P-1 : 0] pwdata,
                    logic [vip_cfg.APB_DATA_WIDTH_P-1 : 0] mask,
                    int                                    psel = 0);

    logic [vip_cfg.APB_ADDR_WIDTH_P-1 : 0] prdata;
    read_word(paddr,  prdata, psel);
    write_word(paddr, (prdata & ~mask | pwdata), psel);

  endtask

endclass
