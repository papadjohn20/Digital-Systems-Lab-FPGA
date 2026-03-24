`timescale 1ns/1ps
module partB_tb;
    reg clk = 0;
    always #5 clk = ~clk; // 100 MHz period (change if needed)

    reg reset = 1;
    
    wire hsync_sig, vsync_sig, activedraw_sig;
    wire [2:0] rgb;
    wire [9:0] hcount, vcount;
    wire [6:0] h_rgb_count, v_rgb_count;
    wire pixel_clk, clk_125MHz;
    
    partB_top dut (
        .clk(clk),
        .reset(reset),
        .activedraw_sig(activedraw_sig),
        .hsync_sig(hsync_sig),
        .vsync_sig(vsync_sig),
        .rgb(rgb),
        .hcount(hcount),
        .vcount(vcount),
        .h_rgb_count(h_rgb_count),
        .v_rgb_count(v_rgb_count),
        .pixel_clk(pixel_clk),
        .clk_125MHz(clk_125MHz)
    );

    initial begin
        $display("Starting Part B test...");

        // Release reset after some cycles
        #200 reset = 0;

        // Run through 3 rows
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);
        repeat (3473) @(posedge clk);



        $display("\nSimulation finished.");
        $finish;
    end

endmodule
