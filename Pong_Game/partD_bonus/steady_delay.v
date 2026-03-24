module steady_delay (
    input wire clk,
    output reg  delay_signal // when is 1 i++
);
    //parameter COUNT_MAX = 8388607; //  1,67772145s/0.0000002s = 8388607
    parameter COUNT_MAX = 20; //  2us/0.2us = 10
    reg [22:0] count = 0;
    
    always @(posedge clk) begin
        count <= count + 1;
        if (count >= COUNT_MAX-1) begin
            delay_signal <= 1;
            count <= 0;
        end
        else delay_signal <= 0;
    end

endmodule