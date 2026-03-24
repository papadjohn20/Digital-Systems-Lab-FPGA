`timescale 1ns / 1ps
module tmds_encoder (
    input         clk_in,
    input         rst_in,
    input  [7:0]  data_in,
    input  [1:0]  control_in,
    input         ve_in, // video data enable
    output reg  [9:0]  tmds_out
);

    // Condition (1) 
    wire [8:0] q_m;
    tm_choice tm_choice_inst(
        .data_in(data_in),
        .q_m(q_m)
    );

    reg signed [4:0] tally;   

    // Count ones and zeros in q_m[7:0]
    wire [3:0] ones_qm  = q_m[0] + q_m[1] + q_m[2] + q_m[3] +
                          q_m[4] + q_m[5] + q_m[6] + q_m[7];
    wire [3:0] zeros_qm = 8 - ones_qm;
    
    reg [2:0] condition;
    reg true;
    always @(posedge clk_in or posedge rst_in) begin
        if (rst_in) begin
            tally    <= 0;
            tmds_out <= 10'b0000000000;

        end else if (!ve_in) begin
            // Control_in dictates what will the output be
            tally <= 0;

            case (control_in)
                2'b00: tmds_out <= 10'b1101010100;
                2'b01: tmds_out <= 10'b0010101011;
                2'b10: tmds_out <= 10'b0101010100;
                2'b11: tmds_out <= 10'b1010101011;
            endcase

        end else begin
            // Condition (2) in the flowchart:
            if ((tally == 0) || (ones_qm == zeros_qm) ) begin
                // Condition (2) TRUE
                condition <= 2;
                true <= 1;
                tmds_out[9]   <= !q_m[8];
                tmds_out[8]   <= q_m[8];

                // Condition (4)
                if (q_m[8] == 0) begin
                    tmds_out[7:0] <= ~q_m[7:0];
                    tally <= tally + (zeros_qm - ones_qm);

                end else begin // q_m[8] == 1
                    tmds_out[7:0] <= q_m[7:0];
                    tally <= tally + (ones_qm - zeros_qm);
                end

            end else begin
                // Condition (2) FALSE go to Condition (3)
                condition <= 3;
                if ((tally > 0 && ones_qm > zeros_qm) ||
                    (tally < 0 && ones_qm < zeros_qm) ) begin
                    true <= 1;
                    // Condition (3) TRUE
                    tmds_out[9]   <= 1'b1;
                    tmds_out[8]   <= q_m[8];
                    tmds_out[7:0] <= ~q_m[7:0];
                    tally <= tally + 2*q_m[8] + (zeros_qm - ones_qm);

                end else begin
                    // Condition (3) FALSE
                    true <= 0;
                    tmds_out[9]   <= 1'b0;
                    tmds_out[8]   <= q_m[8];
                    tmds_out[7:0] <= q_m[7:0];
                    tally <= tally - 2*(!q_m[8]) + (ones_qm - zeros_qm);
                end
            end
        end
    end

endmodule