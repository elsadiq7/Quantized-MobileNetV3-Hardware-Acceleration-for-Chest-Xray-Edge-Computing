vlib work
vlog *.sv
vsim -voptargs=+acc work.BottleNeck_fullimage_tb 
add wave *
run -all
#quit -sim