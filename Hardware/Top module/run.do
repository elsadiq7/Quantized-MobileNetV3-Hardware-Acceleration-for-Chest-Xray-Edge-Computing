# ModelSim/QuestaSim Do File for Chest X-Ray Classifier
# Simplified version to show integration test status

# Create work library
vlib work
vmap work work

# Set some simulation options
set StdArithNoWarnings 1
set NumericStdNoWarnings 1

# Compile all modules
echo "Compiling all modules..."
vlog -sv timing_optimized_modules.sv
vlog -sv external_memory_controller.sv
vlog -sv dsp_resource_manager.sv
vlog -sv "bneck/HSwish.sv"
vlog -sv "bneck/Relu.sv"
vlog -sv "bneck/batchnorm_debug.sv"
vlog -sv "bneck/pointwise_conv_debug.sv"
vlog -sv "bneck/depthwise_conv_simple.sv"
vlog -sv "bneck/BottleNeck_const_func.sv"
vlog -sv "bneck/BottleNeck_Optimized.sv"
vlog -sv "bneck/SE_module.sv"
vlog -sv "bneck/BatchNorm_se.sv"
vlog -sv "bneck/ReLU_se.sv"
vlog -sv "bneck/HardSwishSigmoid.sv"
vlog -sv "bneck/Conv2D.sv"
vlog -sv "bneck/AdaptiveAvgPool2d_1x1.sv"
vlog -sv "bneck/BottleNeck_11Stage_Sequential_Optimized.sv"
vlog -sv "Final layer/hswish.sv"
vlog -sv "Final layer/batchnorm.sv"
vlog -sv "Final layer/batchnorm1d.sv"
vlog -sv "Final layer/pointwise_conv.sv"
vlog -sv "Final layer/linear.sv"
vlog -sv "Final layer/linear_external_weights.sv"
vlog -sv "Final layer/final_layer_top.sv"
vlog -sv "First Layer/HSwish.sv"
vlog -sv "First Layer/Relu6.sv"
vlog -sv "First Layer/batchnorm_accumulator.sv"
vlog -sv "First Layer/batchnorm_normalizer.sv"
vlog -sv "First Layer/batchnorm_top.sv"
vlog -sv "First Layer/convolver.sv"
vlog -sv "First Layer/image_handler_send.sv"
vlog -sv "First Layer/accelerator.sv"
vlog -sv weight_memory_manager.sv
vlog -sv interface_adapter.sv
vlog -sv chest_xray_classifier_top.sv
vlog -sv chest_xray_classifier_tb.sv
vlog -sv integration_test.sv

# Start simulation
echo "Starting integration test..."
vsim -t ps integration_test

# Run simulation until $finish
echo "Running until test completes..."
run -all

echo "Simulation finished - check output above for test results" 