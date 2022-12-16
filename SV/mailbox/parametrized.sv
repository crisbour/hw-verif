typedef mailbox #(string) s_mbox;

// Component to send messages
class producer;
  // Create a mailbox ot handle the put items
  s_mbox names;

  task send();
    for (int i = 0; i < 3; i++) begin
      string s = $sformatf("name_%0d", i);
      #1 $display("[%0t] Producer: Put %s", $time, s);
      names.put(s);
    end
  endtask
endclass

// Consumer Component
class consumer;
  s_mbox list;

  task receive();
    forever begin
      string s;
      list.get(s);
      $display("[%0t] Consumer: Got %s", $time, s);
    end
  endtask
endclass

module tb;
  s_mbox m_mbx = new();
  producer m_producer = new();
  consumer m_consumer = new();

  initial begin
    m_producer.names = m_mbx;
    m_consumer.list = m_mbx;

    fork
      m_producer.send();
      m_consumer.receive();
    join
  end
endmodule
