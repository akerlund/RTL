module axis_arb_mux #
(
    parameter nr_of_streams_p     = 4,                  // Number of AXI stream inputs    
    parameter data_width_p        = 8,                  // Width of AXI stream interfaces in bits    
    parameter keep_enable_p       = (data_width_p > 8), // Propagate tkeep signal    
    parameter keep_width_p        = (data_width_p / 8), // tkeep signal width (words per cycle)    
    parameter id_enable_p         = 0,                  // Propagate tid signal    
    parameter id_width_p          = 8,                  // tid signal width    
    parameter dest_enable_p       = 0,                  // Propagate tdest signal    
    parameter dest_width_p        = 8,                  // tdest signal width    
    parameter duser_enable_p      = 1,                  // Propagate tuser signal    
    parameter user_width_p        = 1,                  // tuser signal width    
    parameter arbiter_type_p      = "PRIORITY",         // arbitration type: "PRIORITY" or "ROUND_ROBIN"    
    parameter lsb_priority_type_p = "HIGH"              // LSB priority: "LOW", "HIGH"    
  )(
    input  wire                                     clk,
    input  wire                                     rst_n,

    input  wire  [nr_of_streams_p*data_width_p-1:0] s_axis_tdata,
    input  wire  [nr_of_streams_p*keep_width_p-1:0] s_axis_tkeep,
    input  wire               [nr_of_streams_p-1:0] s_axis_tvalid,
    output logic              [nr_of_streams_p-1:0] s_axis_tready,
    input  wire               [nr_of_streams_p-1:0] s_axis_tlast,
    input  wire    [nr_of_streams_p*id_width_p-1:0] s_axis_tid,
    input  wire  [nr_of_streams_p*dest_width_p-1:0] s_axis_tdest,
    input  wire  [nr_of_streams_p*user_width_p-1:0] s_axis_tuser,

    output logic [data_width_p-1:0]                 m_axis_tdata,
    output logic [keep_width_p-1:0]                 m_axis_tkeep,
    output logic                                    m_axis_tvalid,
    input  wire                                     m_axis_tready,
    output logic                                    m_axis_tlast,
    output logic [id_width_p-1:0]                   m_axis_tid,
    output logic [dest_width_p-1:0]                 m_axis_tdest,
    output logic [user_width_p-1:0]                 m_axis_tuser
);

  localparam int cl_nr_of_streams_c = $clog2(nr_of_streams_p);


  // MUX for incoming packet
  logic [data_width_p-1:0] current_s_tdata;
  logic [keep_width_p-1:0] current_s_tkeep;
  logic                    current_s_tvalid;
  logic                    current_s_tready;
  logic                    current_s_tlast;
  logic   [id_width_p-1:0] current_s_tid;
  logic [dest_width_p-1:0] current_s_tdest;
  logic [user_width_p-1:0] current_s_tuser;

  assign current_s_tdata  = s_axis_tdata[grant_encoded*data_width_p +: data_width_p];
  assign current_s_tkeep  = s_axis_tkeep[grant_encoded*keep_width_p +: keep_width_p];
  assign current_s_tvalid = s_axis_tvalid[grant_encoded];
  assign current_s_tready = s_axis_tready[grant_encoded];
  assign current_s_tlast  = s_axis_tlast[grant_encoded];
  assign current_s_tid    = s_axis_tid[grant_encoded*id_width_p +: id_width_p];
  assign current_s_tdest  = s_axis_tdest[grant_encoded*dest_width_p +: dest_width_p];
  assign current_s_tuser  = s_axis_tuser[grant_encoded*user_width_p +: user_width_p];


  // output datapath logic
  logic [data_width_p-1:0] m_axis_tdata_reg;
  logic [keep_width_p-1:0] m_axis_tkeep_reg;
  logic                    m_axis_tvalid_reg;
  logic                    m_axis_tlast_reg;
  logic [id_width_p-1:0]   m_axis_tid_reg;
  logic [dest_width_p-1:0] m_axis_tdest_reg;
  logic [user_width_p-1:0] m_axis_tuser_reg;

  // Arbiter signals
  logic    [nr_of_streams_p-1:0] request;
  logic    [nr_of_streams_p-1:0] acknowledge;
  logic    [nr_of_streams_p-1:0] grant;
  logic                          grant_valid;
  logic [cl_nr_of_streams_c-1:0] grant_encoded;


  assign request     = s_axis_tvalid & ~grant;
  assign acknowledge = grant & s_axis_tvalid & s_axis_tready & s_axis_tlast;


  // internal datapath
  logic                    m_axis_tvalid_int;
  logic                    m_axis_tready_int_reg = 1'b0;
  logic                    m_axis_tready_int_early;



  logic [data_width_p-1:0] temp_m_axis_tdata_reg;
  logic [keep_width_p-1:0] temp_m_axis_tkeep_reg;
  logic                    temp_m_axis_tvalid_reg;
  logic                    temp_m_axis_tlast_reg;
  logic [id_width_p-1:0]   temp_m_axis_tid_reg;
  logic [dest_width_p-1:0] temp_m_axis_tdest_reg;
  logic [user_width_p-1:0] temp_m_axis_tuser_reg;

  // datapath control
  logic store_axis_int_to_output;
  logic store_axis_int_to_temp;
  logic store_axis_temp_to_output;




  assign m_axis_tdata  = m_axis_tdata_reg;
  assign m_axis_tkeep  = keep_enable_p ? m_axis_tkeep_reg : {keep_width_p{1'b1}};
  assign m_axis_tvalid = m_axis_tvalid_reg;
  assign m_axis_tlast  = m_axis_tlast_reg;
  assign m_axis_tid    = id_enable_p   ? m_axis_tid_reg   : {id_width_p{1'b0}};
  assign m_axis_tdest  = dest_enable_p ? m_axis_tdest_reg : {dest_width_p{1'b0}};
  assign m_axis_tuser  = duser_enable_p ? m_axis_tuser_reg : {user_width_p{1'b0}};

  // enable ready input next cycle if output is ready or the temp reg will not be filled on the next cycle (output reg empty or no input)
  assign m_axis_tready_int_early = m_axis_tready || (!temp_m_axis_tvalid_reg && (!m_axis_tvalid_reg || !m_axis_tvalid_int));
  assign s_axis_tready           = (m_axis_tready_int_reg && grant_valid) << grant_encoded;



  assign m_axis_tvalid_int = current_s_tvalid && m_axis_tready_int_reg && grant_valid;

  // arbiter instance
  arbiter #(
    .nr_of_ports_p       ( nr_of_streams_p     ),
    .arbiter_type_p      ( arbiter_type_p      ),
    .block_type_p        ( "ACKNOWLEDGE"       ),
    .lsb_priority_type_p ( lsb_priority_type_p )
  ) arbiter_i0 (
    .clk                 ( clk                 ),
    .rst_n               ( rst_n               ),
    .request             ( request             ),
    .acknowledge         ( acknowledge         ),
    .grant               ( grant               ),
    .grant_valid         ( grant_valid         ),
    .grant_encoded       ( grant_encoded       )
  );


  always_comb begin
    // transfer sink ready state to source
    m_axis_tvalid_next        <= m_axis_tvalid_reg;
    temp_m_axis_tvalid_next   <= temp_m_axis_tvalid_reg;
    store_axis_int_to_output  <= 1'b0;
    store_axis_int_to_temp    <= 1'b0;
    store_axis_temp_to_output <= 1'b0;

    if (m_axis_tready_int_reg) begin
      // input is ready
      if (m_axis_tready || !m_axis_tvalid_reg) begin
        // output is ready or currently not valid, transfer data to output
        m_axis_tvalid_next       <= m_axis_tvalid_int;
        store_axis_int_to_output <= 1'b1;
      end
      else begin
        // output is not ready, store input in temp
        temp_m_axis_tvalid_next <= m_axis_tvalid_int;
        store_axis_int_to_temp  <= 1'b1;
      end
    end
    else if (m_axis_tready) begin
      // input is not ready, but output is ready
      m_axis_tvalid_next        <= temp_m_axis_tvalid_reg;
      temp_m_axis_tvalid_next   <= 1'b0;
      store_axis_temp_to_output <= 1'b1;
    end
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      m_axis_tready_int_reg  <= '0;
      temp_m_axis_tvalid_reg <= '0;

      m_axis_tdata_reg  <= '0;
      m_axis_tkeep_reg  <= '0;
      m_axis_tvalid_reg <= '0;
      m_axis_tlast_reg  <= '0;
      m_axis_tid_reg    <= '0;
      m_axis_tdest_reg  <= '0;
      m_axis_tuser_reg  <= '0;

      temp_m_axis_tdata_reg  <= '0;
      temp_m_axis_tkeep_reg  <= '0;
      temp_m_axis_tvalid_reg <= {1'b0, temp_m_axis_tvalid_next};
      temp_m_axis_tlast_reg  <= '0;
      temp_m_axis_tid_reg    <= '0;
      temp_m_axis_tdest_reg  <= '0;
      temp_m_axis_tuser_reg  <= '0;
    end 
    else begin

      m_axis_tvalid_reg      <= m_axis_tvalid_next;
      m_axis_tready_int_reg  <= m_axis_tready_int_early;
      temp_m_axis_tvalid_reg <= temp_m_axis_tvalid_next;

      // datapath
      if (store_axis_int_to_output) begin
        m_axis_tdata_reg <= current_s_tdata;
        m_axis_tkeep_reg <= current_s_tkeep;
        m_axis_tlast_reg <= current_s_tlast;
        m_axis_tid_reg   <= current_s_tid;
        m_axis_tdest_reg <= current_s_tdest;
        m_axis_tuser_reg <= current_s_tuser;
      end
      else if (store_axis_temp_to_output) begin
        m_axis_tdata_reg <= temp_m_axis_tdata_reg;
        m_axis_tkeep_reg <= temp_m_axis_tkeep_reg;
        m_axis_tlast_reg <= temp_m_axis_tlast_reg;
        m_axis_tid_reg   <= temp_m_axis_tid_reg;
        m_axis_tdest_reg <= temp_m_axis_tdest_reg;
        m_axis_tuser_reg <= temp_m_axis_tuser_reg;
      end

      if (store_axis_int_to_temp) begin
        temp_m_axis_tdata_reg <= current_s_tdata;
        temp_m_axis_tkeep_reg <= current_s_tkeep;
        temp_m_axis_tlast_reg <= current_s_tlast;
        temp_m_axis_tid_reg   <= current_s_tid;
        temp_m_axis_tdest_reg <= current_s_tdest;
        temp_m_axis_tuser_reg <= current_s_tuser;
      end
    end
  end

endmodule