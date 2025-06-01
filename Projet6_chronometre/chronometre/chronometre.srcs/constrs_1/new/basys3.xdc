##CONFIGURATION GLOBALE 

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

##CLOCK PRINCIPALE (100 MHz)
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.0 -name clk -waveform {0 5} [get_ports clk]

##AFFICHAGE 7SEGMENTS

###Anodes(actives à 0)
set_property PACKAGE_PIN U2 [get_ports {an[0]}] ;# AN0
set_property PACKAGE_PIN U4 [get_ports {an[1]}] ;# AN1
set_property PACKAGE_PIN V4 [get_ports {an[2]}] ;# AN2
set_property PACKAGE_PIN W4 [get_ports {an[3]}] ;# AN3
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]

### Segments(actifs à 0)
set_property PACKAGE_PIN W7 [get_ports {seg[0]}] ;# CA
set_property PACKAGE_PIN W6 [get_ports {seg[1]}] ;# CB
set_property PACKAGE_PIN U8 [get_ports {seg[2]}] ;# CC
set_property PACKAGE_PIN V8 [get_ports {seg[3]}] ;# CD
set_property PACKAGE_PIN U5 [get_ports {seg[4]}] ;# CE
set_property PACKAGE_PIN V5 [get_ports {seg[5]}] ;# CF
set_property PACKAGE_PIN U7 [get_ports {seg[6]}] ;# CG
set_property PACKAGE_PIN V7 [get_ports {seg[7]}] ;# DP
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

##BOUTON RESET(pour réinitialiser le chronomètre)
set_property PACKAGE_PIN T18 [get_ports reset] ;# bouton reset
set_property IOSTANDARD LVCMOS33 [get_ports reset]
