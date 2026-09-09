class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver);

  virtual uart_if vif;
  transaction tr;

  function new(input string path="drv",
               uvm_component parent=null);
    super.new(path, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    if (!uvm_config_db#(virtual uart_if)::get(
          this, "", "vif", vif))
      `uvm_error("drv", "unable to access interface")
  endfunction

  task reset_dut();
    repeat(5) begin
      vif.rst        <= 1'b1;
      vif.tx_start   <= 1'b0;
      vif.rx_start   <= 1'b0;
      vif.tx_data    <= 8'h00;
      vif.baud       <= 16'h0;
      vif.length     <= 4'h0;
      vif.parity_type<= 1'b0;
      vif.parity_en  <= 1'b0;
      vif.stop2      <= 1'b0;
      `uvm_info("DRV","System reset:Start of simulation",UVM_MEDIUM);
      @(posedge vif.clk);
    end
  endtask

  task drive();
    reset_dut();
    forever begin
      seq_item_port.get_next_item(tr);
      vif.rst         <= 1'b0;
      vif.tx_start    <= tr.tx_start;
      vif.rx_start    <= tr.rx_start;
      vif.tx_data     <= tr.tx_data;
      vif.baud        <= tr.baud;
      vif.length      <= tr.length;
      vif.parity_type <= tr.parity_type;
      vif.parity_en   <= tr.parity_en;
      vif.stop2       <= tr.stop2;
      `uvm_info("DRV", $sformatf("Baud:%0d LEN:%0d PAR_T:%0d PAR_EN:%0d STOP:%0d TX_DATA:%0d", tr.baud, tr.length, tr.parity_type, tr.parity_en, tr.stop2, tr.tx_data), UVM_NONE);
      @(posedge vif.clk);
      @(posedge vif.tx_done);
      @(negedge vif.rx_done);
      seq_item_port.item_done();
    end
  endtask

  virtual task run_phase(uvm_phase phase);
    drive();
  endtask
endclass
