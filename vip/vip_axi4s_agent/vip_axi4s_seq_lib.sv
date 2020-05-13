// -----------------------------------------------------------------------------
// Base Sequence
// -----------------------------------------------------------------------------
class vip_axi4s_base_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(vip_axi4s_base_seq #(vip_cfg))

  // Sequence parameters
  rand int unsigned nr_of_bursts = 1;
       int unsigned max_idle_between_bursts = 0;

  // Constraints
  constraint constraint_nr_of_bursts {
    nr_of_bursts >= 1;
    nr_of_bursts <= 4096;
  }


  function new(string name = "vip_axi4s_base_seq");

    super.new(name);

    // Calculating the max value of 'awlen' so the burst will not exceed the AXI4 boundry
    max_awlen = AXI4_BURST_BIT_BOUNDARY_C / vip_cfg.AXI_DATA_WIDTH_P;

  endfunction

endclass

// -----------------------------------------------------------------------------
// Write Random Sequence
// Randomizes item and send them. The write item's random function assures
// the write will not span through a 4k address boundary.
// -----------------------------------------------------------------------------
class axi4s_random_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0})
  extends vip_axi4s_base_seq #(vip_cfg);

  `uvm_object_param_utils(axi4s_random_seq #(vip_cfg))

  function new(string name = "axi4s_random_seq");
    super.new(name);
  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

    for (int i = 0; i < nr_of_bursts; i++) begin

      // Increasing the address by number of bytes that were written previously
      axi4s_item = new();

      void'(axi4s_item.randomize());

      req = axi4s_item;
      start_item(req);
      finish_item(req);

      #($urandom_range(0, max_idle_between_bursts));

    end

  endtask

endclass


// -----------------------------------------------------------------------------
// Counting Sequence
// Sends write data (wdata) as 0, 1, 2, ..., 3
// -----------------------------------------------------------------------------
class axi4s_counting_seq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0})
  extends vip_axi4s_base_seq #(vip_cfg);

  `uvm_object_param_utils(axi4s_counting_seq #(vip_cfg))


  function new(string name = "axi4s_counting_seq");
    super.new(name);
  endfunction


  virtual task body();

    vip_axi4s_item #(vip_cfg) axi4s_item;

  endtask

endclass
