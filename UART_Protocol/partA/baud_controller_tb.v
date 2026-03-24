`timescale 1ns/1ps
module tb_baud_controller;

    reg clk;
    reg reset;
    reg [2:0] baud_select;
    wire sample_ENABLE;

    baud_controller uut (
        .reset(reset),
        .clk(clk),
        .baud_select(baud_select),
        .sample_ENABLE(sample_ENABLE)
    );

    // Generate 100 MHz clock (10 ns period)
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        
        reset = 1;
        baud_select = 3'b111; // Start with 115200 baud
        #50;
        reset = 0;

        // Run for several pulses at 9600 baud
        #(1_500);

        // Change baud rate to 19200
        baud_select = 3'b100;
        #(10_000);

        $finish;
    end

endmodule
