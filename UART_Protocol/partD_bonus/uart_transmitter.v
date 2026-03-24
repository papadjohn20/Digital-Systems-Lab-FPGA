module uart_transmitter(
    input         clk,
    input         reset,
    input  [7:0]  Tx_DATA,
    input  [2:0]  baud_select,
    input         Tx_EN,
    input         Tx_WR,      // one-cycle pulse to write data
    output reg    TxD,
    output reg    Tx_BUSY
);

    // INSTATIATE BAUD CONTROLLER
    wire Tx_sample_ENABLE;
    baud_controller baud_controller_tx_inst (
        .reset(reset),
        .clk(clk),
        .baud_select(baud_select),
        .sample_ENABLE(Tx_sample_ENABLE)
    );
    // INSTATIATE SYNC 2FF for Tx_WR
    wire Tx_WR_sync;
    Sync_2ff TxWR_sync_inst (
        .clk(clk),
        .async_in(Tx_WR),
        .sync_out(Tx_WR_sync)
    );
    // INSTATIATE SYNC 2FF for Tx_EN
    wire Tx_EN_sync;
    Sync_2ff TxEN_sync_inst (
        .clk(clk),
        .async_in(Tx_EN),
        .sync_out(Tx_EN_sync)
    );
    // INSTATIATE SYNC 2FF for Tx_WR_debounced
    wire Tx_WR_debounced;
    Debouncer debounce_inst (
        clk,
        Tx_WR_sync, 
        Tx_WR_debounced
    );


    // INTERNAL REGS
    reg [10:0] tx_symbol; // frame width: start + 8 data + parity + stop = 11
    reg [3:0]  bit_index; // index to navigate the tx_symbol
    reg [3:0]  sample_count; // counter to count how many sample enables have passed
    reg        parity_bit;
    reg        Tx_WR_d; // Signal that comes out of a 1ff. The input is the Tx_WR_debounced

    // FUNCTION TO CREATE PARITY BIT
    function automatic parity_even;
        input [7:0] data;
        integer i;
        reg parity;
        begin
            parity = 1'b0;
            for (i = 0; i < 8; i = i + 1)
                parity = parity ^ data[i];
            parity_even = parity; // 1 if odd, 0 if even
        end
    endfunction

    //WITHOUT DEBOUNCER FOR THE SIMULATION
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            Tx_WR_d <= 1'b0;
        end else begin
            Tx_WR_d <= Tx_WR_sync;
        end
    end
    wire Tx_WR_rising = (Tx_WR_sync && !Tx_WR_d); //if Tx_WR_sync = 1 and Tx_WR_d = 0 ---> Tx_WR_rising = posedge(Tx_WR)

    // FSM states
    parameter IDLE = 1'b0, SENDING = 1'b1;
    reg current_state, next_state;

    // "next" signals for combinational logic
    reg [10:0] next_tx_symbol;
    reg [3:0]  next_bit_index;
    reg [3:0]  next_sample_count;
    reg        next_parity_bit;
    reg        next_TxD;
    reg        next_Tx_BUSY;

    //----------------------------------------------------------------
    // SEQUENTIAL BLOCK 
    //----------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            bit_index     <= 0;
            sample_count  <= 0;
            parity_bit    <= 0;
            TxD           <= 1'b1;
            tx_symbol     <= 11'b11111111111; 
            Tx_BUSY       <= 1'b0;
        end else begin
            current_state <= next_state;
            bit_index     <= next_bit_index;
            sample_count  <= next_sample_count;
            parity_bit    <= next_parity_bit;
            TxD           <= next_TxD;
            tx_symbol     <= next_tx_symbol;
            Tx_BUSY       <= next_Tx_BUSY;
        end
    end

    //----------------------------------------------------------------
    // COMBINATIONAL BLOCK
    //----------------------------------------------------------------
    always @(current_state or Tx_WR_rising or Tx_EN_sync or Tx_sample_ENABLE
             or bit_index or sample_count or tx_symbol or Tx_DATA or parity_bit) begin

        next_state        = current_state;
        next_tx_symbol    = tx_symbol;
        next_bit_index    = bit_index;
        next_sample_count = sample_count;
        next_parity_bit   = parity_bit;
        next_TxD          = TxD;
        next_Tx_BUSY      = Tx_BUSY;

        case (current_state)
            //----------------------------------------------------------
            IDLE: begin
                next_TxD     = 1'b1;
                next_Tx_BUSY = 1'b0;

                if (Tx_WR_rising && Tx_EN_sync) begin
                    // build frame and go to SENDING
                    next_parity_bit      = parity_even(Tx_DATA) ^ 1'b1; // even parity
                    next_tx_symbol[0]    = 1'b0;       // start bit
                    next_tx_symbol[8:1]  = Tx_DATA;    // data bits
                    next_tx_symbol[9]    = next_parity_bit;
                    next_tx_symbol[10]   = 1'b1;       // stop bit
                    next_bit_index       = 0;
                    next_sample_count    = 0;
                    next_Tx_BUSY         = 1'b1;
                    next_state           = SENDING;
                end
            end

            //----------------------------------------------------------
            SENDING: begin
                next_Tx_BUSY = 1'b1;
//                next_TxD     = tx_symbol[bit_index];
                
                if (Tx_sample_ENABLE) begin
                    if (bit_index == 0) begin 
                        next_TxD = tx_symbol[bit_index];
                        next_bit_index = bit_index + 1;
                    end else if (sample_count >= 15) begin
                        next_sample_count = 0;
                        if (bit_index < 11) begin
                            next_bit_index = bit_index + 1;
                            next_TxD       = tx_symbol[bit_index];
                        end else begin
                            // transmission finished
                            next_state     = IDLE;
                            next_Tx_BUSY   = 1'b0;
                            next_TxD       = 1'b1;
                        end
                    end else
                        next_sample_count = sample_count + 1;
                end
            end

            //----------------------------------------------------------
            default: begin
                next_state        = IDLE;
                next_Tx_BUSY      = 1'b0;
                next_TxD          = 1'b1;
                next_tx_symbol    = 11'b11111111111;
                next_bit_index    = 0;
                next_sample_count = 0;
                next_parity_bit   = 0;
            end
        endcase
    end
endmodule