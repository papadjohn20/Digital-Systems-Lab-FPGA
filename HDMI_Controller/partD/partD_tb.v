`timescale 1ns/1ps

module HDMI_controller_tb();

    reg clk = 0;      // 100 MHz clock
    reg rst = 1;      // reset

    wire hdmi_clk_p, hdmi_clk_n;
    wire [2:0] hdmi_tx_p, hdmi_tx_n;

    //--------------------------------------------------
    // Instantiate DUT (HDMI_controller)
    //--------------------------------------------------
    HDMI_controller dut (
        .clk(clk),
        .reset(rst),
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
    // Monitor important signals inside partB_top
    //--------------------------------------------------
    // Access internal signals with hierarchical names
    wire pixel_clk       = dut.timing_and_vram.pixel_clk;
    wire clk_125         = dut.timing_and_vram.clk_125MHz;
    wire activedraw_sig  = dut.timing_and_vram.activedraw_sig;
    wire hsync_sig       = dut.timing_and_vram.hsync_sig;
    wire vsync_sig       = dut.timing_and_vram.vsync_sig;
    wire [9:0] hcount    = dut.timing_and_vram.hcount;
    wire [9:0] vcount    = dut.timing_and_vram.vcount;
    wire [2:0] rgb       = dut.timing_and_vram.rgb;


    initial begin
        #3_500_000;   // simulate ~3.5 ms
        $display("Simulation finished.");
        $finish;
    end

endmodule
