package testbench_pkg;

// ==========================================
// Module transactio object 
// ==========================================
class switch_item;
  rand bit [7:0]  addr;
  rand bit [15:0] data;
       bit [15:0] addr_a;
       bit [15:0] data_a;
       bit [15:0] addr_b;
       bit [15:0] data_b;

  // Optionally you can define a constraint as per Section 12 of SV LRM:
  // constraint <name> { <signal>[<bits_range] == <value>; }

  function void print(string tag="");
    $display ("T=%0t [%s] addr=0x%0h data=0%0h", $time, tag, addr, data,
      "addr_a=0%0h data_a=0x0h", addr_a, data_a,
      "addr_b=0%0h data_b=0x0h", addr_b, data_b);
  endfunction
endclass

// ==========================================
// GENERATOR 
// ==========================================
class generator;
  mailbox drv_mbx;
  event drv_done;
  int num = 20;

  task run();
    for (int i=0; i < num; i++) begin
      switch_item item = new;
      item.randomize();
      $display("T=%0t [Generator] Loop:%0d/%0d create next item", $time, i, num);
      drv_mbx.put(item);
      @ (drv_done);
    end
    $display("T=%0t [Generator] Done generation of %0d items", $time, num);
  endtask
endclass

// ==========================================
// Module SCOREBOARD 
// ==========================================

class scoreboard;
  mailbox  scb_mbx;

  task run();
    forever begin
      switch_item item;
      scb_mbx.get(item);
      item.print("Scoreboard");

      if (item.addr inside {[0:'h3f]}) begin
        if (item.addr_a != item.addr | item.data_a != item.data)
          $display("T=%0t [Scoreboard] ERROR! Missmatch ", $time,
            "addr=0x%0h data=0x%0h", item.addr, item.data,
            "addr=0x%0h data=0x%0h", item.addr_a, item.data_a);
          else
          $display("T=%0t [Scoreboard] PASS! ", $time,
            "addr=0x%0h data=0x%0h", item.addr, item.data,
            "addr=0x%0h data=0x%0h", item.addr_a, item.data_a);
      end else begin
        if (item.addr_b != item.addr | item.data_b != item.data)
          $display("T=%0t [Scoreboard] ERROR! Missmatch ", $time,
            "addr=0x%0h data=0x%0h", item.addr, item.data,
            "addr=0x%0h data=0x%0h", item.addr_b, item.data_b);
          else
          $display("T=%0t [Scoreboard] PASS! ", $time,
            "addr=0x%0h data=0x%0h", item.addr, item.data,
            "addr=0x%0h data=0x%0h", item.addr_b, item.data_b);
      end
    end
  endtask
endclass

// ==========================================
// DRIVER 
// ==========================================

class driver;
  virtual switch_if vif;
  event drv_done;
  mailbox drv_mbx;

  task run();
    $display("T=%0t [Driver] starting ...", $time);
    @ (posedge vif.clk);

    forever begin
      switch_item item;
      $display("T=%0t [Driver] waiting fo item ...", $time);
      drv_mbx.get(item);
      item.print("Driver");
      vif.vld  <= 1;
      vif.addr <= item.addr;
      vif.data <= item.data;
      // When transfer is over, raise the done event
      @(posedge vif.clk);
      vif.vld <= 0; -> drv_done;
    end
  endtask
endclass

// ==========================================
// MONITOR 
// ==========================================

class monitor;
  virtual switch_if vif;
  mailbox scb_mbx;
  semaphore sema4;

  function new ();
    sema4 = new(1);
  endfunction

  task run();
    $display("T=%0t [Monitor] starting ...", $time);
    // To get a pipeline effect, fork two threads
    // where each thread uses a semaphore for the address phase
    fork
      sample_port("Thread0");
      sample_port("Thread1");
    join
  endtask

  task sample_port(string tag="");
    forever begin
      @ (posedge vif.clk)
      if (vif.rstn & vif.vld) begin
        switch_item item = new;
        sema4.get();
        item.addr = vif.addr;
        item.data = vif.data;
        $display("T=%0t [Monitor] %s First part over", $time, tag);

        @ (posedge vif.clk);
        sema4.put();
        item.addr_a = vif.addr_a;
        item.data_a = vif.data_a;
        item.addr_b = vif.addr_b;
        item.data_b = vif.data_b;
        $display("T=%0t [Monitor] %s Second part over", $time, tag);

        scb_mbx.put(item);
        item.print({"Monitor_", tag});
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
  generator  g0;
  scoreboard s0;

  mailbox drv_mbx;
  mailbox scb_mbx;
  event   drv_done;

  virtual switch_if vif;

  function new();
    d0 = new;
    m0 = new;
    g0 = new;
    s0 = new;
    drv_mbx = new();
    scb_mbx = new();

    d0.drv_mbx = drv_mbx;
    g0.drv_mbx = drv_mbx;
    m0.scb_mbx = scb_mbx;
    s0.scb_mbx = scb_mbx;

    d0.drv_done = drv_done;
    g0.drv_done = drv_done;
  endfunction

  virtual task run();
    d0.vif = vif;
    m0.vif = vif;

    fork
      d0.run();
      m0.run();
      g0.run();
      s0.run();
    join_any // In this case if driver finishes, the monitor and scoreboard will not check latest mailbox
  endtask
endclass

// ==========================================
// Module TEST 
// ==========================================

class test;
  env e0;

  function new();
    e0 = new;
  endfunction

  task run();
    e0.run();
  endtask

endclass

endpackage
