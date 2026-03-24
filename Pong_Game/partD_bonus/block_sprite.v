module block_sprite #(
    parameter SPRITE_WIDTH = 32,
    parameter SPRITE_HEIGHT = 32
)(
    input  wire [9:0] hcount_in,
    input  wire [9:0]  vcount_in,
    input  wire [9:0] sprite_x,
    input  wire [8:0]  sprite_y,
    output reg  [7:0]  red_out,
    output reg  [7:0]  green_out,
    output reg  [7:0]  blue_out
);

    always @(sprite_x or sprite_y or hcount_in or vcount_in) begin
        if ((hcount_in >= sprite_x) && (hcount_in < sprite_x + SPRITE_WIDTH) &&
            (vcount_in >= sprite_y) && (vcount_in < sprite_y + SPRITE_HEIGHT)) begin
            red_out   = 8'hFF;
            green_out = 8'hFF;
            blue_out  = 8'hFF;
        end else begin
            red_out   = 8'h00;
            green_out = 8'h00;
            blue_out  = 8'h00;
        end
    end

endmodule