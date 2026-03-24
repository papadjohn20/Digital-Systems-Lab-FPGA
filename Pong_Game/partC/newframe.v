module newframe (
    input clk,
    input reset,
    input [9:0] hcount,
    input [9:0] vcount,
    output reg new_frame_sig,
    output reg LD0
);
    always @(posedge clk or posedge reset) begin
        if (reset) 
            new_frame_sig <= 1'b0;
        else if (hcount == 10'd9 && vcount == 10'd7) begin 
            new_frame_sig <= 1'b1;
        end else begin
            new_frame_sig <= 1'b0;
        end
    end

    // Counter to toggle LED every 60 frames
    reg [5:0] frame_counter = 0;
    
    always @(new_frame_sig) begin
        if (new_frame_sig) begin
            if (frame_counter == 6'd59) begin
                frame_counter = 6'd0;
                LD0 = 1;  // LED on
            end else begin
                frame_counter = frame_counter + 1'b1;
                LD0 = 0;
            end
        end
    end
endmodule