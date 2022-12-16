class reg_item;
  rand bit [7:0]  addr;
  rand bit [15:0] wdata;
       bit [15:0] rdata;
  rand bit        wr;

  // Optionally you can define a constraint as per Section 12 of SV LRM:
  // constraint <name> { <signal>[<bits_range] == <value>; }

  function void print(string tag="");
    $display ("T=%0t [%s] addr=0x%0h wr=%0d wdata=0%0h rdata=0%0h",
      $time, addr, wr, wdata, rdata);
  endfunction
  
endclass
