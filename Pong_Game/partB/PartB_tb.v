`timescale 1ns/1ps

module partB_tb();

    reg clk = 0;      // 100 MHz clock
    reg reset = 1;    // reset 
    
    wire hdmi_clk_p;
    wire hdmi_clk_n;
    wire [2:0] hdmi_tx_p;
    wire [2:0] hdmi_tx_n;

    HDMI_controller dut (
        .clk(clk),
        .reset(reset),
        .hdmi_clk_p(hdmi_clk_p),
        .hdmi_clk_n(hdmi_clk_n),
        .hdmi_tx_p(hdmi_tx_p),
        .hdmi_tx_n(hdmi_tx_n)
    );
        
    // clock 100 MHz
    always #5 clk = ~clk;

    initial begin
        reset = 1; 
        #200;          // hold reset for 200 ns
        reset = 0; 
    end

    initial begin 
        #35_000; 
        $display("Simulation finished.");
        $stop; 
    end

endmodule