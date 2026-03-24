module Anode_driver(
    input [3:0] counter,
    output reg [3:0] char,
    output reg an3, an2, an1, an0
);
    // anode/character selection logic
    always @(counter) begin
        case (counter)
            4'b0000: begin {an3, an2, an1, an0} = 4'b1111; char = 0;   end
            4'b0001: begin {an3, an2, an1, an0} = 4'b1111; char = 3;   end
            4'b0010: begin {an3, an2, an1, an0} = 4'b1110; char = 3;   end // an0 = 0
            4'b0011: begin {an3, an2, an1, an0} = 4'b1111; char = 3;   end 
            4'b0100: begin {an3, an2, an1, an0} = 4'b1111; char = 3;   end 
            4'b0101: begin {an3, an2, an1, an0} = 4'b1111; char = 2;   end 
            4'b0110: begin {an3, an2, an1, an0} = 4'b1101; char = 2;   end // an1 = 0
            4'b0111: begin {an3, an2, an1, an0} = 4'b1111; char = 2;   end 
            4'b1000: begin {an3, an2, an1, an0} = 4'b1111; char = 2;   end 
            4'b1001: begin {an3, an2, an1, an0} = 4'b1111; char = 1;   end 
            4'b1010: begin {an3, an2, an1, an0} = 4'b1011; char = 1;   end // an2 = 0
            4'b1011: begin {an3, an2, an1, an0} = 4'b1111; char = 1;   end 
            4'b1100: begin {an3, an2, an1, an0} = 4'b1111; char = 1;   end 
            4'b1101: begin {an3, an2, an1, an0} = 4'b1111; char = 0;   end 
            4'b1110: begin {an3, an2, an1, an0} = 4'b0111; char = 0;   end // an3 = 0
            4'b1111: begin {an3, an2, an1, an0} = 4'b1111; char = 0;   end
            default: begin {an3, an2, an1, an0} = 4'b1111; char = 0;   end
        endcase
    end
endmodule