module Anode_driver(
    input clk,
    input reset,
    input button,
    input delay_signal,
    input [3:0] counter,
    output reg [3:0] i,
    output reg [3:0] char,
    output reg an3, an2, an1, an0
);
    reg [3:0] message[0:15];
      always @(posedge clk or posedge reset) begin
        if (reset) begin
            i <= 0;
            message[0]  <= 4'd0;
            message[1]  <= 4'd1;
            message[2]  <= 4'd2;
            message[3]  <= 4'd3;
            message[4]  <= 4'd4;
            message[5]  <= 4'd5;
            message[6]  <= 4'd6;
            message[7]  <= 4'd7;
            message[8]  <= 4'd8;
            message[9]  <= 4'd9;
            message[10]  <= 4'd10;
            message[11]  <= 4'd11;
            message[12]  <= 4'd12;
            message[13]  <= 4'd13;
            message[14]  <= 4'd14;
            message[15]  <= 4'd15;
        end else if(delay_signal || button) begin
            i <= i + 1;
        end    
    end
    
    // anode/character selection logic
    always @(counter) begin
        case (counter)
            4'b0000: begin {an3, an2, an1, an0} = 4'b1111; char = message[i];     end
            4'b0001: begin {an3, an2, an1, an0} = 4'b1111; char = message[i+3];   end
            4'b0010: begin {an3, an2, an1, an0} = 4'b1110; char = message[i+3];   end // an0 = 0
            4'b0011: begin {an3, an2, an1, an0} = 4'b1111; char = message[i+3];   end 
            4'b0100: begin {an3, an2, an1, an0} = 4'b1111; char = message[i+3];   end 
            4'b0101: begin {an3, an2, an1, an0} = 4'b1111; char = message[i+2];   end 
            4'b0110: begin {an3, an2, an1, an0} = 4'b1101; char = message[i+2];   end // an1 = 0
            4'b0111: begin {an3, an2, an1, an0} = 4'b1111; char = message[i+2];   end 
            4'b1000: begin {an3, an2, an1, an0} = 4'b1111; char = message[i+2];   end 
            4'b1001: begin {an3, an2, an1, an0} = 4'b1111; char = message[i+1];   end 
            4'b1010: begin {an3, an2, an1, an0} = 4'b1011; char = message[i+1];   end // an2 = 0
            4'b1011: begin {an3, an2, an1, an0} = 4'b1111; char = message[i+1];   end 
            4'b1100: begin {an3, an2, an1, an0} = 4'b1111; char = message[i+1];   end 
            4'b1101: begin {an3, an2, an1, an0} = 4'b1111; char = message[i];     end 
            4'b1110: begin {an3, an2, an1, an0} = 4'b0111; char = message[i];     end // an3 = 0
            4'b1111: begin {an3, an2, an1, an0} = 4'b1111; char = message[i];     end 
        endcase
    end
endmodule
