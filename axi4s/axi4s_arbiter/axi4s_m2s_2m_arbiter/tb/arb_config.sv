class arb_config extends uvm_object;

  string name;

  `uvm_object_utils_begin(arb_config);
    `uvm_field_string(name, UVM_DEFAULT)
  `uvm_object_utils_end;

  function new(string name = "arb_config");
    super.new(name);
    this.name = name;
  endfunction

endclass
