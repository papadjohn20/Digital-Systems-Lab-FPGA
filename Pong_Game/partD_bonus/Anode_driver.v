module Anode_driver(
    input clk,
    input reset,
    input game_over, // uses this to determine if the game is over
    input left_right_wins, // uses this to determine which player won
    input [3:0] counter,
    output reg [3:0] char,
    output reg an3, an2, an1, an0,
    output reg match_over
);
    reg [3:0] message[0:3];
    reg prev_game_over;
    always @(posedge clk or posedge reset) begin
            if (reset) begin
                message[0]      <= 4'd0;
                message[1]      <= 4'b0100; // '-'
                message[2]      <= 4'd0;
                message[3]      <= 4'd6;
                prev_game_over  <= 1'b0;
                match_over      <= 1'b0;
            end else begin
                // Update scores when game is over
                // Only increment on the rising edge of game_over
                if (game_over && !prev_game_over) begin
                    if (left_right_wins)
                        message[2] <= message[2] + 1; // Right player score
                    else
                        message[0] <= message[0] + 1; // Left player score
                end
                // detect match end: any side reached 3
                if ((message[0] >= 4'd3) || (message[2] >= 4'd3)) begin
                    match_over <= 1'b1;
                end else if (game_over && !prev_game_over) begin
                    // predict the increment outcome
                    if (left_right_wins) begin
                        if (message[2] + 1 == 4'd3) match_over <= 1'b1;
                    end else begin
                        if (message[0] + 1 == 4'd3) match_over <= 1'b1;
                    end
                end
                prev_game_over <= game_over;

                // If match is over, display "0 - 0"
                if (match_over) begin
                    message[0] <= 4'd0;
                    message[1] <= 4'b0100; // '-'
                    message[2] <= 4'd0;
                    message[3] <= 4'd6;
                end
            end
       end

    // anode/character selection logic
    always @(counter) begin
        case (counter)
            4'b0000: begin {an3, an2, an1, an0} = 4'b1111; char = message[0];   end
            4'b0001: begin {an3, an2, an1, an0} = 4'b1111; char = message[3];   end
            4'b0010: begin {an3, an2, an1, an0} = 4'b1110; char = message[3];   end // an0 = 0
            4'b0011: begin {an3, an2, an1, an0} = 4'b1111; char = message[3];   end 
            4'b0100: begin {an3, an2, an1, an0} = 4'b1111; char = message[3];   end 
            4'b0101: begin {an3, an2, an1, an0} = 4'b1111; char = message[2];   end 
            4'b0110: begin {an3, an2, an1, an0} = 4'b1101; char = message[2];   end // an1 = 0
            4'b0111: begin {an3, an2, an1, an0} = 4'b1111; char = message[2];   end 
            4'b1000: begin {an3, an2, an1, an0} = 4'b1111; char = message[2];   end 
            4'b1001: begin {an3, an2, an1, an0} = 4'b1111; char = message[1];   end 
            4'b1010: begin {an3, an2, an1, an0} = 4'b1011; char = message[1];   end // an2 = 0
            4'b1011: begin {an3, an2, an1, an0} = 4'b1111; char = message[1];   end 
            4'b1100: begin {an3, an2, an1, an0} = 4'b1111; char = message[1];   end 
            4'b1101: begin {an3, an2, an1, an0} = 4'b1111; char = message[0];   end 
            4'b1110: begin {an3, an2, an1, an0} = 4'b0111; char = message[0];   end // an3 = 0
            4'b1111: begin {an3, an2, an1, an0} = 4'b1111; char = message[0];   end
            default: begin {an3, an2, an1, an0} = 4'b1111; char = 0;            end
        endcase
    end
endmodule