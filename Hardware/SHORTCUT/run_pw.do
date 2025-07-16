vlib work
vlog *.sv
vsim -voptargs=+acc work.pointwise_conv_tb 
add wave *
run -all
#quit -sim