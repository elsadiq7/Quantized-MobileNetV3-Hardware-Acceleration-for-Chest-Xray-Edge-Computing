vlib work
vlog *.sv
vsim -voptargs=+acc work.shortcut_tb 
add wave *
run -all
#quit -sim