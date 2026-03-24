`timescale 1ns/1ps

module HDMI_controller_tb();

    reg clk = 0;      // 100 MHz clock
    reg rst = 1;      // reset
    reg [7:0] sw = 8'b1111_0000;
    
    wire hdmi_clk_p, hdmi_clk_n;
    wire [2:0] hdmi_tx_p, hdmi_tx_n;

    //--------------------------------------------------
    // Instantiate DUT (HDMI_controller)
    //--------------------------------------------------
    HDMI_controller dut (
        .clk(clk),
        .reset(rst),
        .sw(sw),
        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_tx_p(hdmi_tx_p),
        .hdmi_tx_n(hdmi_tx_n)
    );
        
    always #5 clk = ~clk;   // 10 ns period

    //--------------------------------------------------
    // Reset sequence
    //--------------------------------------------------
    initial begin
        $display("Starting HDMI TOP simulation...");
        rst = 1;
        #200;          // hold reset 200 ns
        rst = 0;
        $display("Reset released.");
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