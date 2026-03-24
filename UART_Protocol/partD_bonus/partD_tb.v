`timescale 1ns/1ps
module uart_top_tb;
    
    reg clk;
    reg reset;

    reg [2:0] baud_select;
    reg Tx_EN, Rx_EN;
    reg Tx_WR;
    reg [7:0] Tx_DATA;
    reg [7:0] test_symbols [0:3];
    integer i;
    
    wire TxD;
    wire Tx_BUSY;
    wire [7:0] Rx_DATA;
    wire Rx_VALID;
    wire Rx_PERROR;
    wire Rx_FERROR;
    
    //lab1
    reg button;
    wire an3, an2, an1, an0;
    wire a, b, c, d, e, f, g, dp;

    // Instantiate uart_top
    uart_top dut (
        .clk(clk),
        .reset(reset),
        .baud_select(baud_select),
        .Tx_EN(Tx_EN),
        .Rx_EN(Rx_EN),
        .Tx_WR(Tx_WR),
        .Tx_DATA(Tx_DATA),
        .TxD(TxD),
        .Tx_BUSY(Tx_BUSY),
        .Rx_DATA(Rx_DATA),
        .Rx_VALID(Rx_VALID),
        .Rx_PERROR(Rx_PERROR),
        .Rx_FERROR(Rx_FERROR),
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
        .button(button)  
    );

    // 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    // helper task: pulse Tx_WR for exactly one posedge of clk
    task tx_write_one;
    begin
        // one clock cycle
        @(posedge clk);
        Tx_WR <= 1'b1;
        @(posedge clk);
        Tx_WR <= 1'b0;
    end
    endtask

    // helper task: pulse button for exactly one posedge of clk
    task button_write_one;
    begin
        // one clock cycle
        @(posedge clk);
        button <= 1'b1;
        @(posedge clk);
        button <= 1'b0;
    end
    endtask


    initial begin
        // init signals
        Tx_WR = 0;
        Tx_DATA = 8'h00;
        Tx_EN = 0;
        Rx_EN = 0;
        baud_select = 3'b111; // fastest (115200 baud)

        // FIRST RESET
        reset = 1;
        #100;
        reset = 0;
        #250;

        // enable transmitter and receiver
        Tx_EN = 1;
        Rx_EN = 1;

        // prepare the four test bytes
        test_symbols[0] = 8'h61; // 'A'
        test_symbols[1] = 8'h62; // 'B'
        test_symbols[2] = 8'h63; // 'C'
        test_symbols[3] = 8'h31; // '1' (example different pattern)

        
        for (i = 0; i < 4; i = i + 1) begin
            wait (Tx_BUSY == 1'b0);

            // put data on Tx_DATA bus
            Tx_DATA = test_symbols[i];

            // pulse Tx_WR synchronous to clk using the helper task
            tx_write_one(); // no debouncer for this to work

            // Wait for receiver to assert Rx_VALID
            wait (Rx_VALID == 1'b1);
            button_write_one(); // no debouncer for this to work

            // wait one clock to let Rx_VALID de-assert (Rx_VALID should be a 1-cycle pulse)
            @(posedge clk);
        end
        
        
        #100_000; // to show that the last symbol was received 
        $finish;
    end

endmodule