`timescale 1ns/1ps
module tm_choice_tb;

    reg  [7:0] data_in;
    wire [8:0] q_m;

    tm_choice uut (
        .data_in(data_in),
        .q_m(q_m)
    );

    task test(input [7:0] d);
    begin
        data_in = d;
        #1;
        $display("data_in = %b  ->  q_m = %b   (MSB=%b)", 
                  data_in, q_m, q_m[8]);
    end
    endtask

    initial begin
        test(8'b1111_1110); // example from lab
        test(8'b0000_0000);
        test(8'b1111_1111);
        test(8'b1010_1010);
        test(8'b0101_0101);
        test(8'b1100_0011);
        test(8'b0011_1100);

        $finish;
    end
endmodule
