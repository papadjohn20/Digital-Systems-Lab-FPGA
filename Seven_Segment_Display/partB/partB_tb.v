`timescale 1ns/1ps

// --- Testbench ---
module lab1_tb;
    reg clk;
    reg reset;
    
    wire an3, an2, an1, an0;
    wire a, b, c, d, e, f, g, dp;
    
    // Instantiate DUT (Device Under Test)
    FourDigitLEDdriver dut (
        .clk(clk),
        .reset(reset),
        .an3(an3), .an2(an2), .an1(an1), .an0(an0),
        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
        .dp(dp)
    );

    // Clock generation
    initial clk = 1;
    always #5 clk = ~clk; // 100MHz clock (10ns period)

    // Stimulus
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, lab1_tb);

        reset = 1;
        #50;
        reset = 0;
   
        #8000;
        reset = 1;    
        #50;
        reset  = 0;
        
        #3000; 
       $finish;
    end
endmodule