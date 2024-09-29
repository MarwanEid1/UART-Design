
vlog \
-f compile_files.f

vsim \
-voptargs=+acc \
work.top_tb

do wave.do

run -all

wave zoom full
