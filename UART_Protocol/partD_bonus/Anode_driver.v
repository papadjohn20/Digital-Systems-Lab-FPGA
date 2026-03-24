module Anode_driver(
    input clk,
    input reset,
    input debounce_button,
    input [3:0] counter,
    output reg [3:0] char,
    output reg an3, an2, an1, an0,
    input [7:0] data
);
    reg [2:0] button_counter;
    reg [3:0] message[0:3];
    reg [3:0] next_value;
    always @(posedge clk or posedge reset) begin
            if (reset) begin
                message[0]      <= 4'd0;
                message[1]      <= 4'd0;
                message[2]      <= 4'd0;
                message[3]      <= 4'd0;
                button_counter  <= 3'd0;
            end else begin
                if (debounce_button) begin
                    if (button_counter < 3)
                        button_counter <= button_counter + 1;
                    else
                        button_counter <= 0;
    
                    message[button_counter] <= next_value;
                end
            end
       end
       
       always @(data) begin
        case(data)
            8'b0011_0000: next_value = 4'h0;  // '0'
            8'b0011_0001: next_value = 4'h1;  // '1'
            8'b0011_0010: next_value = 4'h2;  // '2'
            8'b0011_0011: next_value = 4'h3;  // '3'
            8'b0011_0100: next_value = 4'h4;  // '4'
            8'b0011_0101: next_value = 4'h5;  // '5'
            8'b0011_0110: next_value = 4'h6;  // '6'
            8'b0011_0111: next_value = 4'h7;  // '7'
            8'b0011_1000: next_value = 4'h8;  // '8'
            8'b0011_1001: next_value = 4'h9;  // '9'
            8'b0110_0001: next_value = 4'hA;  // 'a'
            8'b0110_0010: next_value = 4'hB;  // 'b'
            8'b0110_0011: next_value = 4'hC;  // 'c'
            8'b0110_0100: next_value = 4'hD;  // 'd'
            8'b0110_0101: next_value = 4'hE;  // 'e'
            8'b0110_0110: next_value = 4'hF;  // 'f'
            default:      next_value = 4'h0;
        endcase
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
            default: begin {an3, an2, an1, an0} = 4'b1111; char = 0;   end
        endcase
    end
endmodule