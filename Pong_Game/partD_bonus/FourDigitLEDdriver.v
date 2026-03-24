module FourDigitLEDdriver(clk, reset, game_over, left_right_wins, an3, an2, an1, an0, 
    a, b, c, d, e, f, g, dp, match_over);
    input clk, reset, game_over, left_right_wins;
    output an3, an2, an1, an0;
    output a, b, c, d, e, f, g, dp;
    output match_over;

    wire [6:0] LED;
    wire newclk;
    wire [3:0] counter;
    wire [3:0] char;

    wire clkfeed;
    wire locked;
    wire locked_int;
    assign locked_int = 1'b1;
   MMCME2_BASE #(
       .BANDWIDTH("OPTIMIZED"),
       .CLKFBOUT_PHASE(0.0),
       .CLKFBOUT_MULT_F(6.0),   
       .CLKOUT1_DIVIDE(120.0),  
       .CLKOUT1_PHASE(0.0),
       .CLKOUT1_DUTY_CYCLE(0.5),
       .DIVCLK_DIVIDE(1),         // Master division value (1-106)
       .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
       .STARTUP_WAIT("FALSE"),     // Delays DONE until MMCM is locked (FALSE, TRUE)
       .CLKIN1_PERIOD(10.000)    
   )
    
   MMCME2_BASE_inst (
       .CLKFBIN(clkfeed),
       .CLKFBOUT(clkfeed),
       .CLKIN1(clk),
       .CLKOUT1(newclk),
       .LOCKED(locked),
       .PWRDWN(1'b0),
       .RST(reset) 
   );
   
    counter counter_inst(newclk, reset, counter);
    Anode_driver Anode_driver_inst(newclk, reset, game_over, left_right_wins, counter, char, an3, an2, an1, an0, match_over);
    LEDdecoder LEDdecoder_inst (char, LED);

    assign {a, b, c, d, e, f, g} = LED;
    assign dp = 1;  // decimal point off
endmodule