
interface switch_if (input bit clk);
  logic rstn;
  logic vld;
  logic [7:0]  addr;
  logic [15:0] data;

  logic [7:0] addr_a;
  logic [15:0] data_a;

  logic [7:0] addr_b;
  logic [15:0] data_b;
endinterface

import testbench_pkg::*;
`include "switch.sv"

module tb;

  reg clk;

  always #10 clk = ~clk;

  switch_if _if (clk);

  switch u0 (
    .clk    (clk),
    .rstn   (_if.rstn),
    .addr   (_if.addr),
    .data   (_if.data),
    .vld    (_if.vld),
    .addr_a (_if.addr_a),
    .data_a (_if.data_a),
    .addr_b (_if.addr_b),
    .data_b (_if.data_b)
  );

  test t0;

  initial begin
    {clk, _if.rstn} <= 0;

    #20 _if.rstn <=1;
    t0 = new;
    t0.e0.vif = _if;
    t0.run();

    #50 $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

endmodule
