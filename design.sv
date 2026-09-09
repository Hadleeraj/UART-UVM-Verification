`timescale 1ns/1ps



////////////////////////////////////
// clk_gen.sv
////////////////////////////////////
`timescale 1ns/1ps

// Clock generator
module clk_gen(
  input clk, rst,
  input [16:0] baud,
  output reg tx_clk, rx_clk
);

  int rx_max = 0, tx_max = 0; 
  int rx_count = 0, tx_count = 0; 

  // Calculate limits based on 50MHz clock. 
  // Formula: tx_max = 50M / (Baud * 2)
  // Formula: rx_max = 50M / (Baud * 16 * 2)
  always @(posedge clk) begin
    if (rst) begin
      rx_max <= 0;
      tx_max <= 0;
    end
    else begin
      case (baud)
        4800   : begin rx_max <= 326; tx_max <= 5208; end
        9600   : begin rx_max <= 163; tx_max <= 2604; end
        14400  : begin rx_max <= 109; tx_max <= 1736; end
        19200  : begin rx_max <= 81;  tx_max <= 1302; end
        38400  : begin rx_max <= 41;  tx_max <= 651;  end
        57600  : begin rx_max <= 27;  tx_max <= 434;  end
        115200 : begin rx_max <= 14;  tx_max <= 217;  end
        128000 : begin rx_max <= 12;  tx_max <= 195;  end
        default: begin rx_max <= 163; tx_max <= 2604; end
      endcase
    end
  end

  //////////////// rx_clk ///////////////////////
  always @(posedge clk) begin
    if (rst) begin
      rx_count <= 0;
      rx_clk   <= 0;
    end
    else begin
      // This logic ensures exactly rx_max cycles per toggle
      if (rx_count >= rx_max - 1) begin
        rx_clk   <= ~rx_clk;
        rx_count <= 0;
      end
      else begin
        rx_count <= rx_count + 1;
      end
    end
  end

  //////////////// tx_clk ///////////////////////
  always @(posedge clk) begin
    if (rst) begin
      tx_count <= 0;
      tx_clk   <= 0;
    end
    else begin
      // This logic ensures exactly tx_max cycles per toggle
      if (tx_count >= tx_max - 1) begin
        tx_clk   <= ~tx_clk;
        tx_count <= 0;
      end
      else begin
        tx_count <= tx_count + 1;
      end
    end
  end

endmodule

