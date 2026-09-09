`ifndef UART_TRANSACTION_SV
`define UART_TRANSACTION_SV

// ═══════════════════════════════════════════
// LAYER 2: TRANSACTION — Data Packet
// ═══════════════════════════════════════════
// One object = one UART transfer
// Contains: what to send, how to send, what was received
// Passed between: sequence → driver → DUT → monitor → scoreboard

typedef enum bit [3:0] {
  rand_baud_1_stop   = 0,
  rand_length_1_stop = 1,
  length5wp          = 2,   // length 5 with parity
  length6wp          = 3,
  length7wp          = 4,
  length8wp          = 5,
  length5wop         = 6,   // length 5 without parity
  length6wop         = 7,
  length7wop         = 8,
  length8wop         = 9,
  rand_baud_2_stop   = 11,
  rand_length_2_stop = 12
} oper_mode;

class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction);

  // ── Randomizable fields (stimulus) ────────
  rand oper_mode op;
  rand logic [7:0] tx_data;
  rand logic [16:0] baud;
  rand logic [3:0] length;
  rand logic parity_type, parity_en;

  // ── Control fields (set by sequence) ──────
  logic tx_start, rx_start;
  logic rst;
  logic stop2;

  // ── Response fields (filled by DUT) ───────
  logic tx_done, rx_done, tx_err, rx_err;
  logic [7:0] rx_out;

  // ── Constraints ───────────────────────────
  constraint baud_c {
    baud inside {4800, 9600, 14400, 19200, 38400, 57600};
  }

  constraint length_c {
    length inside {5, 6, 7, 8};
  }

  function new(string name ="transaction");
    super.new(name);
  endfunction

endclass : transaction

`endif
