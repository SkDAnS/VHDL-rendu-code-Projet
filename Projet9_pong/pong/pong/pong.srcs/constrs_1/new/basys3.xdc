set_property PACKAGE_PIN W5 [get_ports clk100]
set_property IOSTANDARD LVCMOS33 [get_ports clk100]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk100]

## Reset button (bouton du centre)
set_property PACKAGE_PIN U18 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

## VGA - Horizontal Sync
set_property PACKAGE_PIN P19 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports hsync]

## VGA - Vertical Sync
set_property PACKAGE_PIN R19 [get_ports vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]

## VGA - Red [3:0]
set_property PACKAGE_PIN N19 [get_ports {vga_red[3]}]
set_property PACKAGE_PIN J19 [get_ports {vga_red[2]}]
set_property PACKAGE_PIN H19 [get_ports {vga_red[1]}]
set_property PACKAGE_PIN G19 [get_ports {vga_red[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_red[*]}]

## VGA - Green [3:0]
set_property PACKAGE_PIN D17 [get_ports {vga_green[3]}]
set_property PACKAGE_PIN G17 [get_ports {vga_green[2]}]
set_property PACKAGE_PIN H17 [get_ports {vga_green[1]}]
set_property PACKAGE_PIN J17 [get_ports {vga_green[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_green[*]}]

## VGA - Blue [3:0]
set_property PACKAGE_PIN J18 [get_ports {vga_blue[3]}]
set_property PACKAGE_PIN K18 [get_ports {vga_blue[2]}]
set_property PACKAGE_PIN L18 [get_ports {vga_blue[1]}]
set_property PACKAGE_PIN N18 [get_ports {vga_blue[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_blue[*]}]

# paddle left up (BTN_UP)
set_property PACKAGE_PIN T18 [get_ports btnU]
set_property IOSTANDARD LVCMOS33 [get_ports btnU]

# paddle left down (BTN_LEFT)
set_property PACKAGE_PIN W19 [get_ports btnL]
set_property IOSTANDARD LVCMOS33 [get_ports btnL]

# paddle right up (BTN_RIGHT)
set_property PACKAGE_PIN T17 [get_ports btnR]
set_property IOSTANDARD LVCMOS33 [get_ports btnR]

# paddle right down (BTN_down)
set_property PACKAGE_PIN U17 [get_ports btnD]
set_property IOSTANDARD LVCMOS33 [get_ports btnD]