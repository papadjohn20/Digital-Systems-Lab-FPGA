//---------------DEBOUNCER ---------------//
`timescale 1ns/1ps

// --- Testbench ---
module lab1_tb;
    reg clk;
    reg reset;
    reg button;

    wire an3, an2, an1, an0;
    wire a, b, c, d, e, f, g, dp;
    
    // Instantiate DUT (Device Under Test)
    FourDigitLEDdriver dut (
        .clk(clk),
        .reset(reset),
        .button(button),
        .an3(an3), .an2(an2), .an1(an1), .an0(an0),
        .a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
        .dp(dp)
    );

    // Clock generation (100 MHz)
    initial clk = 1;
    always #5 clk = ~clk; // 10 ns period

    // Stimulus
    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, lab1_tb);

        //Initial state
        button = 0;
        reset  = 1;
       
        #50;
        reset  = 0;
        button = 1; //1st valid press
        
        #2300;
        button = 0; //let go after 2.500 ns

        #2000;
        button = 1; //invalid press

        #50;
        button = 0; //let go after 50 ns

        #3000
        button = 1; //2nd valid press
        
        #5500;
        //#3_000;
        button = 0; //let go after 3.500 ns
 
        #1_000
        $finish;
    end
endmodule
