`timescale 1ns/1ps
module uart_receiver (
    input              clk,
    input              reset,
    input       [2:0]  baud_select,
    input              Rx_EN,
    input              RxD,         // incoming serial line (async)
    output reg  [7:0]  Rx_DATA,     // received byte
    output reg         Rx_VALID,    // data valid flag (1 cycle if no errors)
    output reg         Rx_PERROR,   // parity error
    output reg         Rx_FERROR    // framing / sampling error
);

    // -------------------------------------------------------------------------
    // Instantiated modules
    // -------------------------------------------------------------------------
    wire Rx_sample_ENABLE;
    baud_controller baud_ctrl_rx_inst (
        .reset(reset),
        .clk(clk),
        .baud_select(baud_select),
        .sample_ENABLE(Rx_sample_ENABLE)
    );

    wire RxD_sync;
    Sync_2ff Rx_sync_inst (
        .clk(clk),
        .async_in(RxD),
        .sync_out(RxD_sync)
    );

    // -------------------------------------------------------------------------
    // Parity function (even parity helper)
    // -------------------------------------------------------------------------
    function automatic parity_even;
        input [7:0] data;
        integer i;
        reg parity;
        begin
            parity = 1'b0;
            for (i = 0; i < 8; i = i + 1)
                parity = parity ^ data[i];
            parity_even = parity;  // 1 if odd, 0 if even
        end
    endfunction

    // -------------------------------------------------------------------------
    // FSM state encoding (3-bit as before)
    // -------------------------------------------------------------------------
    localparam IDLE   = 3'b000,
               START  = 3'b001,
               DATA   = 3'b010,
               PARITY = 3'b011,
               STOP   = 3'b100;
    // Current state register
    reg [2:0] current_state, next_state;

    // Registered "current" datapath values
    reg [3:0] sample_count;    // (16 samples per bit)
    reg [2:0] bit_index;       // 0..7 for data bits
    reg [7:0] data;            // shift register for received data (internal)
    reg prev_sample;           // previous sample (holds last sampled RxD_sync)
    reg mid_sample;            // sample #10


    // "next" datapath signals (combinational outputs of next-state logic)
    reg [3:0] next_sample_count;
    reg [2:0] next_bit_index;
    reg [7:0] next_data;
    reg       next_prev_sample;
    reg       next_mid_sample;
    reg [7:0] next_Rx_DATA;
    reg       next_Rx_VALID;
    reg       next_Rx_PERROR;
    reg       next_Rx_FERROR;

    // ---------------------------------------------------------------------
    // SEQUENTIAL BLOCK
    // ---------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            sample_count  <= 0;
            bit_index     <= 0;
            data          <= 0;
            prev_sample   <= 1'b1;     // idle line is high
            mid_sample    <= 1'b1;
            Rx_DATA       <= 8'b0;
            Rx_VALID      <= 1'b0;
            Rx_PERROR     <= 1'b0;
            Rx_FERROR     <= 1'b0;
        end else begin
            // latch next-state results
            current_state <= next_state;
            sample_count  <= next_sample_count;
            bit_index     <= next_bit_index;
            data          <= next_data;
            prev_sample   <= next_prev_sample;
            mid_sample    <= next_mid_sample;
            Rx_DATA       <= next_Rx_DATA;
            Rx_VALID      <= next_Rx_VALID;
            Rx_PERROR     <= next_Rx_PERROR;
            Rx_FERROR     <= next_Rx_FERROR;
        end
    end
    
    // ---------------------------------------------------------------------
    // COMBINATIONAL BLOCK
    // ---------------------------------------------------------------------
    always @(current_state or Rx_EN or Rx_sample_ENABLE or RxD_sync
             or sample_count or bit_index or data or prev_sample or mid_sample
             or Rx_DATA or Rx_VALID or Rx_PERROR or Rx_FERROR) begin

        // Default: hold current values (prevents inferred latches)
        next_state        = current_state;
        next_sample_count = sample_count;
        next_bit_index    = bit_index;
        next_data         = data;
        next_prev_sample  = prev_sample;
        next_mid_sample   = mid_sample;


        // default outputs to hold previous registered values 
        next_Rx_DATA      = Rx_DATA;      // (Rx_DATA is updated only when valid)  
        next_Rx_VALID     = 1'b0;         // default 0 (pulse when new data available)
        next_Rx_PERROR    = Rx_PERROR;
        next_Rx_FERROR    = Rx_FERROR;

        // If receiver not enabled, stay/reset to IDLE and clear valid/errors
        if (!Rx_EN) begin
            next_state        = IDLE;
            next_sample_count = 0;
            next_bit_index    = 0;
            next_data         = 8'b0;
            next_prev_sample  = 1'b1;
            next_mid_sample   = 1'b1;
            next_Rx_VALID     = 1'b0;
            next_Rx_PERROR    = 1'b0;
            next_Rx_FERROR    = 1'b0;
        end else begin
            // Rx_EN is asserted -> normal FSM operation
            case (current_state)
                // ---------------------------------------------------------
                IDLE: begin
                    // Clear valid and errors in IDLE
                    next_Rx_VALID  = 1'b0;
                    next_Rx_PERROR = 1'b0;
                    next_Rx_FERROR = 1'b0;

                    next_sample_count = 0;
                    next_bit_index    = 0;
                    next_data         = 8'b0;
                    next_mid_sample   = 1'b1;

                    next_prev_sample  = prev_sample;

                    if (!RxD_sync) begin
                        // detected falling edge -> possible start
                        next_state        = START;
                        next_sample_count = 0;
                        next_prev_sample  = RxD_sync; // initialize prev_sample with first sample
                        // carry over errors cleared above
                    end
                end

                // ---------------------------------------------------------
                START: begin
                    // sample on every Rx_sample_ENABLE pulse
                    if (Rx_sample_ENABLE) begin
                        // Compare only the middle samples (7-10)
                        if ((sample_count >= 7 && sample_count <= 10) && (RxD_sync ^ prev_sample)) begin
                            next_Rx_FERROR = 1'b1;
                            next_state = IDLE;
                        end else begin
                            next_Rx_FERROR = Rx_FERROR;
                        end

                        next_prev_sample = RxD_sync;
                        // Update mid_sample at sample#10
                        if (sample_count == 10)
                            next_mid_sample = RxD_sync;

                        if (sample_count >= 15) begin
                            // completed 15 samples for start bit
                            next_sample_count = 0;
                            // if no sampling error and the sampled line is still low -> valid start
                            if (!next_Rx_FERROR && !mid_sample) begin
                                next_state     = DATA;
                                next_bit_index = 0;
                                next_data      = 8'b0;
                            end 
                        end else begin
                            next_sample_count = sample_count + 1;
                        end
                    end
                end

                // ---------------------------------------------------------
                DATA: begin
                    if (Rx_sample_ENABLE) begin
                        // Compare only the middle samples (7-10)
                        if ((sample_count >= 7 && sample_count <= 10) && (RxD_sync ^ prev_sample)) begin
                            next_Rx_FERROR = 1'b1;
                            next_state = IDLE;
                        end else begin
                            next_Rx_FERROR = Rx_FERROR;
                        end

                        next_prev_sample = RxD_sync;

                        // Update mid_sample at sample#10
                        if (sample_count == 10)
                            next_mid_sample = RxD_sync;

                        if (sample_count >= 15) begin
                            // after 15 sub-samples: latch bit = prev_sample (the last registered sample)
                            next_sample_count = 0;
                            next_data[bit_index] = mid_sample;
                            if (bit_index == 7) begin
                                next_state = PARITY;
                            end else begin
                                next_bit_index = bit_index + 1;
                            end
                        end else begin
                            next_sample_count = sample_count + 1;
                        end
                    end
                end

                // ---------------------------------------------------------
                PARITY: begin
                    if (Rx_sample_ENABLE) begin
                        // check mismatch with previous sample
                        if ((sample_count >= 7 && sample_count <= 10) && (RxD_sync ^ prev_sample)) begin
                            next_Rx_FERROR = 1'b1;
                            next_state = IDLE;
                        end else begin
                            next_Rx_FERROR = Rx_FERROR;
                        end

                        next_prev_sample = RxD_sync;
                        
                        if (sample_count == 10)
                            next_mid_sample = RxD_sync;

                        if (sample_count >= 15) begin
                            next_sample_count = 0;
                            // parity check: even parity -> parity bit must equal ~parity_even(data)
                            if (mid_sample != !parity_even(data)) begin
                                next_Rx_PERROR = 1'b1;
                                next_state = IDLE;
                            end else begin
                                next_Rx_PERROR = 1'b0;
                                next_state = STOP;
                            end
                        end else begin
                            next_sample_count = sample_count + 1;
                        end
                    end
                end

                // ---------------------------------------------------------
                STOP: begin
                    if (Rx_sample_ENABLE) begin
                        // Compare only the middle samples (7-10)
                        if ((sample_count >= 7 && sample_count <= 10) && (RxD_sync ^ prev_sample)) begin
                            next_Rx_FERROR = 1'b1;
                            next_state = IDLE;
                        end else begin
                            next_Rx_FERROR = Rx_FERROR;
                        end

                        next_prev_sample = RxD_sync;
                        if (sample_count == 10)
                            next_mid_sample = RxD_sync;

                        if (sample_count >= 15) begin
                            next_sample_count = 0;
                            // stop bit must be high 
                            if (!mid_sample) begin
                                next_Rx_FERROR = 1'b1;
                                next_state = IDLE;
                            end
                            // if no errors, produce Rx_VALID pulse and update Rx_DATA
                            if ((next_Rx_PERROR == 1'b0) && (next_Rx_FERROR == 1'b0)) begin
                                next_Rx_DATA  = data;
                                next_Rx_VALID = 1'b1;
                            end else begin
                                next_Rx_VALID = 1'b0;
                            end
                            next_state = IDLE;
                        end else begin
                            next_sample_count = sample_count + 1;
                        end
                    end
                end

                // ---------------------------------------------------------
                default: begin
                    next_state        = IDLE;
                    next_sample_count = 0;
                    next_bit_index    = 0;
                    next_data         = 8'b0;
                    next_prev_sample  = 1'b1;
                    next_Rx_VALID     = 1'b0;
                    next_Rx_PERROR    = 1'b0;
                    next_Rx_FERROR    = 1'b0;
                end
            endcase
        end
    end
endmodule