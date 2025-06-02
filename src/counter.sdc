set_units -time ns
create_clock [get_ports clk_cpu]  -name core_clock -period 5
set_load -pin_load 0.005 [get_ports {MOSI MISO SCLK CS}]
set_max_transition 0.5 [get_ports clk_cpu]

