module baud_controller(
    input  reset,
    input  clk,           // 100 MHz clock
    input  [2:0]  baud_select,   // Selects one of 8 baud rates
    output reg sample_ENABLE  // One-cycle enable pulse
);

// Baud rate table (4 * Baud_rate)
// counter_limit = 100e6 / (4 * Baud_rate)
reg [31:0] counter_limit;
reg [31:0] counter;

always @(*) begin
    case (baud_select)
        3'b000: counter_limit = 83333;  // 300 baud
        3'b001: counter_limit = 20833;  // 1200 baud
        3'b010: counter_limit = 5208;   // 4800 baud
        3'b011: counter_limit = 2604;   // 9600 baud
        3'b100: counter_limit = 1302;   // 19200 baud
        3'b101: counter_limit = 651;    // 38400 baud
        3'b110: counter_limit = 434;    // 57600 baud
        3'b111: counter_limit = 217;    // 115200 baud
        default: counter_limit = 83333;
    endcase
end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 0;
            sample_ENABLE <= 0;
        end else begin
            if (counter >= counter_limit) begin
                counter <= 0;
                sample_ENABLE <= 1'b1;  // Pulse high for one clock cycle
            end else begin
                counter <= counter + 1'b1;
                sample_ENABLE <= 1'b0;
            end
        end
    end
endmodule
