module HDMI_controller(
    input  wire clk,          
    input  wire reset,        // BTN0
    input  wire up,           // BTN2
    input  wire down,         // BTN3
    input  wire up_right,     // SW0 for Right Paddle
    input  wire down_right,   // SW1 for Right Paddle
    input  wire new_game,     // BTN1
    input  wire [3:0] paddle_speed, // SW12-SW15
    input  wire [3:0] puck_speed,   // SW8-SW11 
    output wire hdmi_clk_p,
    output wire hdmi_clk_n,
    output wire [2:0] hdmi_tx_p,
    output wire [2:0] hdmi_tx_n,
    output wire LD0,
    output wire an3, an2, an1, an0,
    output wire a, b, c, d, e, f, g, dp
);

    wire activedraw_sig, hsync_sig, vsync_sig;
    wire [2:0] left_rgb, right_rgb;
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
        .clk_125MHz(clk_125MHz),
        .left_rgb(left_rgb),
        .right_rgb(right_rgb)
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
    
    wire game_over, left_right_wins, match_over;
    FourDigitLEDdriver FourDigitLEDdriver_inst (
        .clk(clk),
        .reset(reset),
        .game_over(game_over),
        .left_right_wins(left_right_wins),
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
        .dp(dp),
        .match_over(match_over)
    );

    wire [7:0] red_pong, green_pong, blue_pong;
    wire reset_game = reset | match_over; // reset game on reset signal OR on match over
    pong game_inst (
        .clk(pixel_clk),
        .reset(reset),
        .up(up),
        .down(down),
        .up_right(up_right),
        .down_right(down_right),
        .new_game(new_game),
        .paddle_speed(paddle_speed),
        .puck_speed(puck_speed),
        .new_frame(new_frame_sig),
        .hcount(hcount),
        .vcount(vcount),
        .red_pong(red_pong),
        .green_pong(green_pong),
        .blue_pong(blue_pong),
        .game_over(game_over),
        .left_right_wins(left_right_wins)
    );
    //left vram has one green pixel at the start and the right vram has one blue pixel at the start
    // We did this so that we could distinguish which vram was used, in small simulations
    
    //----------------------------------------------------
    // 2. Expand VRAM 3-bit output into 8-bit color channels
    //----------------------------------------------------
    wire [7:0] red   = (game_over) ? ((left_right_wins) ? {8{right_rgb[2]}} : {8{left_rgb[2]}}) : red_pong;
    wire [7:0] green = (game_over) ? ((left_right_wins) ? {8{right_rgb[1]}} : {8{left_rgb[1]}}) : green_pong;
    wire [7:0] blue  = (game_over) ? ((left_right_wins) ? {8{right_rgb[0]}} : {8{left_rgb[0]}}) : blue_pong;


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