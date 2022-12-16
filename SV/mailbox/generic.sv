module tb;
  mailbox   mbx = new(2);

  // Thread0 is producer
  initial begin
    for (int i=0; i < 5; i++) begin
      #1 mbx.put (i);
      $display("[%0t] Thread0: Put item #%0d, size=%0d", $time, i, mbx.num());
    end
  end

  // Thread1 is consumer
  initial begin
    forever begin
      int idx;
      #2 mbx.get(idx);
      $display("[%0t] Thread1: Got item #%0d, size=%0d", $time, idx, mbx.num());
    end
  end

endmodule

