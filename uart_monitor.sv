class mon extends uvm_monitor;
  `uvm_component_utils(mon);

  uvm_analysis_port#(transaction) send;
  transaction tr;
  virtual uart_if vif;
  
  function new(input string inst="mon", uvm_component parent=null);
    super.new(inst,parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr=transaction::type_id::create("tr");
    send = new("send", this);
    if(!uvm_config_db#(virtual uart_if)::get(this,"","vif",vif))
      `uvm_error("MON", "unable to access interface");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      if (vif.rst) begin
        tr.rst = 1'b1;
        `uvm_info("MON" ,"System reset detected", UVM_NONE);
         send.write(tr);
      end
      else begin
        @(posedge vif.tx_done);
        tr.rst = 1'b0;
        tr.tx_start = vif.tx_start;
        tr.rx_start = vif.rx_start;
        tr.tx_data = vif.tx_data;
        tr.baud = vif.baud;
        tr.length = vif.length;
        tr.parity_type = vif.parity_type;
        tr.parity_en = vif.parity_en;
        tr.stop2 = vif.stop2;
        @(negedge vif.rx_done);
        tr.rx_out = vif.rx_out;
        `uvm_info("MON", $sformatf("BAUD:%0d LEN:%0d PAR_T:%0d PAR_EN:%0d STOP:%0d TX_DATA:%0d RX_DATA:%0d", tr.baud, tr.length, tr.parity_en, tr.parity_en, tr.stop2, tr.tx_data, tr.rx_out),UVM_NONE);
        send.write(tr);
      end
    end
  endtask
endclass

  
      
      
        
        
        
          
   
