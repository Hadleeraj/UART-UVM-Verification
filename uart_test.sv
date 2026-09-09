class test extends uvm_test;
  `uvm_component_utils(test);
  
  function new(input string inst="test", uvm_component c);
    super.new(inst,c);
  endfunction
  
  env e;
  
  rand_baud rb;
  random_baud_with_stop rbs;
  random_baud_len5p rb51;
  random_baud_len6p rb61;
  random_baud_len7p rb71;
  random_baud_len8p rb81;
  
  random_baud_len5 rb51wop;
  rand_baud_len6 rb61wop;
  rand_baud_len7 rb71wop;
  rand_baud_len8 rb81wop;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    e=env::type_id::create("env", this);
    rb=rand_baud::type_id::create("rb");
    rbs=random_baud_with_stop::type_id::create("rbs");
    rb51=random_baud_len5p::type_id::create("rb51");
    rb61=random_baud_len6p::type_id::create("rb61");
    rb71=random_baud_len7p::type_id::create("rb71");
    rb81=random_baud_len8p::type_id::create("rb81");
    rb51wop=random_baud_len5::type_id::create("rb51wop");
    rb61wop=rand_baud_len6::type_id::create("rb61wop");
    rb71wop=rand_baud_len7::type_id::create("rb71wop");
    rb81wop=rand_baud_len8::type_id::create("rb81wop");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    rb.start(e.a.seqr);
    rbs.start(e.a.seqr);
    rb51.start(e.a.seqr);
    rb61.start(e.a.seqr);
    rb71.start(e.a.seqr);
    rb81.start(e.a.seqr);
    rb51wop.start(e.a.seqr);
    rb61wop.start(e.a.seqr);
    rb71wop.start(e.a.seqr);
    rb81wop.start(e.a.seqr);
    
    #20;
    phase.drop_objection(this);
  endtask
endclass

  
  
