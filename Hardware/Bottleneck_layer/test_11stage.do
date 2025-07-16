vlib work
vlog *.sv
vsim -voptargs=+acc work.BottleNeck_11stage_tb
add wave *
run -all
quit
