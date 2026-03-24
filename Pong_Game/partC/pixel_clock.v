module pixel_clock_gen(
    input  wire clk_100MHz,
    input  wire reset,
    output wire pixclk_25MHz,
    output wire clk_125MHz
);
    wire clkfb;
    wire locked;
    //f = 100*(25.175/(5*20)) = 25.175 MHz
    MMCME2_BASE #(
        .CLKIN1_PERIOD(10.0),

        // Multiply the 100 MHz clock by 25.175 MHz
        .CLKFBOUT_MULT_F(10.07),
        .DIVCLK_DIVIDE(1.00),
        .CLKOUT0_DIVIDE_F(40.000),
        .CLKOUT0_PHASE(0.0),
        .CLKOUT0_DUTY_CYCLE(0.5),
        // Pixel clock = 25.175 MHz
        .CLKOUT1_DIVIDE(8.00),
        .CLKOUT1_PHASE(0.0),
        .CLKOUT1_DUTY_CYCLE(0.5),

        // 5*pixel clock = 125.875 MHz

        .CLKFBOUT_PHASE(0.0),
        .STARTUP_WAIT("FALSE")
    )
    mmcm_inst (
        // Primary ports
        .CLKIN1(clk_100MHz),

        // feedback
        .CLKFBOUT(clkfb),
        .CLKFBIN(clkfb),

        // outputs
        .CLKOUT0(pixclk_25MHz), // port0 as requested
        .CLKOUT1(clk_125MHz),       // 5x pixel clock

        // status and control
        .LOCKED(locked),
        .PWRDWN(1'b0),
        .RST(reset)
    );

endmodule
