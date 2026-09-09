`ifndef UART_COVERAGE_SV
`define UART_COVERAGE_SV

// ═══════════════════════════════════════════════════
// COVERAGE COLLECTOR
// ═══════════════════════════════════════════════════
// Subscribes to monitor's analysis port
// Samples coverpoints for every transaction
// Reports coverage percentage at end of simulation

class uart_coverage extends uvm_subscriber#(transaction);
  `uvm_component_utils(uart_coverage)

  // ── Transaction handle ──────────────────────────
  transaction tr;

  // ── Covergroup Definition ───────────────────────
  covergroup uart_cg;

    // ── Coverpoint 1: Baud Rate ───────────────────
    // Did we test all supported baud rates?
    cp_baud: coverpoint tr.baud {
      bins baud_4800   = {4800};
      bins baud_9600   = {9600};
      bins baud_14400  = {14400};
      bins baud_19200  = {19200};
      bins baud_38400  = {38400};
      bins baud_57600  = {57600};
    }

    // ── Coverpoint 2: Data Length ─────────────────
    // Did we test all data lengths (5,6,7,8 bits)?
    cp_length: coverpoint tr.length {
      bins len_5 = {5};
      bins len_6 = {6};
      bins len_7 = {7};
      bins len_8 = {8};
    }

    // ── Coverpoint 3: Parity Enable ──────────────
    // Did we test both parity ON and OFF?
    cp_parity_en: coverpoint tr.parity_en {
      bins parity_off = {1'b0};
      bins parity_on  = {1'b1};
    }

    // ── Coverpoint 4: Parity Type ────────────────
    // Did we test both even and odd parity?
    cp_parity_type: coverpoint tr.parity_type {
      bins even_parity = {1'b0};
      bins odd_parity  = {1'b1};
    }

    // ── Coverpoint 5: Stop Bits ──────────────────
    // Did we test both 1 and 2 stop bits?
    cp_stop2: coverpoint tr.stop2 {
      bins one_stop_bit = {1'b0};
      bins two_stop_bits = {1'b1};
    }

    // ── Coverpoint 6: TX Data Ranges ─────────────
    // Did we test different data patterns?
    cp_tx_data: coverpoint tr.tx_data {
      bins all_zeros  = {8'h00};            // 0000_0000
      bins all_ones   = {8'hFF};            // 1111_1111
      bins alt_55     = {8'h55};            // 0101_0101
      bins alt_aa     = {8'hAA};            // 1010_1010
      bins msb_only   = {8'h80};            // 1000_0000
      bins lsb_only   = {8'h01};            // 0000_0001
      bins low_range  = {[8'h02:8'h7E]};    // low values
      bins high_range = {[8'h81:8'hFE]};    // high values
    }

    // ── Coverpoint 7: Operation Mode ─────────────
    // Did we test all defined oper_mode values?
    cp_op: coverpoint tr.op {
      bins op_rand_baud_1stop  = {rand_baud_1_stop};
      bins op_rand_baud_2stop  = {rand_baud_2_stop};
      bins op_len5_parity      = {length5wp};
      bins op_len6_parity      = {length6wp};
      bins op_len7_parity      = {length7wp};
      bins op_len8_parity      = {length8wp};
      bins op_len5_noparity    = {length5wop};
      bins op_len6_noparity    = {length6wop};
      bins op_len7_noparity    = {length7wop};
      bins op_len8_noparity    = {length8wop};
    }

    // ── Cross 1: Baud Rate × Data Length ─────────
    // Did we test all baud+length combinations?
    // e.g. 9600 baud with 5-bit data
    //      9600 baud with 8-bit data
    //      57600 baud with 5-bit data etc.
    cx_baud_length: cross cp_baud, cp_length;

    // ── Cross 2: Length × Parity ─────────────────
    // Did we test all length+parity combinations?
    cx_length_parity: cross cp_length, cp_parity_en;

    // ── Cross 3: Parity Enable × Parity Type ─────
    // When parity is ON — did we test both types?
    cx_parity: cross cp_parity_en, cp_parity_type;

  endgroup

  // ── Constructor ──────────────────────────────────
  function new(input string inst="uart_coverage",
               uvm_component parent=null);
    super.new(inst, parent);
    uart_cg = new();          // instantiate covergroup
  endfunction

  // ── build_phase ──────────────────────────────────
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction

  // ── write(): called automatically by analysis port ──
  // Every time monitor sends a transaction
  // coverage is sampled
  virtual function void write(transaction t);
    tr = t;
    uart_cg.sample();         // ← SAMPLE all coverpoints
    `uvm_info("COV",
      $sformatf("Coverage sampled — Current: %0.2f%%",
        uart_cg.get_coverage()),
      UVM_NONE)
  endfunction

  // ── report_phase: print final coverage ──────────
  virtual function void report_phase(uvm_phase phase);
    `uvm_info("COV",
      $sformatf("════════════════════════════════════════"),
      UVM_NONE)
    `uvm_info("COV",
      $sformatf("FINAL COVERAGE REPORT"),
      UVM_NONE)
    `uvm_info("COV",
      $sformatf("════════════════════════════════════════"),
      UVM_NONE)
    `uvm_info("COV",
      $sformatf("Overall Coverage     : %0.2f%%",
        uart_cg.get_coverage()),
      UVM_NONE)
    `uvm_info("COV",
      $sformatf("Baud Rate Coverage   : %0.2f%%",
        uart_cg.cp_baud.get_coverage()),
      UVM_NONE)
    `uvm_info("COV",
      $sformatf("Data Length Coverage : %0.2f%%",
        uart_cg.cp_length.get_coverage()),
      UVM_NONE)
    `uvm_info("COV",
      $sformatf("Parity EN Coverage   : %0.2f%%",
        uart_cg.cp_parity_en.get_coverage()),
      UVM_NONE)
    `uvm_info("COV",
      $sformatf("Stop Bits Coverage   : %0.2f%%",
        uart_cg.cp_stop2.get_coverage()),
      UVM_NONE)
    `uvm_info("COV",
      $sformatf("TX Data Coverage     : %0.2f%%",
        uart_cg.cp_tx_data.get_coverage()),
      UVM_NONE)
    `uvm_info("COV",
      $sformatf("════════════════════════════════════════"),
      UVM_NONE)
  endfunction

endclass

`endif
