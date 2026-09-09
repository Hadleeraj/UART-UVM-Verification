
import uvm_pkg::*;
`include "uvm_macros.svh"

`include "uart_if.sv"
`include "uart_transaction.sv"
`include "uart_sequence.sv"
`include "uart_config.sv"
`include "uart_driver.sv"
`include "uart_monitor.sv"
`include "uart_scoreboard.sv"
`include "uart_coverage.sv" 
`include "uart_agent.sv"
`include "uart_env.sv"
`include "uart_test.sv"

module tb();
  uart_if vif();
  uart_top dut(
    .clk(vif.clk),
    .rst(vif.rst),
    .tx_start(vif.tx_start),
    .rx_start(vif.rx_start),
    .tx_data(vif.tx_data),
    .baud(vif.baud),
    .length(vif.length),
    .parity_type(vif.parity_type),
    .parity_en(vif.parity_en),
    .stop2(vif.stop2),
    .tx_done(vif.tx_done),
    .rx_done(vif.rx_done),
    .tx_err(vif.tx_err),
    .rx_err(vif.rx_err),
    .rx_out(vif.rx_out)
  );
  
  initial begin
    vif.clk <= 0;
  end
  always #10 vif.clk <= ~vif.clk;
  
  initial begin
    uvm_config_db#(virtual uart_if)::set(null, "*", "vif", vif);
    run_test("test");
  end
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
endmodule


    


