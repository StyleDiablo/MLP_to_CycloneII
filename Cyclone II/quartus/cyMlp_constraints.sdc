# Create a primary clock with a period of 20 ns (50 MHz)
create_clock -name clk -period 20.0 [get_ports clk]

# Set input delay constraints for the Switches ports
set_input_delay -clock clk -max 3.0 -add_delay [get_ports {Switches[*]}]
set_input_delay -clock clk -min 1.0 -add_delay [get_ports {Switches[*]}]

# Set output delay constraints for the LCD ports
set_output_delay -clock clk -max 5.0 [get_ports {LCD_RS LCD_E LCD_RW DBUS[*]}]
set_output_delay -clock clk -min 1.0 [get_ports {LCD_RS LCD_E LCD_RW DBUS[*]}]

# Timing exceptions (if any)
set_false_path -from [get_ports reset]


