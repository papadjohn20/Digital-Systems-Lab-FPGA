`timescale 1ns/1ps

module PartC_tb();

    reg clk = 0;
    reg reset = 1;
    reg up = 0;
    reg down = 0;
    reg [3:0] paddle_speed = 4'd1;

    wire hdmi_clk_p, hdmi_clk_n;
    wire [2:0] hdmi_tx_p, hdmi_tx_n;
    wire LD0;

    HDMI_controller dut (
        .clk(clk),
        .reset(reset),
        .up(up),
        .down(down),
        .paddle_speed(paddle_speed),
        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_tx_p(hdmi_tx_p),
        .hdmi_tx_n(hdmi_tx_n),
        .LD0(LD0)
    );

    always #5 clk = ~clk;

    initial begin
        reset = 1;
        up = 0;
        down = 0;
        paddle_speed = 4'd1; 
        #200;
        reset = 0; 


        #10_000; 

        $display("Moving Paddle Down...");
        down = 1;

        #40_000; 
        down = 0;

        #50_000;

        $display("Moving Paddle Up with higher speed...");
        paddle_speed = 4'd3;
        up = 1;
        #40_000;
        up = 0;

        #500;
        $display("Simulation finished.");
        $finish; 
    end

    initial begin
        $monitor("Time=%0t | Up=%b Down=%b Speed=%d | LED=%b", 
                 $time, up, down, paddle_speed, LD0);
    end

endmodule