`timescale 1ns/1ps
module tb_uart_receiver;

    reg clk, reset;
    reg Rx_EN;
    reg RxD;
    reg [2:0] baud_select;
    wire [7:0] Rx_DATA;
    wire Rx_VALID;
    wire Rx_PERROR;
    wire Rx_FERROR;

    // Instantiate DUT
    uart_receiver dut (
        .clk(clk),
        .reset(reset),
        .baud_select(baud_select),
        .Rx_EN(Rx_EN),
        .RxD(RxD),
        .Rx_DATA(Rx_DATA),
        .Rx_VALID(Rx_VALID),
        .Rx_PERROR(Rx_PERROR),
        .Rx_FERROR(Rx_FERROR)
    );

    // Generate 100 MHz clock
    initial clk = 0;
    always #5 clk = ~clk;

    // Helper task to send one UART frame
    // Format: 1 start (0) + 8 data bits (LSB first) + parity (even) + stop (1)
    task send_uart_byte;
        input [7:0] data;
        integer i;
        reg parity_bit;
        begin
            parity_bit = ^data;      // XOR reduction at 1 if odd number of 1s
            parity_bit = ~parity_bit; // even parity bit

            // Start bit
            RxD = 0; 
            #(8680); // bit period for 115200 baud

            // Data bits
            for (i = 0; i < 8; i = i + 1) begin
                RxD = data[i];
                #(8680);
            end

            // Parity bit
            RxD = parity_bit;
            #(8680);

            // Stop bit
            RxD = 1;
            #(8680);
        end
    endtask
    
    task send_uart_byte_wrong_stop_bit;
        input [7:0] data;
        integer i;
        reg parity_bit;
        begin
            parity_bit = ^data;      // XOR reduction at 1 if odd number of 1s
            parity_bit = ~parity_bit; // even parity bit

            // Start bit
            RxD = 0;
            #(8680); // bit period for 115200 baud

            // Data bits
            for (i = 0; i < 8; i = i + 1) begin
                RxD = data[i];
                #(8680);
            end

            // Parity bit
            RxD = parity_bit;
            #(8680);

            // Stop bit
            RxD = 0; //WRONG
            #(8680);
        end
    endtask
    
    task send_uart_byte_wrong_parity_bit;
        input [7:0] data;
        integer i;
        reg parity_bit;
        begin
            parity_bit = ^data;      // XOR reduction at 1 if odd number of 1s
            parity_bit = ~parity_bit; // even parity bit

            // Start bit
            RxD = 0;
            #(8680); // bit period for 115200 baud

            // Data bits
            for (i = 0; i < 8; i = i + 1) begin
                RxD = data[i];
                #(8680);
            end

            // Parity bit
            RxD = ~parity_bit; //WRONG (sending ~parity bit)
            #(8680);

            // no need to sent stop bit
        end
    endtask
    
    initial begin
        reset = 1;
        Rx_EN = 0;
        RxD = 1;  // idle line high
        baud_select = 3'b111; // fastest (115200 baud)
        #100;
        reset = 0;
        #100;

        Rx_EN = 1;

        // --- Send 'A' (0x41)
        send_uart_byte(8'h41);
        wait (Rx_VALID); //when sending wrong parity bit put in comment because VALID wont go to 1
//        send_uart_byte_wrong_parity_bit(8'h43);
//        wait(Rx_PERROR); RxD = 1; //when sending wrong parity bit remove dont have that as a comment. Otherwise the C will be sent wrong aswell 
        #1000;

//        // --- Send 'C' (0x43) -> odd number of 1's, check parity
        send_uart_byte(8'h43);
        wait (Rx_VALID); //when sending wrong stop bit put in comment because VALID wont go to 1
//        send_uart_byte_wrong_stop_bit(8'h43);
//        wait (Rx_FERROR); RxD = 1;//when sending wrong stop bit remove dont have that as a comment. Otherwise the Z will be sent wrong aswell     
        #1000;

//        // --- Send 'Z' (0x5A) -> even parity again
        send_uart_byte(8'h5A);
        wait (Rx_VALID);
        #1000;
        #(17380);//time to show Z in the waveform
        
        $finish;
    end
endmodule
