module HDMI_controller(
    input  wire clk,          
    input  wire reset,        // BTN0
    input  wire up,           // BTN2
    input  wire down,         // BTN3
    input  wire new_game,     // BTN1 
    input  wire [3:0] paddle_speed, // SW12-SW15
    input  wire [3:0] puck_speed,   // SW8-SW11 
    output wire hdmi_clk_p,
    output wire hdmi_clk_n,
    output wire [2:0] hdmi_tx_p,
    output wire [2:0] hdmi_tx_n,
    output wire LD0           
);

    wire activedraw_sig, hsync_sig, vsync_sig;
    wire [9:0] hcount, vcount;
    wire pixel_clk, clk_125MHz;

    lab3PartB timing_inst (
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

    wire new_frame_sig;
    newframe nf_inst (
        .clk(pixel_clk),
        .reset(reset),
        .hcount(hcount),
        .vcount(vcount),
        .new_frame_sig(new_frame_sig),
        .LD0(LD0)
    );

    wire [7:0] red, green, blue;
    pong game_inst (
        .clk(pixel_clk),
        .reset(reset),
        .up(up),
        .down(down),
        .new_game(new_game),
        .paddle_speed(paddle_speed),
        .puck_speed(puck_speed),
        .new_frame(new_frame_sig),
        .hcount(hcount),
        .vcount(vcount),
        .red(red),
        .green(green),
        .blue(blue)
    );

    // --- TMDS Encoders & Serializers ---
    wire [9:0] tmds_encoded [2:0];
    tmds_encoder enc_red   (.clk_in(pixel_clk), .rst_in(reset), .data_in(red),   .control_in(2'b00), .ve_in(activedraw_sig), .tmds_out(tmds_encoded[2]));
    tmds_encoder enc_green (.clk_in(pixel_clk), .rst_in(reset), .data_in(green), .control_in(2'b00), .ve_in(activedraw_sig), .tmds_out(tmds_encoded[1]));
    tmds_encoder enc_blue  (.clk_in(pixel_clk), .rst_in(reset), .data_in(blue),  .control_in({vsync_sig, hsync_sig}), .ve_in(activedraw_sig), .tmds_out(tmds_encoded[0]));

    wire [2:0] tmds_signal;
    tmds_serializer ser_red   (.clk_pixel_in(pixel_clk), .clk_5x_in(clk_125MHz), .rst_in(reset), .tmds_in(tmds_encoded[2]), .tmds_out(tmds_signal[2]));
    tmds_serializer ser_green (.clk_pixel_in(pixel_clk), .clk_5x_in(clk_125MHz), .rst_in(reset), .tmds_in(tmds_encoded[1]), .tmds_out(tmds_signal[1]));
    tmds_serializer ser_blue  (.clk_pixel_in(pixel_clk), .clk_5x_in(clk_125MHz), .rst_in(reset), .tmds_in(tmds_encoded[0]), .tmds_out(tmds_signal[0]));

    OBUFDS OBUFDS_blue  (.I(tmds_signal[0]), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
    OBUFDS OBUFDS_green (.I(tmds_signal[1]), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
    OBUFDS OBUFDS_red   (.I(tmds_signal[2]), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));
    OBUFDS obuf_clk     (.I(pixel_clk),      .O(hdmi_clk_p),    .OB(hdmi_clk_n));
    
endmodule