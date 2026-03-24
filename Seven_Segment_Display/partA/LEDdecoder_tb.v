`timescale 1ns / 1ps

module LEDdecoder_tb;

    reg [3:0] char;
    wire [6:0] LED;

    // Instantiate LEDdecoder
    LEDdecoder uut (
        .char(char),
        .LED(LED)
    );

    integer i;

    initial begin
        $dumpfile("waveform.vcd");
        $dumpvars(0, LEDdecoder_tb);
        // Run through all chars
        for (i = 0; i < 16; i = i + 1) begin
            char = i;
            #10;
            $display("char: %h  LED: %b", char, LED);
        end

        char = 4'b0100; // Print 4 twice
        #10;
        $display("\n\nchar: %h  LED: %b", char, LED);
        #10;
        $display("char: %h  LED: %b", char, LED);

        $finish;
    end
endmodule