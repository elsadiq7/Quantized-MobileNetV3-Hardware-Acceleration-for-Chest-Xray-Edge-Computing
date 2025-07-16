vlib work
vlog *.sv
vsim -voptargs=+acc work.batchnorm_tb 
add wave *
run -all
#quit -sim