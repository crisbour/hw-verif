interface reg_if (input bit clk);
  logic        rstn;
  logic [7:0]  addr;
  logic [15:0] wdata;
  logic [15:0] rdata;
  logic        sel;
  logic        wr;
  logic        ready;

endinterface
