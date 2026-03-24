module Sync_2ff (
    input clk,
    input async_in, // asyncronous input signal 
    output reg  sync_out  // fixed input signal  
);
    reg sync_ff1;

    always @(posedge clk) begin
        sync_ff1  <= async_in;   // 1st flip flop
        sync_out  <= sync_ff1;   // 2nd flip flop
    end
endmodule