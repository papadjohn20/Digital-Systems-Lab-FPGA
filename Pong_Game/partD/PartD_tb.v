`timescale 1ns/1ps

module partD_tb();

    reg clk = 0;
    reg reset = 1;
    reg up = 0;
    reg down = 0;
    reg new_game = 0;
    reg [3:0] paddle_speed = 4'd1;
    reg [3:0] puck_speed = 4'd3;

    wire hdmi_clk_p, hdmi_clk_n;
    wire [2:0] hdmi_tx_p, hdmi_tx_n;
    wire LD0;

    HDMI_controller dut (
        .clk(clk),
        .reset(reset),
        .up(up),
        .down(down),
        .new_game(new_game),
        .paddle_speed(paddle_speed),
        .puck_speed(puck_speed),
        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_tx_p(hdmi_tx_p),
        .hdmi_tx_n(hdmi_tx_n),
        .LD0(LD0)
    );

    always #5 clk = ~clk;

    initial begin
        reset = 1;
        new_game = 0;
        #200;
        reset = 0;
        
        // Start game
        $display("Starting New Game...");
        new_game = 1;
        #100;
        new_game = 0;

        #60_000; 

        // move paddle down
        // $display("Moving paddle to intercept puck...");
        // down = 1;
        // #500_000;
        // down = 0;

        // $display("Increasing puck speed...");
        // puck_speed = 4'd10; 
        // #1_000_000;

        // Game Over
        $display("Waiting for Game Over...");
        #60_000;

        // 2nd game start
//        $display("Resetting game with New Game button...");
//        new_game = 1;
//        #100;
//        new_game = 0;

//        #120_000;
        $display("Simulation finished.");
        $stop;
    end

endmodule