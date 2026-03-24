`timescale 1ns/1ps

module partA_tb();

    reg clk = 0;      // 100 MHz clock
    reg reset = 1;      // reset
    wire new_frame_sig;
    wire LD0;
    
    partA_top dut (
        .clk(clk),
        .reset(reset),
        .new_frame_sig(new_frame_sig),
        .LD0(LD0)
    );
        
    always #5 clk = ~clk;   // 10 ns period

    //--------------------------------------------------
    // Reset sequence
    //--------------------------------------------------
    initial begin
        reset = 1;
        #200;          // hold reset 200 ns
        reset = 0;
    end
    //--------------------------------------------------
    // Simulation duration
    //--------------------------------------------------
    initial begin
        #3_500_000;   // simulate ~3.5 ms
        $display("Simulation finished.");
        $stop;
    end

endmodule