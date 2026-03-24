module pong (
    input  wire clk,               // Pixel clock
    input  wire reset,
    input  wire up,                // Left Paddle Up (BTN)
    input  wire down,              // Left Paddle Down (BTN)
    input  wire up_right,          // Right Paddle Up (SW0)
    input  wire down_right,        // Right Paddle Down (SW1)
    input  wire new_game,          // Restart game button
    input  wire [3:0] paddle_speed,// Speed from switches
    input  wire [3:0] puck_speed,  // Speed from switches
    input  wire new_frame,         // Pulse once per frame
    input  wire [9:0] hcount,
    input  wire [9:0] vcount,
    output wire [7:0] red_pong,
    output wire [7:0] green_pong,
    output wire [7:0] blue_pong,
    output reg game_over,
    output reg left_right_wins // 0: Left wins, 1: Right wins
);

//    localparam SCREEN_WIDTH  = 10;
//    localparam SCREEN_HEIGHT = 8;
//    localparam PADDLE_W = 1;
//    localparam PADDLE_H = 4;
//    localparam PUCK_W   = 2;
//    localparam PUCK_H   = 2;
//    localparam PADDLE_X_LEFT = 0;
//    localparam PADDLE_X_RIGHT = 6;

     localparam SCREEN_WIDTH  = 640;
     localparam SCREEN_HEIGHT = 480;
     localparam PADDLE_W = 10;
     localparam PADDLE_H = 100;
     localparam PUCK_W   = 32;
     localparam PUCK_H   = 32;
     localparam PADDLE_X_LEFT  = 10;
     localparam PADDLE_X_RIGHT = 620;

    // Position and Direction Registers
    reg [8:0] paddle_y_left, paddle_y_right, puck_y;
    reg [9:0] puck_x;
    reg [9:0] paddle_x_left = PADDLE_X_LEFT;
    reg [9:0] paddle_x_right = PADDLE_X_RIGHT;

    reg x_dir, y_dir; // 1: Right/Down, 0: Left/Up

    always @(posedge clk or posedge reset) begin
        if (reset || new_game) begin
