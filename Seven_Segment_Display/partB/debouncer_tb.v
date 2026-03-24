`timescale 1ns/1ps

module debounce_tb;
    reg clk;
    reg reset_btn;
    wire sync_reset, debounced_reset;
    
    Sync_2ff s_dut(
        .clk(clk),
        .async_in(reset_btn),
        .sync_out(sync_reset)
    );
    Debouncer d_dut (
        .clk(clk),
        .btn_in(sync_reset),
        .btn_out(debounced_reset)
    );

    initial clk = 0;
    always #100 clk = ~clk;

    initial begin
        $dumpfile("debounce_waveform.vcd");
        $dumpvars(0, debounce_tb);

        reset_btn = 0;
        #1000;  // Wait 1us

        //INVALID
        reset_btn = 1; #200;   // 0.2us
        reset_btn = 0; #400;   // 0.4us
        reset_btn = 1; #300;   // 0.3us
        reset_btn = 0; #600;   // 0.6us
        reset_btn = 1; #100;   // 0.1us
        reset_btn = 0; #2000;  // 2us gap

        //VALID 1
        reset_btn = 1;
        #2000
        reset_btn = 0;
        #1500;  // 1ms release


       $finish;
    end
endmodule
