`timescale 1ns/1ps
module tb_uart_transmitter;
    reg clk, reset;
    reg [7:0] Tx_DATA;
    reg [2:0] baud_select;
    reg Tx_EN;
    reg Tx_WR;
    wire TxD;
    wire Tx_BUSY;

    // Instantiate DUT (assumes Sync_2ff inside)
    uart_transmitter dut (
        .reset(reset),
        .clk(clk),
        .Tx_DATA(Tx_DATA),
        .baud_select(baud_select),
        .Tx_EN(Tx_EN),
        .Tx_WR(Tx_WR),
        .TxD(TxD),
        .Tx_BUSY(Tx_BUSY)
    );

    // 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        reset = 1;
        
        Tx_DATA = 8'h41;       // ASCII 'A'
        baud_select = 3'b111;  // 115200 baud (fastest)
        Tx_EN = 0;
        Tx_WR = 0;
        #100;
        reset = 0;
        #100;

        // Enable transmitter
        Tx_EN = 1;

        // --- First transmission: 'A'
        #37;
        Tx_WR = 1;
        #500;
        Tx_WR = 0;
        wait (Tx_BUSY == 0);
        #2000;

//        // --- Second transmission: 'B'
//        Tx_DATA = 8'h42; // ASCII 'B'
//        #100;
//        Tx_WR = 1;
//        #500;
//        Tx_WR = 0;
//        wait (Tx_BUSY == 0);
//        #2000;

        // --- Third transmission: 'C' (odd number of 1s)
        Tx_DATA = 8'h43; // ASCII 'C' = 01000011 (3 ones)
        #100;
        Tx_WR = 1;
        #500;
        Tx_WR = 0;
        wait (Tx_BUSY == 0);
        #2000;

        $finish;
    end
endmodule