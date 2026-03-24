create_clock -period 10.000 -name clk [get_ports clk]
set_property -dict {PACKAGE_PIN F14 IOSTANDARD LVCMOS33} [get_ports {clk}]
# On-board Buttons
set_property -dict {PACKAGE_PIN J2 IOSTANDARD LVCMOS33} [get_ports {reset}]
#HDMI Signals
set_property -dict { PACKAGE_PIN T14 IOSTANDARD TMDS_33} [get_ports {hdmi_clk_n}]
set_property -dict { PACKAGE_PIN R14 IOSTANDARD TMDS_33} [get_ports {hdmi_clk_p}]
set_property -dict { PACKAGE_PIN T15 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_n[0]}]
set_property -dict { PACKAGE_PIN R17 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_n[1]}]
set_property -dict { PACKAGE_PIN P16 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_n[2]}]
set_property -dict { PACKAGE_PIN R15 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_p[0]}]
set_property -dict { PACKAGE_PIN R16 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_p[1]}]
set_property -dict { PACKAGE_PIN N15 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_p[2]}]

# sw[7:0] from switches SW0..SW7
set_property -dict { PACKAGE_PIN V2 IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]
set_property -dict { PACKAGE_PIN U2 IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]
set_property -dict { PACKAGE_PIN U1 IOSTANDARD LVCMOS33 } [get_ports { sw[2] }]
set_property -dict { PACKAGE_PIN T2 IOSTANDARD LVCMOS33 } [get_ports { sw[3] }]
set_property -dict { PACKAGE_PIN T1 IOSTANDARD LVCMOS33 } [get_ports { sw[4] }]
set_property -dict { PACKAGE_PIN R2 IOSTANDARD LVCMOS33 } [get_ports { sw[5] }]
set_property -dict { PACKAGE_PIN R1 IOSTANDARD LVCMOS33 } [get_ports { sw[6] }]
set_property -dict { PACKAGE_PIN P2 IOSTANDARD LVCMOS33 } [get_ports { sw[7] }]

# Set Bank 0 voltage
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
