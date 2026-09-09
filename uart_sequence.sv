// SEQUENCE 1: Random baud, length=8, parity ON, 1 stop(no stop)

class rand_baud extends uvm_sequence#(transaction);
  `uvm_object_utils(rand_baud)
  
  transaction tr;
  
  function new(string name ="rand_baud");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
      begin
        tr = transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize);
        tr.op = rand_baud_1_stop;
        tr.length = 8;
        tr.baud = 9600;
        tr.rst = 1'b0;
        tr.tx_start = 1'b1;
        tr.rx_start = 1'b1;
        tr.parity_en = 1'b1;
        tr.stop2 = 1'b0;
        finish_item(tr);
      end
  endtask
endclass
// SEQUENCE 2: Random baud, length=8, parity ON, 2 stop

class random_baud_with_stop extends uvm_sequence#(transaction);
  `uvm_object_utils(random_baud_with_stop)
  
  transaction tr;
  
  function new(string name= "random_baud_with_stop");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
    begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = rand_length_2_stop;
      tr.length = 8;
      tr.rst = 1'b0;
      tr.tx_start = 1'b1;
      tr.rx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b1;
      finish_item(tr);
    end
  endtask
endclass

// SEQUENCE 3: Length=5, variable baud, WITH parity

class random_baud_len5p extends uvm_sequence#(transaction);
  `uvm_object_utils(random_baud_len5p)
  
  transaction tr;
  
  function new(string name= "random_baud_len5p");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
    begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length5wp;
      tr.tx_data = {3'b000, tr.tx_data[7:3]};
      tr.length = 5;
      tr.rst = 1'b0;
      tr.tx_start = 1'b1;
      tr.rx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// SEQUENCE 4: Length=6, variable baud, WITH parity

class random_baud_len6p extends uvm_sequence#(transaction);
  `uvm_object_utils(random_baud_len6p)
  
  transaction tr;
  
  function new(string name= "random_baud_len6p");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
    begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length6wp;
      tr.tx_data = {2'b00, tr.tx_data[7:2]};
      tr.length = 6;
      tr.rst = 1'b0;
      tr.tx_start = 1'b1;
      tr.rx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// SEQUENCE 5: Length=7, variable baud, WITH parity

class random_baud_len7p extends uvm_sequence#(transaction);
  `uvm_object_utils(random_baud_len7p)
  
  transaction tr;
  
  function new(string name= "random_baud_len7p");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
    begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length7wp;
      tr.tx_data = {1'b0, tr.tx_data[7:1]};
      tr.length = 7;
      tr.rst = 1'b0;
      tr.tx_start = 1'b1;
      tr.rx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// SEQUENCE 6: Length=8, variable baud, WITH parity

class random_baud_len8p extends uvm_sequence#(transaction);
  `uvm_object_utils(random_baud_len8p)
  
  transaction tr;
  
  function new(string name= "random_baud_len8p");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
    begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length8wp;
      tr.tx_data = tr.tx_data[7:0];
      tr.length = 8;
      tr.rst = 1'b0;
      tr.tx_start = 1'b1;
      tr.rx_start = 1'b1;
      tr.parity_en = 1'b1;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// SEQUENCE 7: Length=5, variable baud, WITHOUT parity

class random_baud_len5 extends uvm_sequence#(transaction);
  `uvm_object_utils(random_baud_len5)
  
  transaction tr;
  
  function new(string name= "random_baud_len5");
    super.new(name);
  endfunction
  
  virtual task body();
    repeat(10)
    begin
      tr = transaction::type_id::create("tr");
      start_item(tr);
      assert(tr.randomize);
      tr.op = length5wop;
      tr.tx_data = {3'b000, tr.tx_data[7:3]};
      tr.length = 5;
      tr.rst = 1'b0;
      tr.tx_start = 1'b1;
      tr.rx_start = 1'b1;
      tr.parity_en = 1'b0;
      tr.stop2 = 1'b0;
      finish_item(tr);
    end
  endtask
endclass

// SEQUENCE 8: Length=6, variable baud, WITHOUT parity
// ──────────────────────────────────────────────────
class rand_baud_len6 extends uvm_sequence#(transaction);
  `uvm_object_utils(rand_baud_len6);
 
  transaction tr;
 
  function new(string name="rand_baud_len6");
    super.new(name);
  endfunction
 
  virtual task body();
    repeat(10)
      begin
        tr=transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize);
        tr.op=length6wop;
        tr.rst=1'b0;
        tr.length=6;
        tr.tx_data={2'b00, tr.tx_data[7:2]};
        tr.tx_start=1'b1;
        tr.rx_start=1'b1;
        tr.parity_en=1'b0;
        tr.stop2=1'b0;
        finish_item(tr);
      end
  endtask
endclass

// SEQUENCE 9: Length=7, variable baud, WITHOUT parity
// ──────────────────────────────────────────────────
class rand_baud_len7 extends uvm_sequence#(transaction);
  `uvm_object_utils(rand_baud_len7);
  transaction tr;
  function new(string name="rand_baud_len7");
    super.new(name);
  endfunction
 
  virtual task body();
    repeat(5)
      begin
        tr=transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize);
        tr.op=length7wop;
        tr.rst=1'b0;
        tr.length=7;
        tr.tx_data={1'b0, tr.tx_data[7:1]};
        tr.tx_start=1'b1;
        tr.rx_start=1'b1;
        tr.parity_en=1'b0;
        tr.stop2=1'b0;
        finish_item(tr);
      end
  endtask
endclass

// SEQUENCE 10: Length=8, variable baud, WITHOUT parity
// ──────────────────────────────────────────────────
class rand_baud_len8 extends uvm_sequence#(transaction);
  `uvm_object_utils(rand_baud_len8);
  transaction tr;
 
  function new(string name="rand_baud_len8");
    super.new(name);
  endfunction
 
  virtual task body();
    repeat(10)
      begin
        tr=transaction::type_id::create("tr");
        start_item(tr);
        assert(tr.randomize);
        tr.op=length8wop;
        tr.rst=1'b0;
        tr.length=8;
        tr.tx_data=tr.tx_data[7:0];
        tr.tx_start=1'b1;
        tr.rx_start=1'b1;
        tr.parity_en=1'b0;
        tr.stop2=1'b0;
        finish_item(tr);
      end
  endtask
endclass



    
      
    
