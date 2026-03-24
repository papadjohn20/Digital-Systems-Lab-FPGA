`timescale 1ns/1ps

//SIMULATION SETTINGS
// small simulation 300us


module partD_tb();

    // --- Input Signals ---
    reg clk = 0;
    reg reset = 1;
    reg up = 0;
    reg down = 0;
    reg up_right = 0;     // New: SW0 for Right Paddle Up
    reg down_right = 0;   // New: SW1 for Right Paddle Down
    reg new_game = 0;
    reg [3:0] paddle_speed = 4'd1; // Set a visible speed for simulation
    reg [3:0] puck_speed = 4'd1;

    wire hdmi_clk_p, hdmi_clk_n;
    wire [2:0] hdmi_tx_p, hdmi_tx_n;
    wire LD0;
    wire an3, an2, an1, an0;
    wire a, b, c, d, e, f, g, dp;

    // --- Updated DUT Instantiation for 1v1 ---
    HDMI_controller dut (
        .clk(clk),
        .reset(reset),
        .up(up),
        .down(down),
        .up_right(up_right),     // Connected to Right Paddle Up
        .down_right(down_right), // Connected to Right Paddle Down
        .new_game(new_game),
        .paddle_speed(paddle_speed),
        .puck_speed(puck_speed),
        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_tx_p(hdmi_tx_p),
        .hdmi_tx_n(hdmi_tx_n),
        .LD0(LD0),
        .an3(an3),
        .an2(an2),
        .an1(an1),
        .an0(an0),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .dp(dp)
    );

    always #5 clk = ~clk;

    initial begin
        // 1. System Reset
        reset = 1;
        new_game = 0;
        up = 0; down = 0;
        up_right = 0; down_right = 0;
        #200;
        reset = 0;
        
        // 2. Start Game
        $display("Starting 1v1 New Game...");
        new_game = 1;
        #100;
        new_game = 0;

        // Wait for some frames to pass

        // // 3. Test Left Paddle (Buttons)
        // $display("Testing Left Player movement...");
        // down = 1; 
        // #40_000;
        // down = 0;

        // // 4. Test Right Paddle (Switches)
        // $display("Testing Right Player movement...");
        // up_right = 1; 
        // #40_000;
        // up_right = 0;

        // // 5. Test Simultaneous Movement
        // $display("Moving both paddles at once...");
        // up = 1;
        // down_right = 1;
        // #50_000;
        // up = 0;
        // down_right = 0;

        // 6. Simulate Playtime for Collisions
        $display("Waiting for potential collisions or Game Over...");
        #140_000;
               
        // 7. Reset for a 2nd round
        $display("Resetting game for Round 2...");
        new_game = 1;
        #100;
        new_game = 0;
        puck_speed = 4'd2; // with double the speed

        #120_000;
         // 7. Reset for a 3rd round
        $display("Resetting game for Round 2...");
        new_game = 1;
        #100;
        new_game = 0;
        puck_speed = 4'd2; // with double the speed

        #120_000;
        
        //TESTING MATCH OVER
         // 7. Reset for a 4th round
        $display("Resetting game for Round 2...");
        new_game = 1;
        #100;
        new_game = 0;
        puck_speed = 4'd2; // with double the speed

        #120_000;

        $display("Simulation finished.");
        $stop;
    end
endmodule