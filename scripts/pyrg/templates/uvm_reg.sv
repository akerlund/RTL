// -----------------------------------------------------------------------------
// CLASS_DESCRIPTION
// -----------------------------------------------------------------------------
class REG_NAME extends uvm_reg;

  `uvm_object_utils(REG_NAME)

UVM_FIELD_DECLARATIONS

  function new (string name = "REG_NAME");
    super.new(name, UVM_REG_SIZE, UVM_NO_COVERAGE);
  endfunction


  function void build();

UVM_BUILD
  endfunction

endclass

