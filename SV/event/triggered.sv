module tb;
    event event_a;

    initial begin 
        #20 -> event_a;
        $display ( "[%0t] Thread1: triggered event_a", $time);
    end

    // Thread2: Starts waiting for the event using "@" operator at 20ns
    initial begin
        $display ("[%0t] Thread2: waiting for trigger", $time);
        #20 @(event_a);
        $display("[%0t] Thread2: received event_a trigger", $time);
    end

    // Thread3: Starts witing for the event using ".triggered" at 20ns
    initial begin
        $display ("[%0t] Thread3: waiting for trigger", $time);
        #20 @(event_a);
        $display("[%0t] Thread3: received event_a trigger", $time);

    end
endmodule
