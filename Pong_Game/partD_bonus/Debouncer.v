module Debouncer (
    input  wire clk,
    input  wire btn_in,      // raw button from board (active high)
    output reg  btn_out    // debounced signal
);
    parameter COUNT_MAX = 400_000;  
    // parameter COUNT_MAX = 10; // 
    reg [$clog2(COUNT_MAX):0] count = 0;
    reg state = 1'b0;
    reg temp = 1'b0;

    always @(posedge clk) begin
        
        if (btn_in != state) begin
            count <= count + 1;
            if (count >= COUNT_MAX-1) begin
                state <= btn_in;
                count <= 0;
            end
        end else begin
            count <= 0;
            state <= 0;          
        end
    end

    always @(state) begin
        btn_out <= state;
    end
endmodule