////////////////////////////////////
// uart_tx.sv
////////////////////////////////////
module uart_tx(
  input tx_clk, tx_start,
  input rst,
  input [7:0] tx_data,
  input [3:0] length,
  input parity_en, parity_type,
  input stop2,
  output reg tx, tx_done, tx_err
);

  logic [7:0] tx_reg;

  logic start_b = 0;
  logic stop_b  = 1;
  logic parity_bit = 0;
  integer count = 0;

  typedef enum bit [2:0] {
    idle           = 0,
    start_bit      = 1,
    send_data      = 2,
    send_parity    = 3,
    send_first_stop = 4,
    send_sec_stop  = 5,
    done           = 6
  } state_type;

  state_type state = idle, next_state = idle;

  // FIX: Capture tx_data sequentially to prevent latches in the FSM
  always @(posedge tx_clk) begin
    if (rst) begin
      tx_reg <= 8'h00;
    end else if (state == idle && tx_start) begin
      tx_reg <= tx_data;
    end
  end

  //////////parity generator
  always @(posedge tx_clk) begin
    if (parity_type == 1'b1) begin //odd
      case (length)
        4'd5 : parity_bit =  ^(tx_data[4:0]); 
        4'd6 : parity_bit =  ^(tx_data[5:0]);
        4'd7 : parity_bit =  ^(tx_data[6:0]);
        4'd8 : parity_bit =  ^(tx_data[7:0]);
        default : parity_bit = 1'b0;
      endcase
    end
    else begin //even
      case (length)
        4'd5 : parity_bit = ~^(tx_data[4:0]); 
        4'd6 : parity_bit = ~^(tx_data[5:0]);
        4'd7 : parity_bit = ~^(tx_data[6:0]);
        4'd8 : parity_bit = ~^(tx_data[7:0]);
        default : parity_bit = 1'b0;
      endcase
    end
  end

  //////////reset detector//////////////
  always @(posedge tx_clk) begin
    if (rst)
      state <= idle;
    else
      state <= next_state;
  end

  //////next state decoder + output decoder
  always @(*) begin
    // Defaults to prevent latches
    tx_done = 1'b0;
    tx_err  = 1'b0;
    tx      = 1'b1; 
    next_state = state;

    case (state)
      idle : begin
        tx      = 1'b1;
        if (tx_start)
          next_state = start_bit;
      end
      
      start_bit : begin
        tx         = start_b;
        next_state = send_data;
      end
      
      send_data : begin
        tx = tx_reg[count];
        if (count < (length - 1)) begin
          next_state = send_data;
        end
        else if (parity_en) begin
          next_state = send_parity;
        end
        else begin
          next_state = send_first_stop;
        end
      end
      
      send_parity : begin
        tx         = parity_bit;
        next_state = send_first_stop;
      end
      
      send_first_stop : begin
        tx = stop_b;
        if (stop2)
          next_state = send_sec_stop;
        else
          next_state = done;
      end
      
      send_sec_stop : begin
        tx         = stop_b;
        next_state = done;
      end
      
      done : begin
        tx_done    = 1'b1;
        next_state = idle;
      end
      
      default : next_state = idle;
    endcase
  end

  //////////////Transmitter clock count//////////////////////////////////
  always @(posedge tx_clk) begin
    case (state)
      idle : count <= 0;
      start_bit : count <= 0;
      send_data : count <= count + 1;
      send_parity : count <= 0;
      send_first_stop : count <= 0;
      send_sec_stop : count <= 0;
      done : count <= 0;
      default : count <= 0;
    endcase
  end

endmodule

////////////////////////////////////
// uart_rx.sv
////////////////////////////////////
module uart_rx(
  input rx_clk, rx_start,
  input rst, rx,
  input [3:0] length,
  input parity_type, parity_en,
  input stop2,
  output reg [7:0] rx_out,
  output logic rx_done, rx_error
);

  logic parity = 0;
  logic [7:0] datard = 0;
  int count = 0;
  int bit_count = 0;

  typedef enum bit [2:0] {
    idle           = 0,
    start_bit      = 1,
    recv_data      = 2,
    check_parity   = 3,
    check_first_stop = 4,
    check_sec_stop = 5,
    done           = 6
  } state_type;

  state_type state = idle, next_state = idle;

  // FIX: Sequential block for data capture to eliminate combinational feedback loop (0/255 bug)
  always @(posedge rx_clk) begin
    if (rst) begin
      datard <= 8'h00;
    end else if (state == recv_data && count == 7) begin
      datard <= {rx, datard[7:1]};
    end
  end

  // FIX: Make rx_out sequential to avoid latches
  always @(posedge rx_clk) begin
    if (rst) begin
      rx_out <= 8'h00;
    end else if (state == recv_data && count == 15 && bit_count == (length - 1)) begin
      case (length)
        5 : rx_out <= datard[7:3];
        6 : rx_out <= datard[7:2];
        7 : rx_out <= datard[7:1];
        8 : rx_out <= datard[7:0];
        default : rx_out <= 8'h00;
      endcase
    end
  end

  ////////////////////////////////////
  //reset detector
  always @(posedge rx_clk) begin
    if (rst)
      state <= idle;
    else
      state <= next_state;
  end

  ///////////////////////next_state decoder + output
  always @(*) begin
    // Defaults to prevent latches
    rx_done = 1'b0;
    rx_error = 1'b0;
    next_state = state;

    case (state)
      idle : begin
        if (rx_start && !rx)
          next_state = start_bit;
      end
      
      start_bit : begin
        if (count == 7 && rx) begin 
          next_state = idle;
        end
        else if (count == 15) begin
          next_state = recv_data;
        end
      end
      
      recv_data : begin
        if (count == 15 && bit_count == (length - 1)) begin
          if (parity_type)
            parity = ^datard;
          else
            parity = ~^datard;

          if (parity_en)
            next_state = check_parity;
          else
            next_state = check_first_stop;
        end
      end
      
      check_parity : begin
        if (count == 7) begin
          if (rx == parity)
            rx_error = 1'b0;
          else
            rx_error = 1'b1;
        end
        else if (count == 15) begin
          next_state = check_first_stop;
        end
      end
      
      check_first_stop : begin
        if (count == 7) begin
          if (rx != 1'b1)
            rx_error = 1'b1;
          else
            rx_error = 1'b0;
        end
        else if (count == 15) begin
          if (stop2)
            next_state = check_sec_stop;
          else
            next_state = done;
        end
      end
      
      check_sec_stop : begin
        if (count == 7) begin
          if (rx != 1'b1)
            rx_error = 1'b1;
          else
            rx_error = 1'b0;
        end
        else if (count == 15) begin
          next_state = done;
        end
      end
      
      done : begin
        rx_done    = 1'b1;
        next_state = idle;
      end
      
    endcase
  end

  ////////////////////////////////////
  // rx count
  always @(posedge rx_clk) begin
    case (state)
      idle : begin
        count     <= 0;
        bit_count <= 0;
      end
      
      start_bit : begin
        if (count < 15) count <= count + 1;
        else count <= 0;
      end
      
      recv_data : begin
        if (count < 15) count <= count + 1;
        else begin
          count     <= 0;
          bit_count <= bit_count + 1;
        end
      end
      
      check_parity : begin
        if (count < 15) count <= count + 1;
        else count <= 0;
      end
      
      check_first_stop : begin
        if (count < 15) count <= count + 1;
        else count <= 0;
      end
      
      check_sec_stop : begin
        if (count < 15) count <= count + 1;
        else count <= 0;
      end
      
      done : begin
        count     <= 0;
        bit_count <= 0;
      end
    endcase
  end

endmodule

//////////////////////////////////////
// uart_top.sv
//////////////////////////////////////
module uart_top(
  input clk, rst,
  input tx_start, rx_start,
  input [7:0] tx_data,
  input [16:0] baud,
  input [3:0] length,
  input parity_en, parity_type,
  input stop2,
  output tx_done, rx_done, tx_err, rx_err,
  output [7:0] rx_out
);

  wire tx_clk, rx_clk;
  wire tx_rx;

  clk_gen clk_dut (
    .clk(clk), 
    .rst(rst), 
    .baud(baud), 
    .tx_clk(tx_clk), 
    .rx_clk(rx_clk)
  );
  
  // FIX: Using explicit port mapping to prevent parity signal swapping
  uart_tx tx_dut (
    .tx_clk(tx_clk), 
    .tx_start(tx_start), 
    .rst(rst), 
    .tx_data(tx_data), 
    .length(length), 
    .parity_en(parity_en),      
    .parity_type(parity_type), 
    .stop2(stop2), 
    .tx(tx_rx), 
    .tx_done(tx_done), 
    .tx_err(tx_err)
  );
  
  uart_rx rx_dut (
    .rx_clk(rx_clk), 
    .rx_start(rx_start), 
    .rst(rst), 
    .rx(tx_rx), 
    .length(length), 
    .parity_type(parity_type), 
    .parity_en(parity_en), 
    .stop2(stop2), 
    .rx_out(rx_out), 
    .rx_done(rx_done), 
    .rx_error(rx_err)
  );

endmodule