//            paddle_y_left  <= 4;
//            paddle_y_right <= 0;
//            puck_x <= 4;
//            puck_y <= 1;
             paddle_y_left  <= 190;
             paddle_y_right <= 190;
             puck_x <= 304;
             puck_y <= 224;
            //Random start direction
            x_dir  <= hcount[0]; 
            y_dir  <= hcount[1];
            game_over <= 0;
        end else if (new_frame && !game_over) begin
            
            // -----------------------------
            // ---  LEFT PADDLE MOVEMENT ---
            // -----------------------------
            if (up && !down)
                paddle_y_left <= (paddle_y_left > paddle_speed) ? (paddle_y_left - paddle_speed) : 0;
            else if (down && !up)
                paddle_y_left <= (paddle_y_left + PADDLE_H + paddle_speed < SCREEN_HEIGHT) ? (paddle_y_left + paddle_speed) : (SCREEN_HEIGHT - PADDLE_H);

            // ------------------------------
            // ---  RIGHT PADDLE MOVEMENT ---
            // ------------------------------
            if (up_right && !down_right)
                paddle_y_right <= (paddle_y_right > paddle_speed) ? (paddle_y_right - paddle_speed) : 0;
            else if (down_right && !up_right)
                paddle_y_right <= (paddle_y_right + PADDLE_H + paddle_speed < SCREEN_HEIGHT) ? (paddle_y_right + paddle_speed) : (SCREEN_HEIGHT - PADDLE_H);

            // ---------------------
            // --- PUCK MOVEMENT ---
            // ---------------------
            // up and down movements
            if (y_dir) begin // Moving Down
                if (puck_y + PUCK_H + puck_speed < SCREEN_HEIGHT) begin
                    puck_y <= puck_y + puck_speed;
                end else begin 
                    puck_y <= SCREEN_HEIGHT - PUCK_H; 
                    y_dir <= 0; // Bounce Up
                end
            end else begin // Moving Up
                if (puck_y > puck_speed)  begin
                    puck_y <= puck_y - puck_speed;
                end else begin 
                    puck_y <= 0; 
                    y_dir <= 1; // Bounce Down
                end
            end

            // --- Horizontal Puck Movement & Collision ---
            if (x_dir) begin // Moving Right
                if (puck_x + PUCK_W + puck_speed <= PADDLE_X_RIGHT)
                    puck_x <= puck_x + puck_speed;
                else if (((puck_x + PUCK_W == PADDLE_X_RIGHT) && ((puck_y + PUCK_H >= paddle_y_right) && (puck_y <= paddle_y_right + PADDLE_H))) || 
                         (((puck_x + PUCK_W != PADDLE_X_RIGHT) && y_dir == 0) && ((puck_y - puck_speed + PUCK_H >= paddle_y_right) && (puck_y - puck_speed <= paddle_y_right + PADDLE_H))) || 
                         (((puck_x + PUCK_W != PADDLE_X_RIGHT) && y_dir == 1) && ((puck_y + puck_speed + PUCK_H >= paddle_y_right) && (puck_y + puck_speed <= paddle_y_right + PADDLE_H)))) begin
                  
                    puck_x <= PADDLE_X_RIGHT - PUCK_W;
                    x_dir <= 0; // Bounce Left
                end else begin
                    puck_x <= puck_x + puck_speed; // attach to the left side of the right paddle
                    game_over <= 1; //bounce left(not losing YET)
                    left_right_wins <= 0; // Left player wins
                end
            end else begin // Moving Left
                if (puck_x >= puck_speed + PADDLE_X_LEFT + PADDLE_W)
                    puck_x <= puck_x - puck_speed;
                else if (((puck_x == PADDLE_X_LEFT + PADDLE_W)  && ((puck_y + PUCK_H >= paddle_y_left) && (puck_y <= paddle_y_left + PADDLE_H)))     || 
                         (((puck_x != PADDLE_X_LEFT + PADDLE_W) && y_dir == 0) && ((puck_y - puck_speed + PUCK_H >= paddle_y_left) && (puck_y - puck_speed <= paddle_y_left + PADDLE_H))) || 
                         (((puck_x != PADDLE_X_LEFT + PADDLE_W) && y_dir == 1) && ((puck_y + puck_speed + PUCK_H >= paddle_y_left) && (puck_y + puck_speed <= paddle_y_left + PADDLE_H)))   ) begin
                   
                    puck_x <= PADDLE_X_LEFT + PADDLE_W; // attach to the right side of the left paddle
                    x_dir <= 1; //bounce right(not losing YET) 
                end else begin
                    puck_x <= puck_x - puck_speed;
                    game_over <= 1;
                    left_right_wins <= 1; // Right player wins
                end
            end
        end
    end

    // Sprite Rendering
    wire [7:0] r_p, g_p, b_p, r_l, g_l, b_l, r_r, g_r, b_r;
    block_sprite #(.SPRITE_WIDTH(PUCK_W), .SPRITE_HEIGHT(PUCK_H)) 
    puck_sp (.hcount_in(hcount), .vcount_in(vcount), .sprite_x(puck_x), .sprite_y(puck_y), .red_out(r_p), .green_out(g_p), .blue_out(b_p));
    
    block_sprite #(.SPRITE_WIDTH(PADDLE_W), .SPRITE_HEIGHT(PADDLE_H))
    pad_l (.hcount_in(hcount), .vcount_in(vcount), .sprite_x(paddle_x_left), .sprite_y(paddle_y_left), .red_out(r_l), .green_out(g_l), .blue_out(b_l));
    
    block_sprite #(.SPRITE_WIDTH(PADDLE_W), .SPRITE_HEIGHT(PADDLE_H)) 
    pad_r (.hcount_in(hcount), .vcount_in(vcount), .sprite_x(paddle_x_right), .sprite_y(paddle_y_right), .red_out(r_r), .green_out(g_r), .blue_out(b_r));

    assign red_pong   = r_p | r_l | r_r;
    assign green_pong = g_p | g_l | g_r;
    assign blue_pong  = b_p | b_l | b_r;

endmodule