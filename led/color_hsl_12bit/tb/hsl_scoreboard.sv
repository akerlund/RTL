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

`uvm_analysis_imp_decl(_collected_port_mst0)
`uvm_analysis_imp_decl(_collected_port_slv0)

class hsl_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(hsl_scoreboard)

  uvm_analysis_imp_collected_port_mst0 #(vip_axi4s_item #(vip_axi4s_cfg), hsl_scoreboard) collected_port_mst0;
  uvm_analysis_imp_collected_port_slv0 #(vip_axi4s_item #(vip_axi4s_cfg), hsl_scoreboard) collected_port_slv0;

  // Storage for comparison
  vip_axi4s_item #(vip_axi4s_cfg) master_items [$];
  vip_axi4s_item #(vip_axi4s_cfg) slave_items  [$];

  // Debug storage
  vip_axi4s_item #(vip_axi4s_cfg) all_master_items [$];
  vip_axi4s_item #(vip_axi4s_cfg) all_slave_items  [$];


  // For raising objections
  uvm_phase current_phase;

  int number_of_master_items;
  int number_of_slave_items;

  int number_of_compared;
  int number_of_passed;
  int number_of_failed;



  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    collected_port_mst0 = new("collected_port_mst0", this);
    collected_port_slv0 = new("collected_port_slv0", this);

  endfunction



  function void connect_phase(uvm_phase phase);

    current_phase = phase;
    super.connect_phase(current_phase);

  endfunction



  virtual task run_phase(uvm_phase phase);

    current_phase = phase;
    super.run_phase(current_phase);

  endtask



  function void check_phase(uvm_phase phase);

    current_phase = phase;
    super.check_phase(current_phase);

    if (master_items.size() > 0) begin
      `uvm_error(get_name(), $sformatf("There are still items in the Master queue"))
    end

    if (slave_items.size() > 0) begin
      `uvm_error(get_name(), $sformatf("There are still items in the Slave queue"))
    end

    if (number_of_failed != 0) begin
      `uvm_error(get_name(), $sformatf("Test failed! (%0d) mismatches", number_of_failed))
    end
    else begin
      `uvm_info(get_name(), $sformatf("Test passed (%0d)/(%0d) finished transfers", number_of_passed, number_of_compared), UVM_LOW)
    end

  endfunction

  //----------------------------------------------------------------------------
  // Master Agent
  //----------------------------------------------------------------------------

  virtual function void write_collected_port_mst0(vip_axi4s_item #(vip_axi4s_cfg) trans);

    number_of_master_items++;
    master_items.push_back(trans);
    all_master_items.push_back(trans);

    current_phase.raise_objection(this);

  endfunction

  //----------------------------------------------------------------------------
  // Slave Agent
  //----------------------------------------------------------------------------

  virtual function void write_collected_port_slv0(vip_axi4s_item #(vip_axi4s_cfg) trans);

    number_of_slave_items++;
    slave_items.push_back(trans);
    all_slave_items.push_back(trans);

    compare();
    current_phase.drop_objection(this);

  endfunction


  virtual function void compare();

    vip_axi4s_item #(vip_axi4s_cfg) current_master_item;
    vip_axi4s_item #(vip_axi4s_cfg) current_slave_item;

    int compare_ok = 1;

    int hue   = 0;
    int sat   = 0;
    int light = 0;

    int red_mst   = 0;
    int green_mst = 0;
    int blue_mst  = 0;

    int red_slv   = 0;
    int green_slv = 0;
    int blue_slv  = 0;


    current_master_item = master_items.pop_front();
    current_slave_item  = slave_items.pop_front();

    // Extracting the HUE values from the master and converting them to RGB
    hue   = int'(current_master_item.tdata[0][11 : 0]);
    sat   = int'(current_master_item.tdata[0][23 : 12]);
    light = int'(current_master_item.tdata[0][35 : 24]);

    void'(colorHSL(hue, sat, light, red_mst, green_mst, blue_mst));

    // Extracting the RGB values from the slave, i.e., the DUT
    red_slv   = int'(current_slave_item.tdata[0][11 : 0]);
    green_slv = int'(current_slave_item.tdata[0][23 : 12]);
    blue_slv  = int'(current_slave_item.tdata[0][35 : 24]);


    number_of_compared++;


    if (red_mst != red_slv) begin
      compare_ok = 0;
      `uvm_error(get_name(), $sformatf("Red number (%0d) mismatches: (%0d != %0d)", number_of_compared, red_mst, red_slv))
    end

    if (green_mst != green_slv) begin
      compare_ok = 0;
      `uvm_error(get_name(), $sformatf("Green number (%0d) mismatches: (%0d != %0d)", number_of_compared, green_mst, green_slv))
    end

    if (blue_mst != blue_slv) begin
      compare_ok = 0;
      `uvm_error(get_name(), $sformatf("Blue number (%0d) mismatches: (%0d != %0d)", number_of_compared, blue_mst, blue_slv))
    end


    if (compare_ok) begin
      number_of_passed++;
    end
    else begin
      number_of_failed++;
    end

  endfunction



  function automatic colorHSL(int hue, int sat, int light, ref int red, ref int green, ref int blue);

    int m  = 0;
    int tR = 0;
    int tG = 0;
    int tB = 0;

    int frac = (6*hue) >> 12;

    // Chroma
    int C = ((4095 - abs( (light << 1) - 4095)) * sat) >> 12;

    int X = (C * (4095 - abs((6*hue % 8192) - 4095))) >> 12;

    // Hue
    if (frac == 0) begin
      tR = C;
      tG = X;
      tB = 0;
    end
    else if (frac == 1) begin
      tR = X;
      tG = C;
      tB = 0;
    end
    else if (frac == 2) begin
      tR = 0;
      tG = C;
      tB = X;
    end
    else if (frac == 3) begin
      tR = 0;
      tG = X;
      tB = C;
    end
    else if (frac == 4) begin
      tR = X;
      tG = 0;
      tB = C;
    end
    else if (frac == 5) begin
      tR = C;
      tG = 0;
      tB = X;
    end

    // Lightness.
    m = light - (C>>1);
    tR += m;
    tG += m;
    tB += m;

    red   = gamma_lut_table_c[tR];
    green = gamma_lut_table_c[tG];
    blue  = gamma_lut_table_c[tB];

  endfunction

endclass
