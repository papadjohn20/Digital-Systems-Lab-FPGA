module pong (
    input  wire clk,               // pixel clock
    input  wire reset,
    input  wire up,                
    input  wire down,              
    input  wire new_game,          
    input  wire [3:0] paddle_speed,
    input  wire [3:0] puck_speed,  
    input  wire new_frame,         
    input  wire [9:0] hcount,
    input  wire [9:0] vcount,
    output wire [7:0] red,
    output wire [7:0] green,
    output wire [7:0] blue
);

    localparam SCREEN_WIDTH  = 10;
    localparam SCREEN_HEIGHT = 8;
    localparam PADDLE_W = 2;
    localparam PADDLE_H = 4;
    localparam PUCK_W   = 2;
    localparam PUCK_H   = 2;
    localparam PADDLE_X = 1;
    
    //(640x480)
//     localparam SCREEN_WIDTH  = 640;
//     localparam SCREEN_HEIGHT = 480;
//     localparam PADDLE_W = 10;
//     localparam PADDLE_H = 100;
//     localparam PUCK_W   = 32;
//     localparam PUCK_H   = 32;
//     localparam PADDLE_X = 10;

    reg [8:0] paddle_y, puck_y;
    reg [9:0] puck_x;
    reg [9:0] paddle_x = PADDLE_X;
    reg x_dir, y_dir; // 1: Right/Down, 0: Left/Up
    reg game_over;

    always @(posedge clk or posedge reset) begin
        if (reset || new_game) begin
            paddle_y <= 4;
            puck_x   <= 5;
            puck_y   <= 4;
//            paddle_y <= 190;
//            puck_x   <= 304;
//            puck_y   <= 224;
            //Random start direction
            x_dir    <= hcount[0];
            y_dir    <= hcount[1];
            game_over <= 0;
        end else if (new_frame && !game_over) begin
            
            // -----------------------
            // --- PADDLE MOVEMENT ---
            // -----------------------
            if (up && !down)
                paddle_y <= (paddle_y > paddle_speed) ? (paddle_y - paddle_speed) : 0;
            else if (down && !up)
                paddle_y <= (paddle_y + PADDLE_H + paddle_speed < SCREEN_HEIGHT) ? 
                             (paddle_y + paddle_speed) : (SCREEN_HEIGHT - PADDLE_H);
            
            // ---------------------
            // --- PUCK MOVEMENT ---
            // ---------------------
            // up and down movements
            if (y_dir) begin //if moving down
                if (puck_y + PUCK_H + puck_speed < SCREEN_HEIGHT) begin
                    puck_y <= puck_y + puck_speed;
                end else begin
                    puck_y <= SCREEN_HEIGHT - PUCK_H;
                    y_dir <= 0; //bounce up
                end
            end else begin //if moving up
                if (puck_y > puck_speed) begin
                    puck_y <= puck_y - puck_speed;
                end else begin
                    puck_y <= 0;
                    y_dir <= 1; // bounce down 
                end
            end

            // right and left movements
            if (x_dir) begin //if moving right
                if (puck_x + PUCK_W + puck_speed < SCREEN_WIDTH)
                    puck_x <= puck_x + puck_speed;
                else begin 
                    puck_x <= SCREEN_WIDTH - PUCK_W;
                    x_dir <= 0; //bounce left
                end
            end else begin //if moving left
                if (puck_x >= puck_speed + PADDLE_X + PADDLE_W)
                    puck_x <= puck_x - puck_speed; // move left normally
                else if (((puck_x == PADDLE_X + PADDLE_W)  && ((puck_y + PUCK_H >= paddle_y) && (puck_y <= paddle_y + PADDLE_H)))        || 
                         (((puck_x != PADDLE_X + PADDLE_W) && y_dir == 0) && ((puck_y - puck_speed + PUCK_H >= paddle_y) && (puck_y - puck_speed <= paddle_y + PADDLE_H))) || 
                         (((puck_x != PADDLE_X + PADDLE_W) && y_dir == 1) && ((puck_y + puck_speed + PUCK_H >= paddle_y) && (puck_y + puck_speed <= paddle_y + PADDLE_H)))   ) begin
                    
                            puck_x <= PADDLE_X + PADDLE_W; // attach to the right side of the paddle
                            x_dir <= 1; //bounce right(not losing YET) 
                end else begin
                    puck_x <= puck_x - puck_speed; 
                    game_over <= 1;
                end
            end
        end
    end

    wire [7:0] r_puck, g_puck, b_puck, r_pad, g_pad, b_pad;

    block_sprite #(.SPRITE_WIDTH(PUCK_W), .SPRITE_HEIGHT(PUCK_H))
    puck_sprite (.hcount_in(hcount), .vcount_in(vcount), .sprite_x(puck_x), .sprite_y(puck_y),
                 .red_out(r_puck), .green_out(g_puck), .blue_out(b_puck));

    block_sprite #(.SPRITE_WIDTH(PADDLE_W), .SPRITE_HEIGHT(PADDLE_H))
    paddle_sprite (.hcount_in(hcount), .vcount_in(vcount), .sprite_x(paddle_x), .sprite_y(paddle_y),
                   .red_out(r_pad), .green_out(g_pad), .blue_out(b_pad));

    assign red   = r_puck | r_pad;
    assign green = g_puck | g_pad;
    assign blue  = b_puck | b_pad;

endmodule