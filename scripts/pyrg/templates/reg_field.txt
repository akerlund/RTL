
    // -----------------------------------------------------------------------------
    // FIELD_DESCRIPTION
    // -----------------------------------------------------------------------------
    FIELD_INSTANCE
    FIELD_NAME.configure(
      .parent(this),
      .size(FIELD_SIZE),
      .lsb_pos(FIELD_LSB_POS),
      .access(FIELD_ACCESS),
      .volatile(0),
      .reset(FIELD_RESET),
      .has_reset(FIELD_HAS_RESET),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("FIELD_NAME", 0, FIELD_SIZE);
