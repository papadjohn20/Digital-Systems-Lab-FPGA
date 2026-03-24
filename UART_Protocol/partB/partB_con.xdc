## Spartan-7 Boolean Board  — UART Transmitter
## Clock 100 MHz
set_property -dict { PACKAGE_PIN F14 IOSTANDARD LVCMOS33 } [get_ports { clk }];
create_clock -add -name sys_clk -period 10.00 -waveform {0 5} [get_ports { clk }];

## Reset push-button (BTN0)
set_property -dict { PACKAGE_PIN J2 IOSTANDARD LVCMOS33 } [get_ports { reset }];

# TxD output
set_property -dict { PACKAGE_PIN U11 IOSTANDARD LVCMOS33 } [get_ports { TxD }];

## Tx_BUSY indicator LED — use LED15 (A4)
set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 } [get_ports { Tx_BUSY }];

## Tx_DATA[7:0] from switches SW0..SW7
set_property -dict { PACKAGE_PIN V2 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[0] }];
set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[1] }];
set_property -dict { PACKAGE_PIN U1 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[2] }];
set_property -dict { PACKAGE_PIN T2 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[3] }];
set_property -dict { PACKAGE_PIN T1 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[4] }];
set_property -dict { PACKAGE_PIN R2 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[5] }];
set_property -dict { PACKAGE_PIN R1 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[6] }];
set_property -dict { PACKAGE_PIN P2 IOSTANDARD LVCMOS33 } [get_ports { Tx_DATA[7] }];

## Tx_EN switch — SW10 → N1
set_property -dict { PACKAGE_PIN N1 IOSTANDARD LVCMOS33 } [get_ports { Tx_EN }];

#BTN1 (J5)
set_property -dict { PACKAGE_PIN J5 IOSTANDARD LVCMOS33 } [get_ports { Tx_WR }];

## Baud_select[2:0] from switches SW13..SW15
# SW13 → L1, SW14 → K2, SW15 → K1
set_property -dict { PACKAGE_PIN L1 IOSTANDARD LVCMOS33 } [get_ports { baud_select[0] }];
set_property -dict { PACKAGE_PIN K2 IOSTANDARD LVCMOS33 } [get_ports { baud_select[1] }];
set_property -dict { PACKAGE_PIN K1 IOSTANDARD LVCMOS33 } [get_ports { baud_select[2] }];
