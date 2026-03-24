module partA_top (
    input  wire clk,          // 100 MHz input clock
    input  wire reset,        // button reset
    output new_frame_sig,
    output LD0
);

    //----------------------------------------------------
    // 1. PART B TOP (timing + VRAM + pixel clocks)
    //----------------------------------------------------
    wire activedraw_sig;
    wire hsync_sig, vsync_sig;
    wire [9:0] hcount, vcount;
    wire pixel_clk;           // 25.175 MHz
    wire clk_125MHz;          // 125.875 MHz (pixel 5)

    lab3PartB timing_and_vram (
        .clk(clk),
        .reset(reset),
        .activedraw_sig(activedraw_sig),
        .hsync_sig(hsync_sig),
        .vsync_sig(vsync_sig),
        .hcount(hcount),
        .vcount(vcount),
        .pixel_clk(pixel_clk),
        .clk_125MHz(clk_125MHz)
    );

    newframe newframe_inst(
        .clk(pixel_clk),
        .reset(reset),
        .hcount(hcount),
        .vcount(vcount),
        .new_frame_sig(new_frame_sig),
        .LD0(LD0)
    );

endmodule