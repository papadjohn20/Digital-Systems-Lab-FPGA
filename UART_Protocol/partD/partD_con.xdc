## Spartan-7 Boolean Board PART D
### Clock 100 MHz
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk -period 10.00 -waveform {0 5} [get_ports { clk }];

### Reset button (BTN0)
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports { reset }];

### Baud rate select switches SW13..SW15
set_property -dict { PACKAGE_PIN L1 IOSTANDARD LVCMOS33 } [get_ports { baud_select[0] }];
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports { baud_select[1] }];
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports { baud_select[2] }];

# TxD output
set_property -dict { PACKAGE_PIN U11 IOSTANDARD LVCMOS33 } [get_ports { TxD }];
### UART RxD
#set_property -dict { PACKAGE_PIN V12 IOSTANDARD LVCMOS33 } [get_ports { RxD }];

## Tx_BUSY indicator LED use LED12 (B3)
set_property -dict { PACKAGE_PIN B3 IOSTANDARD LVCMOS33 } [get_ports { Tx_BUSY }];
### Status LEDs (LD13..LD15)
set_property -dict { PACKAGE_PIN A3 IOSTANDARD LVCMOS33 } [get_ports { Rx_FERROR }];
set_property -dict { PACKAGE_PIN B4 IOSTANDARD LVCMOS33 } [get_ports { Rx_PERROR }];
set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 } [get_ports { Rx_VALID }];

## Tx_DATA[7:0] from switches SW0..SW7
set_property -dict { PACKAGE_PIN V2 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[0] }];
set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[1] }];
set_property -dict { PACKAGE_PIN U1 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[2] }];
set_property -dict { PACKAGE_PIN T2 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[3] }];
set_property -dict { PACKAGE_PIN T1 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[4] }];
set_property -dict { PACKAGE_PIN R2 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[5] }];
set_property -dict { PACKAGE_PIN R1 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[6] }];
set_property -dict { PACKAGE_PIN P2 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[7] }];

### Received data LEDs (LD0..LD7)
set_property -dict { PACKAGE_PIN G1 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[0] }];
set_property -dict { PACKAGE_PIN G2 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[1] }];
set_property -dict { PACKAGE_PIN F1 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[2] }];
set_property -dict { PACKAGE_PIN F2 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[3] }];
set_property -dict { PACKAGE_PIN E1 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[4] }];
set_property -dict { PACKAGE_PIN E2 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[5] }];
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[6] }];
set_property -dict { PACKAGE_PIN E5 IOSTANDARD LVCMOS33 } [get_ports { Rx_DATA[7] }];

## Tx_EN enable switch (SW9)
set_property -dict { PACKAGE_PIN N2 IOSTANDARD LVCMOS33 } [get_ports { Tx_EN }];
### Receiver enable switch (SW10)
set_property -dict { PACKAGE_PIN N1 IOSTANDARD LVCMOS33 } [get_ports { Rx_EN }];

#BTN1 (J5)
set_property -dict { PACKAGE_PIN J5 IOSTANDARD LVCMOS33 } [get_ports { Tx_WR }];