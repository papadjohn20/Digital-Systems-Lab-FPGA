`timescale 1ns/1ps
module vram_tb;

    reg clk = 0;
    always #5 clk = ~clk; // 100 MHz

    reg [13:0] addr;
    wire [2:0] rgb;
    integer i;
    vram uut (
        .clk(clk),
        .addr(addr),
        .rgb(rgb)
    );

    initial begin
    #200
    for(i = 0; i < 12288 ; i = i + 1) begin
        addr = i;
        @(posedge clk);  // WAIT FOR 1 CLOCK
        $display("addr%d rgb=%b", i, rgb);
    end
    
    $finish;
end

endmodule
