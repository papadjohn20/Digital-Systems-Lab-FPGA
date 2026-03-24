module HDMI_controller(
    input  wire clk,          // 100 MHz input clock
    input  wire reset,        // button reset
    output wire hdmi_clk_p,
    output wire hdmi_clk_n,
    output wire [2:0] hdmi_tx_p,
    output wire [2:0] hdmi_tx_n
);

    //----------------------------------------------------
    // 1. PART B TOP (timing + VRAM + pixel clocks)
    //----------------------------------------------------
    wire activedraw_sig;
    wire hsync_sig, vsync_sig;
    wire [2:0] rgb;           // 1-bit R/G/B from VRAM
    wire [9:0] hcount, vcount;
    wire pixel_clk;           // 25.175 MHz
    wire clk_125MHz;          // 125.875 MHz (pixel × 5)

    partB_top timing_and_vram (
        .clk(clk),
        .reset(reset),
        .activedraw_sig(activedraw_sig),
        .hsync_sig(hsync_sig),
        .vsync_sig(vsync_sig),
        .rgb(rgb),
        .hcount(hcount),
        .vcount(vcount),
        .pixel_clk(pixel_clk),
        .clk_125MHz(clk_125MHz)
    );

    //----------------------------------------------------
    // 2. Expand VRAM 3-bit output into 8-bit color channels
    //----------------------------------------------------
    wire [7:0] red   = {8{rgb[2]}};
    wire [7:0] green = {8{rgb[1]}};
    wire [7:0] blue  = {8{rgb[0]}};

    //----------------------------------------------------
    // 3. TMDS encoders (Part C)
    //----------------------------------------------------
    wire [9:0] tmds_encoded [2:0];

    // RED channel
    tmds_encoder enc_red (
        .clk_in(pixel_clk),
        .rst_in(reset),
        .data_in(red),
        .control_in(2'b00),
        .ve_in(activedraw_sig),
        .tmds_out(tmds_encoded[2])
    );

    // GREEN channel
    tmds_encoder enc_green (
        .clk_in(pixel_clk),
        .rst_in(reset),
        .data_in(green),
        .control_in(2'b00),
        .ve_in(activedraw_sig),
        .tmds_out(tmds_encoded[1])
    );

    // BLUE channel (carries sync information!)
    tmds_encoder enc_blue (
        .clk_in(pixel_clk),
        .rst_in(reset),
        .data_in(blue),
        .control_in({vsync_sig, hsync_sig}),
        .ve_in(activedraw_sig),
        .tmds_out(tmds_encoded[0])
    );

    //----------------------------------------------------
    // 4. TMDS serializers (given file)
    //----------------------------------------------------
    wire [2:0] tmds_signal;

    tmds_serializer ser_red (
        .clk_pixel_in(pixel_clk),
        .clk_5x_in(clk_125MHz),
        .rst_in(reset),
        .tmds_in(tmds_encoded[2]),
        .tmds_out(tmds_signal[2])
    );

    tmds_serializer ser_green (
        .clk_pixel_in(pixel_clk),
        .clk_5x_in(clk_125MHz),
        .rst_in(reset),
        .tmds_in(tmds_encoded[1]),
        .tmds_out(tmds_signal[1])
    );

    tmds_serializer ser_blue (
        .clk_pixel_in(pixel_clk),
        .clk_5x_in(clk_125MHz),
        .rst_in(reset),
        .tmds_in(tmds_encoded[0]),
        .tmds_out(tmds_signal[0])
    );

    //----------------------------------------------------
    // 5. OBUFDS → differential TMDS
    //----------------------------------------------------
    OBUFDS OBUFDS_blue (.I(tmds_signal[0]), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
    OBUFDS OBUFDS_green(.I(tmds_signal[1]), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
    OBUFDS OBUFDS_red (.I(tmds_signal[2]), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));

    OBUFDS obuf_clk (.I(pixel_clk), .O(hdmi_clk_p), .OB(hdmi_clk_n));

endmodule
