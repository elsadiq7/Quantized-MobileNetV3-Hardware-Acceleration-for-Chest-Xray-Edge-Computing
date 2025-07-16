
vlib work
vlog *.sv
vsim -voptargs=+acc work.BottleNeck_const_func_tb
run 60000
quit
