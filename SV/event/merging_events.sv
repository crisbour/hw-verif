module tb;
    event event_a, event_b;

    initial begin
        fork
            // Thread1: waits for event_a to be triggered
            begin
                wait(event_a.triggered);
                $display("[%0t] Thread 1: Wait for event_a is over", $time);
            end
            // Thread2: waits for event_b to be triggered
            begin
                wait(event_b.triggered);
                $display("[%0t] Thread 2: Wait for event_b is over", $time);
            end
            
            // Thread3: triggers event_a after 20 ns
            #20 -> event_a;

            // Thread4: triggers event_b after 30 ns
            #30 -> event_b;

            // Thread5: Assigns event_b to event_a at 10ns
            // This cause triggering of event_a to propagate to event_b
            begin
                //#10 event_b = event_a;
            end
        join
    end
endmodule
