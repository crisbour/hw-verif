package testbench_pkg;

// ==========================================
// Module model
// ==========================================
class reg_item;
  rand bit [7:0]  addr;
  rand bit [15:0] wdata;
       bit [15:0] rdata;
  rand bit        wr;

  // Optionally you can define a constraint as per Section 12 of SV LRM:
  // constraint <name> { <signal>[<bits_range] == <value>; }

  function void print(string tag="");
    $display ("T=%0t [%s] addr=0x%0h wr=%0d wdata=0%0h rdata=0%0h",
      $time, tag, addr, wr, wdata, rdata);
  endfunction
endclass


// ==========================================
// Module SCOREBOARD 
// ==========================================

class scoreboard;
  mailbox  scb_mbx;
  reg_item refq[256];

  task run();
    forever begin
      reg_item item;
      scb_mbx.get(item);
      item.print("Scoreboard");

      if (item.wr) begin
        if (refq[item.addr] == null)
          refq[item.addr] = new;

        refq[item.addr] = item;
        $display("T=%0t [Scoreboard] Store addr=0x%0h wr=0x%0d data=0x%0h",
          $time, item.addr, item.wr, item.wdata);
      end

      if (!item.wr) begin
        if (refq[item.addr] == null)
          if(item.rdata != 'h1234)
            $display("T=%0t [Scoreboard] ERROR! First time read, addr=0x%0h exp=1234 act=0x%0h",
              $time, item.addr, item.rdata);
          else
            $display("T=%0t [Scoreboard] PASS! First time read, addr=0x%0h exp=1234 act=0x%0h",
              $time, item.addr, item.rdata);
        else
          if (item.rdata != refq[item.addr].wdata)
            $display("T=%0t [Scoreboard] ERROR! addr=0x%0h exp=0x%0h act=0x%0h",
              $time, item.addr, refq[item.addr].wdata, item.rdata);
          else
            $display("T=%0t [Scoreboard] PASS! addr=0x%0h exp=0x%0h act=0x%0h",
              $time, item.addr, refq[item.addr].wdata, item.rdata);
        end
      end
  endtask
endclass

// ==========================================
// DRIVER 
// ==========================================

class driver;
  virtual reg_if vif;
  event drv_done;
  mailbox drv_mbx;

  task run();
    $display("T=%0t [Driver] starting ...", $time);
    @ (posedge vif.clk);

    forever begin
      reg_item item;
      $display("T=%0t [Driver] waiting fo item ...", $time);
      drv_mbx.get(item);
      item.print("Driver");
      vif.sel   <= 1;
      vif.addr  <= item.addr;
      vif.wr    <= item.wr;
      vif.wdata <= item.wdata;
      @(posedge vif.clk);
      while (!vif.ready) begin
        $display ("T=%0t [Driver] wait until ready is high", $time);
        @(posedge vif.clk);
      end
      vif.sel <= 0; -> drv_done;
    end
  endtask
endclass

// ==========================================
// MONITOR 
// ==========================================

class monitor;
  virtual reg_if vif;
  mailbox scb_mbx;

  task run();
    $display("T=%0t [Monitor] starting ...", $time);

    forever begin
      @ (posedge vif.clk);
      if (vif.sel) begin
        reg_item item = new;
        item.addr  = vif.addr;
        item.wr    = vif.wr;
        item.wdata = vif.wdata;

        if(!vif.wr) begin
          @ (posedge vif.clk);
          item.rdata = vif.rdata;
        end

        item.print("Monitor");
        scb_mbx.put(item);
      end
    end
  endtask
endclass

// ==========================================
// ENV
// ==========================================

class env;
  driver     d0;
  monitor    m0;
  scoreboard s0;
  mailbox    scb_mbx;
  virtual reg_if vif;

  function new();
    d0 = new();
    m0 = new();
    s0 = new();
    scb_mbx = new();
  endfunction

  virtual task run();
    d0.vif = vif;
    m0.vif = vif;
    m0.scb_mbx = scb_mbx;
    s0.scb_mbx = scb_mbx;

    fork
      s0.run();
      d0.run();
      m0.run();
    join_any // In this case if driver finishes, the monitor and scoreboard will not check latest mailbox
  endtask
endclass

// ==========================================
// Module TEST 
// ==========================================

class test;
  env     e0;
  mailbox drv_mbx;

  function new();
    drv_mbx = new();
    e0 =      new();
  endfunction

  virtual task run();
    e0.d0.drv_mbx = drv_mbx;

    fork
      e0.run();
    join_none

    apply_stim();

  endtask

  virtual task apply_stim();
    reg_item item;
    $display ("T=%0t [Test] Starting stimulus ...", $time);
    item = new;
    // with add in-line constraints to the class
    item.randomize() with { addr == 8'haa; wr == 1;}; 
    drv_mbx.put(item);
    
    item =new;
    item.randomize() with { addr == 8'haa; wr == 0;};
    drv_mbx.put(item);
  endtask
endclass

endpackage
