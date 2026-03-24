module Debouncer (
    input  wire clk,
    input  wire btn_in,      // raw button from board (active high)
    output reg  btn_out    // debounced signal
);
    parameter COUNT_MAX = 25000; //  5 ms at 5 MHz  0.005s/0.0000002s=25,000
    reg [$clog2(COUNT_MAX):0] count = 0;
    reg stable_state = 1'b0;

    always @(posedge clk) begin
        if (btn_in != stable_state) begin
            count <= count + 1;
            if (count >= COUNT_MAX) begin
                stable_state <= btn_in;
                count <= 0;
            end
        end else begin
            count <= 0;
        end
    end

    always @(*) begin
        btn_out = stable_state;
    end
endmodule