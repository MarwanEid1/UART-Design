
add wave -position insertpoint  \
sim:/top_tb/top_inst/clk \
sim:/top_tb/top_inst/rst_n \
sim:/top_tb/top_inst/dvsr \
sim:/top_tb/top_inst/Rx_din \
sim:/top_tb/top_inst/rd_uart \
sim:/top_tb/top_inst/wr_uart \
sim:/top_tb/top_inst/wr_data \
sim:/top_tb/top_inst/rd_data \
sim:/top_tb/top_inst/Tx_dout \
sim:/top_tb/top_inst/Rx_full \
sim:/top_tb/top_inst/Rx_empty \
sim:/top_tb/top_inst/Tx_full \
sim:/top_tb/top_inst/parity_error \
sim:/top_tb/top_inst/framing_error

radix binary -showbase
