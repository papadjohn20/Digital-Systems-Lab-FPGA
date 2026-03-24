`timescale 1ns/1ps
module tm_choice (
    input  wire [7:0] data_in,
    output wire [8:0] q_m
);

    // Count ones
    wire [3:0] ones = data_in[0] + data_in[1] + data_in[2] + data_in[3] 
                     + data_in[4] + data_in[5] + data_in[6] + data_in[7];

    // Choose XNOR path (Option 2)
    wire use_xnor = (ones > 4) || (ones == 4 && data_in[0] == 1'b0);

    // Generate q_m[1]..q_m[7] depending on XOR/XNOR
    assign q_m[0] = data_in[0];
    assign q_m[1] = use_xnor ? !(data_in[1] ^ data_in[0]) : (data_in[1] ^ data_in[0]);
    assign q_m[2] = use_xnor ? !(data_in[2] ^ q_m[1]) : (data_in[2] ^ q_m[1]);
    assign q_m[3] = use_xnor ? !(data_in[3] ^ q_m[2]) : (data_in[3] ^ q_m[2]);
    assign q_m[4] = use_xnor ? !(data_in[4] ^ q_m[3]) : (data_in[4] ^ q_m[3]);
    assign q_m[5] = use_xnor ? !(data_in[5] ^ q_m[4]) : (data_in[5] ^ q_m[4]);
    assign q_m[6] = use_xnor ? !(data_in[6] ^ q_m[5]) : (data_in[6] ^ q_m[5]);
    assign q_m[7] = use_xnor ? !(data_in[7] ^ q_m[6]) : (data_in[7] ^ q_m[6]);

    // MSB: 1 for XOR (option 1), 0 for XNOR (option 2)
    assign q_m[8] = !use_xnor;

endmodule
