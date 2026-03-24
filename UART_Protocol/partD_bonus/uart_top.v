module uart_top (
    input          clk,
    input          reset,
    input   [2:0]  baud_select,
    input          Tx_EN,
    input          Rx_EN,
    input          Tx_WR,        // pulse to start transmission (from testbench or HW)
    input   [7:0]  Tx_DATA,      // data to send (can be connected to switches)
    output         TxD,
    output         Tx_BUSY,
    output  [7:0]  Rx_DATA,
    output         Rx_VALID,
    output         Rx_PERROR,
    output         Rx_FERROR,
    output  an3, an2, an1, an0,
    output  a, b, c, d, e, f, g, dp,
    input   button
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
       
    FourDigitLEDdriver lab1_inst(
        .clk(clk),
        .reset(reset),
        .button(button),
        .an3(an3),
        .an2(an2),
        .an1(an1),
        .an0(an0),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .e(e),
        .f(f),
        .g(g),
        .dp(dp), 
        .data(Rx_DATA)// DATA FROM RECEIVER   
    );
    // The other modules are instatited inside the transmitter and receiver
endmodule