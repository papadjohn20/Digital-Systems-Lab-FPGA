module uart_top (
    input  wire        clk,
    input  wire        reset,
    input  wire [2:0]  baud_select,
    input  wire        Tx_EN,
    input  wire        Rx_EN,
    input  wire        Tx_WR,        // pulse to start transmission (from testbench or HW)
    input  wire [7:0]  Tx_DATA,      // data to send (can be connected to switches)
    output wire        TxD,
    output wire        Tx_BUSY,
    output wire [7:0]  Rx_DATA,
    output wire        Rx_VALID,
    output wire        Rx_PERROR,
    output wire        Rx_FERROR
);
  
    // Instantiate the transmitter
    uart_transmitter tx_inst (
        .clk(clk),
        .reset(reset),
        .Tx_DATA(Tx_DATA),
        .baud_select(baud_select),
        .Tx_EN(Tx_EN),
        .Tx_WR(Tx_WR),
        .TxD(TxD),
        .Tx_BUSY(Tx_BUSY)
    );

    // Instantiate the receiver
    uart_receiver rx_inst (
        .clk(clk),
        .reset(reset),
        .baud_select(baud_select),
        .Rx_EN(Rx_EN),
        .RxD(TxD),
        .Rx_DATA(Rx_DATA),
        .Rx_VALID(Rx_VALID),
        .Rx_PERROR(Rx_PERROR),
        .Rx_FERROR(Rx_FERROR)
    );

    // The other modules are instatited inside the transmitter and receiver
endmodule
