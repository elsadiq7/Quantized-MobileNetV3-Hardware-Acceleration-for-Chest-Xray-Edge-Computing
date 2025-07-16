vlib work
vlog *.sv
vsim -voptargs=+acc work.depthwise_conv_tb 
add wave *
run -all
#quit -sim