vlib work
vlog *sv
vsim -voptargs=+acc work.BottleNeck_11Stage_Sequential_tb 
add wave *
run -all