## UART Receiver .xdc (Part C)
## Spartan-7 Boolean Board

### Clock 100 MHz
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk -period 10.00 -waveform {0 5} [get_ports { clk }];

### Reset button (BTN0)
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports { reset }];

### UART RxD
set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { RxD }];

### Baud rate select switches SW13..SW15
set_property -dict { PACKAGE_PIN L1 IOSTANDARD LVCMOS33 } [get_ports { baud_select[0] }];
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports { baud_select[1] }];
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports { baud_select[2] }];

### Receiver enable switch (SW10)
set_property -dict { PACKAGE_PIN N1 IOSTANDARD LVCMOS33 } [get_ports { Rx_EN }];

### Received data LEDs (LD0..LD7)
set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[0] }];
set_property -dict { PACKAGE_PIN G2 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[1] }];
set_property -dict { PACKAGE_PIN F1 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[2] }];
set_property -dict { PACKAGE_PIN F2 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[3] }];
set_property -dict { PACKAGE_PIN E1 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[4] }];
set_property -dict { PACKAGE_PIN E2 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[5] }];
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[6] }];
set_property -dict { PACKAGE_PIN E5 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[7] }];

### Status LEDs (LD13..LD15)
set_property -dict { PACKAGE_PIN A3 IOSTANDARD LVCMOS33 } [get_ports { Rx_FERROR }];
set_property -dict { PACKAGE_PIN B4 IOSTANDARD LVCMOS33 } [get_ports { Rx_PERROR }];
set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 } [get_ports { Rx_VALID }];