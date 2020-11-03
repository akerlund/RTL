class CLASS_NAME extends uvm_reg_block;

  `uvm_object_utils(CLASS_NAME)

UVM_REG_DECLARATIONS

  function new (string name = "CLASS_NAME");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction


  function void build();

UVM_BUILD

    default_map = create_map(MAP_NAME, BASE_ADDR, BUS_BIT_WIDTH, UVM_LITTLE_ENDIAN);

UVM_ADD

    lock_model();

  endfunction

endclass
