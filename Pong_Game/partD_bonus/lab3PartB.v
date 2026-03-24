module lab3PartB(
    input  wire clk,
    input  wire reset,
    output wire activedraw_sig,
    output wire hsync_sig,
    output wire vsync_sig,
    output wire [9:0] hcount,
    output wire [9:0] vcount,
    output wire [6:0] h_rgb_count,
    output wire [6:0] v_rgb_count,
    output wire pixel_clk,
    output wire clk_125MHz,
    output wire [2:0] left_rgb,
    output wire [2:0] right_rgb
);

    // MMCM for pixel clock
    pixel_clock_gen clkgen (
        .clk_100MHz(clk),
        .reset(reset),
        .pixclk_25MHz(pixel_clk),
        .clk_125MHz(clk_125MHz)
    );

    // Frame timing instantiation
    frame_timing frame_timing_inst (
        .pixclk(pixel_clk),
        .reset(reset),
        .hcount(hcount),
        .vcount(vcount),
        .h_rgb_count(h_rgb_count),
        .v_rgb_count(v_rgb_count),     
        .activedraw_sig(activedraw_sig),
        .hsync_sig(hsync_sig),
        .vsync_sig(vsync_sig)
    );

    // Build VRAM address: keep lower 7 bits of each for 128 of x and 96 of y
    wire [13:0] addr = {v_rgb_count, h_rgb_count};
    
    // LEFT VRAM from Part A
    left_vram left_vram_inst (
        .clk(pixel_clk),
        .addr(addr),
        .rgb(left_rgb)
    );

    // RIGHT VRAM from Part A
    right_vram right_vram_inst (
        .clk(pixel_clk),
        .addr(addr),
        .rgb(right_rgb)
    );
    
endmodule
