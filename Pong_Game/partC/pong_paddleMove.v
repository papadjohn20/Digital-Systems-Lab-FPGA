module pong (
    input  wire clk,               // pixel clock
    input  wire reset,
    input  wire up,                
    input  wire down,              
    input  wire [3:0] paddle_speed, 
    input  wire new_frame,         
    input  wire [9:0] hcount,
    input  wire [9:0] vcount,
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue
);

    localparam SCREEN_HEIGHT = 8;
    localparam PUCK_H = 2; //32
    localparam PUCK_W = 2; //32
    localparam PADDLE_H = 4; //100
    localparam PADDLE_W = 2; //10
    
    //(640x480)
//     localparam SCREEN_HEIGHT = 480;
//     localparam PADDLE_W = 10;
//     localparam PADDLE_H = 100;
//     localparam PUCK_W   = 32;
//     localparam PUCK_H   = 32;
    
    wire [9:0] puck_x = 10'd5;
    wire [8:0] puck_y = 10'd2;
//     reg [9:0] puck_x = 10'd304;
//     reg [8:0] puck_y = 10'd224;
    
    reg [9:0] paddle_x = 10'd2;
    reg [8:0] paddle_y = 10'd1;
//     reg [9:0] paddle_x = 10'd10;
//     reg [8:0] paddle_y = 10'd190; 

    // --- Paddle movement --- 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            paddle_y <= 10'd2;
//            paddle_y <= 10'd190;
        end else if (new_frame) begin
            if (up && !down) begin
                if (paddle_y > paddle_speed)
                    paddle_y <= paddle_y - paddle_speed;
                else
                    paddle_y <= 0;  
            end 
            else if (down && !up) begin
                if (paddle_y + PADDLE_H + paddle_speed < SCREEN_HEIGHT)
                    paddle_y <= paddle_y + paddle_speed;
                else
                    paddle_y <= SCREEN_HEIGHT - PADDLE_H; 
            end
        end
    end

    // --- Sprites ---
    wire [7:0] r_puck, g_puck, b_puck;
    wire [7:0] r_paddle, g_paddle, b_paddle;

    block_sprite #(.SPRITE_WIDTH(PUCK_W), .SPRITE_HEIGHT(PUCK_H)) 
    puck_inst (
        .hcount_in(hcount),
        .vcount_in(vcount),
        .sprite_x(puck_x),
        .sprite_y(puck_y),
        .red_out(r_puck),
        .green_out(g_puck),
        .blue_out(b_puck)
    );

    block_sprite #(.SPRITE_WIDTH(PADDLE_W), .SPRITE_HEIGHT(PADDLE_H))
    paddle_inst (
        .hcount_in(hcount),
        .vcount_in(vcount),
        .sprite_x(paddle_x),
        .sprite_y(paddle_y),
        .red_out(r_paddle),
        .green_out(g_paddle),
        .blue_out(b_paddle)
    );

    assign red   = r_puck | r_paddle;
    assign green = g_puck | g_paddle;
    assign blue  = b_puck | b_paddle;

endmodule