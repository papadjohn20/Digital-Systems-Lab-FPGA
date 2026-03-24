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
    wire [9:0] hcount, vcount;
    wire pixel_clk;           // 25.175 MHz
    wire clk_125MHz;          // 125.875 MHz (pixel × 5)

    lab3PartB lab3PartB_inst (
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

    reg [9:0] puck_x = 10'd5;
    reg [8:0] puck_y = 10'd2;
//     reg [9:0] puck_x = 10'd304;
//     reg [8:0] puck_y = 10'd224;
    wire [7:0] red_puck;
    wire [7:0] green_puck;
    wire [7:0] blue_puck;
    block_sprite #(.SPRITE_WIDTH(2), .SPRITE_HEIGHT(2)) 
    puck_inst (
        .hcount_in(hcount),
        .vcount_in(vcount),
        .sprite_x(puck_x),
        .sprite_y(puck_y),
        .red_out(red_puck),
        .green_out(green_puck),
        .blue_out(blue_puck)
    );

    reg [9:0] paddle_x = 10'd2;
    reg [8:0] paddle_y = 10'd2;
//     reg [9:0] paddle_x = 10'd10;
//     reg [8:0] paddle_y = 10'd190;
    wire [7:0] red_paddle;
    wire [7:0] green_paddle;
    wire [7:0] blue_paddle;
    block_sprite #(.SPRITE_WIDTH(2), .SPRITE_HEIGHT(4))
    paddle_inst (
        .hcount_in(hcount),
        .vcount_in(vcount),
        .sprite_x(paddle_x),
        .sprite_y(paddle_y),
        .red_out(red_paddle),
        .green_out(green_paddle),
        .blue_out(blue_paddle)
    );

    wire [7:0] red = red_puck | red_paddle;
    wire [7:0] green = green_puck | green_paddle;
    wire [7:0] blue = blue_puck | blue_paddle;


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

    OBUFDS OBUFDS_blue (.I(tmds_signal[0]), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
    OBUFDS OBUFDS_green(.I(tmds_signal[1]), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
    OBUFDS OBUFDS_red (.I(tmds_signal[2]), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));

    OBUFDS obuf_clk (.I(pixel_clk), .O(hdmi_clk_p), .OB(hdmi_clk_n));

endmodule
