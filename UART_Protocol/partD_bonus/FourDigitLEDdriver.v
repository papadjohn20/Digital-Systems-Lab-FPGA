module FourDigitLEDdriver(clk, reset, button, an3, an2, an1, an0, 
    a, b, c, d, e, f, g, dp, data);
    input clk, reset, button;
    input [7:0] data;
    output an3, an2, an1, an0;
    output a, b, c, d, e, f, g, dp;
    wire [6:0] LED;
    wire newclk;
    wire sync_button, debounce_button;
    wire [3:0] counter;
    wire [3:0] char;
    wire [3:0] message_flat[0:15];
    wire [3:0] i;

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
   // THE NEWCLK was not used in the simulation, but when tested on the fpga the newclk was connected
    Sync_2ff sync_2ff_button(clk, button, sync_button);
    Debouncer debounce_button_inst (clk, sync_button, debounce_button);
    counter counter_inst(clk, reset, counter);
    Anode_driver Anode_driver_inst(clk, reset, button, counter, char, an3, an2, an1, an0, data); //NO DEBOUNCER FOR THE SIMULATION
    LEDdecoder LEDdecoder_inst (char, LED);

    assign {a, b, c, d, e, f, g} = LED;
    assign dp = 1;  // decimal point off
endmodule