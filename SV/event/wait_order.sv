module tb;
    event a, b, c;

    initial begin
        #10 -> a;
        #20 -> b;
        #30 -> c;
    end

    initial begin
        wait_order (a, b, c)
            $display("Events were executed in the correct order");
        else
            $display("Events were NOT executed in the correct order");
    end
endmodule

