modulea i2c_master #(

    parameter int input_clk, //input clock speed from user logic in Hz
    parameter int bus_clk   //speed the i2c bus (scl) will run at in Hz
  )(
    input  wire        clk,       // system clock
    input  wire        reset_n,   // active low reset
    input  wire        ena,       // latch in command
    input  wire  [6:0] addr,      // address of target slave
    input  wire        rw,        // '0 is write, '1' is read
    input  wire  [7:0] data_wr,   // data to write to slave
    output logic       busy,      // indicates transaction in progress
    output logic [7:0] data_rd,   // data read from slave
    output logic       ack_error, // flag if improper acknowledge from slave
    inout  logic       sda,       // serial data output of i2c bus
    inout  logic       scl        // serial clock output of i2c bus
//    ack_error : BUFFER STD_LOGIC;                    //flag if improper acknowledge from slave
//    sda       : INOUT  STD_LOGIC;                    //serial data output of i2c bus
//    scl       : INOUT  STD_LOGIC);                   //serial clock output of i2c bus
  );

  localparam int divider_c = (input_clk / bus_clk) / 4; //number of clocks in 1/4 cycle of scl

  typedef enum {
    ready, start, command, slv_ack1, wr, rd, slv_ack2, mstr_ack, stop
  } state_t;

  state_t     state;

  logic       data_clk;      // : STD_LOGIC;                      // data clock for sda
  logic       data_clk_prev; // : STD_LOGIC;                      // data clock during previous system clock
  logic       scl_clk;       // : STD_LOGIC;                      // constantly running internal scl
  logic       scl_ena;       // : STD_LOGIC := '0;                // enables internal scl to output
  logic       sda_int;       // : STD_LOGIC := '1';               // internal sda
  logic       sda_ena_n;     // : STD_LOGIC;                      // enables internal sda to output
  logic [7:0] addr_rw;       // : STD_LOGIC_VECTOR(7 DOWNTO 0);   // latched in address and read/write
  logic [7:0] data_tx;       // : STD_LOGIC_VECTOR(7 DOWNTO 0);   // latched in data to write to slave
  logic [7:0] data_rx;       // : STD_LOGIC_VECTOR(7 DOWNTO 0);   // data received from slave
  int         bit_cnt;       // : INTEGER RANGE 0 TO 7 := 7;      // tracks bit number in transaction
  logic       stretch;       // : STD_LOGIC := '0;                // identifies if slave is stretching scl



  //set sda output
  assign sda_ena_n = (state == start) ? data_clk_prev :
                     (state == stop)  ? ~data_clk_prev : sda_int;

  //set scl and sda outputs
  assign scl = (scl_ena && !scl_clk) ? '0 : 1'bz;
  assign sda = !sda_ena_n ? '1 : 1'bz;

  always_ff @(posedge clk or negedge rst_n) begin

    int unsigned count_v;

    if (!rst_n) begin
      count_v <= '0;
      stretch <= '0;
    end
    else begin

      data_clk_prev <= data_clk;               // store previous value of data clock

      if (count_v == divider_c*4-1) begin      // end of timing cycle
        count_v = '0;                          // reset timer
      end
      else if (stretch == '0) begin            // clock stretching from slave not detected
        count_v = count_v + 1;                 // continue clock generation timing
      end

      if (count_v <= divider_c-1) begin        // First 1/4 cycle of clocking
        scl_clk  <= '0;
        data_clk <= '0;
      end
      else if (count_v <= 2*divider_c-1) begin // Second 1/4 cycle of clocking
        scl_clk  <= '0;
        data_clk <= 1;
      end
      else if (count_v <= 3*divider_c-1) begin // Third 1/4 cycle of clocking
        scl_clk  <= 1;                         // release scl
        data_clk <= 1;
        if (scl == '0) begin                   // detect if slave is stretching clock
          stretch <= 1;
        end
        else begin
          stretch <= '0;
        end
      end
      else begin                               // last 1/4 cycle of clocking
        scl_clk  <= 1;
        data_clk <= '0;
      end

    end
  end


  // state machine and writing to sda during scl low (data_clk rising edge)
  always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
      state     <= ready;                               // return to initial state
      busy      <= '1';                                 // indicate not available
      scl_ena   <= '0;                                  // sets scl high impedance
      sda_int   <= '1';                                 // sets sda high impedance
      ack_error <= '0;                                  // clear acknowledge error flag
      bit_cnt   <= 7;                                   // restarts data bit counter
      data_rd   <= "00000000";                          // clear data read port
    end
    else begin

      if (data_clk && !data_clk_prev) begin             // data clock rising edge

        case (state)
          ready: begin                                  // idle state
            if (ena) begin                              // transaction requested
              busy    <= 1;                             // flag busy
              addr_rw <= addr & rw;                     // collect requested slave address and command
              data_tx <= data_wr;                       // collect requested data to write
              state   <= start;                         // go to start bit
            end
            else begin                                  // remain idle
              busy    <= '0;                            // unflag busy
              state   <= ready;                         // remain idle
            end
          end

          start: begin                                  // start bit of transaction
            busy <= '1';                                // resume busy if continuous mode
            sda_int <= addr_rw[bit_cnt];                // set first address bit to bus
            state <= command;                           // go to command
          end

          command: begin                                // address and command byte of transaction
            if(bit_cnt == 0) begin                      // command transmit finished
              sda_int <= 1;                             // release sda for slave acknowledge
              bit_cnt <= 7;                             // reset bit counter for "byte" states
              state   <= slv_ack1;                      // go to slave acknowledge (command)
            end
            else begin                                  // next clock cycle of command state
              bit_cnt <= bit_cnt - 1;                   // keep track of transaction bits
              sda_int <= addr_rw[bit_cnt-1];            // write address/command bit to bus
              state   <= command;                       // continue with command
            end
          end

          slv_ack1: begin                               // slave acknowledge bit (command)
            if( !addr_rw[0] ) begin                     // write command
              sda_int <= data_tx[bit_cnt];              // write first bit of data
              state   <= wr;                            // go to write byte
            end
            else begin                                  // read command
              sda_int <= 1;                             // release sda from incoming data
              state   <= rd;                            // go to read byte
            end
          end

          wr: begin                                     // write byte of transaction
            busy <= 1;                                  // resume busy if continuous mode
            if ( bit_cnt == '0) begin                   // write byte transmit finished
              sda_int <= 1;                             // release sda for slave acknowledge
              bit_cnt <= 7;                             // reset bit counter for "byte" states
              state <= slv_ack2;                        // go to slave acknowledge (write)
            end
            else begin                                  // next clock cycle of write state
              bit_cnt <= bit_cnt - 1;                   // keep track of transaction bits
              sda_int <= data_tx[bit_cnt-1];            // write next bit to bus
              state   <= wr;                            // continue writing
            end

          rd: begin                                     // read byte of transaction
            busy <= 1;                                  // resume busy if continuous mode
            if (bit_cnt == 0) begin                     // read byte receive finished
              if (ena && (addr_rw == addr & rw)) begin  // continuing with another read at same address
                sda_int <= '0;                          // acknowledge the byte has been received
              end
              else begin                                // stopping or continuing with a write
                sda_int <= 1;                           // send a no-acknowledge (before stop or repeated start)
              end
              bit_cnt <= 7;                             // reset bit counter for "byte" states
              data_rd <= data_rx;                       // output received data
              state   <= mstr_ack;                       // go to master acknowledge
            end
            else begin                                  // next clock cycle of read state
              bit_cnt <= bit_cnt - 1;                   // keep track of transaction bits
              state <= rd;                              // continue reading
            end
          end

          slv_ack2: begin                               // slave acknowledge bit (write)
            if (ena) begin                              // continue transaction
              busy     <= '0;                           // continue is accepted
              addr_rw <= addr & rw;                     // collect requested slave address and command
              data_tx <= data_wr;                       // collect requested data to write
              if ((addr_rw == addr) && rw) begin        // continue transaction with another write
                sda_int <= data_wr[bit_cnt];            // write first bit of data
                state   <= wr;                          // go to write byte
              end
              else begin                                // continue transaction with a read or new slave
                state <= start;                         // go to repeated start
              end
            end
            else begin                                  // complete transaction
              state <= stop;                            // go to stop bit
            end

          mstr_ack: begin                               // master acknowledge bit after a read
            if (ena) begin                              // continue transaction
              busy    <= '0;                            // continue is accepted and data received is available on bus
              addr_rw <= addr & rw;                     // collect requested slave address and command
              data_tx <= data_wr;                       // collect requested data to write
              if ((addr_rw == addr) && rw) begin        // continue transaction with another read
                sda_int <= 1;                           // release sda from incoming data
                state   <= rd;                          // go to read byte
              end
              else begin                                // continue transaction with a write or new slave
                state <= start;                         // repeated start
              end
            end
            else begin                                  // complete transaction
              state <= stop;                            // go to stop bit
            end
          end

          stop: begin                                   // stop bit of transaction
            busy  <= '0;                                // unflag busy
            state <= ready;                             // go to idle state
          end
        endcase
      end
      else if (!data_clk && data_clk_prev) begin        // data clock falling edge

        case (state)

          start: begin
            if(scl_ena == '0) begin                     // starting new transaction
              scl_ena   <= 1;                           // enable scl output
              ack_error <= '0;                          // reset acknowledge error output
            end
          end

          slv_ack1: begin                               // receiving slave acknowledge (command)
            if(sda != '0 || ack_error) begin            // no-acknowledge or previous no-acknowledge
              ack_error <= 1;                           // set error output if no-acknowledge
            end
          end

          rd: begin                                     // receiving slave data
            data_rx[bit_cnt] <= sda;                    // receive current slave data bit
          end

          slv_ack2: begin                               // receiving slave acknowledge (write)
            if(sda != '0 || ack_error) begin            // no-acknowledge or previous no-acknowledge
              ack_error <= 1;                           // set error output if no-acknowledge
            end
          end
          stop: begin
            scl_ena <= '0;                              // disable scl
          end

        endcase
      end
    end
  end


endmodule