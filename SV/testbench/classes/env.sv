`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"
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
