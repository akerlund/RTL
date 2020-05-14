package vip_axi4s_types_pkg;

  typedef enum {
    VIP_AXI4S_MASTER_AGENT_E,
    VIP_AXI4S_SLAVE_AGENT_E
  } vip_axi4s_agent_type_t;

  typedef struct packed {
    int AXI_DATA_WIDTH_P;
    int AXI_STRB_WIDTH_P;
    int AXI_KEEP_WIDTH_P;
    int AXI_ID_WIDTH_P;
    int AXI_DEST_WIDTH_P;
    int AXI_USER_WIDTH_P;
  } vip_axi4s_cfg_t;

endpackage