`include "reg_ctrl.sv"
import testbench_pkg::*;

// ==========================================
// Module INTERFACE
// ==========================================

interface reg_if (input bit clk);
  logic        rstn;
  logic [7:0]  addr;
  logic [15:0] wdata;
  logic [15:0] rdata;
  logic        sel;
  logic        wr;
  logic        ready;

endinterface

module tb;
  reg clk;

  always #10 clk = ~clk;

  reg_if _if (clk);

  reg_ctrl u0 (
    .clk   (clk),
    .addr  (_if.addr),
    .rstn  (_if.rstn),
    .sel   (_if.sel),
    .wr    (_if.wr),
    .wdata (_if.wdata),
    .rdata (_if.rdata),
    .ready (_if.ready)
  );

  initial begin
    test t0 = new;

    clk <= 0;
    _if.rstn <= 0;
    _if.sel <= 0;
    #20 _if.rstn <= 1;

    t0.e0.vif = _if;
    t0.run();

    #200 $finish;
  end

  initial begin
    $dumpvars;
    $dumpfile("dump.vcd");
  end
endmodule
