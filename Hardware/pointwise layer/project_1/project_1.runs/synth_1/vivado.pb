
{
Command: %s
53*	vivadotcl2J
6synth_design -top pointwise_conv -part xc7z020clg484-32default:defaultZ4-113h px� 
:
Starting synth_design
149*	vivadotclZ4-321h px� 
�
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
	Synthesis2default:default2
xc7z0202default:defaultZ17-347h px� 
�
0Got license for feature '%s' and/or device '%s'
310*common2
	Synthesis2default:default2
xc7z0202default:defaultZ17-349h px� 
�
%s*synth2�
sStarting Synthesize : Time (s): cpu = 00:00:05 ; elapsed = 00:00:04 . Memory (MB): peak = 687.648 ; gain = 236.914
2default:defaulth px� 
�
synthesizing module '%s'%s4497*oasys2"
pointwise_conv2default:default2
 2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
12default:default8@Z8-6157h px� 
W
%s
*synth2?
+	Parameter N bound to: 16 - type: integer 
2default:defaulth p
x
� 
V
%s
*synth2>
*	Parameter Q bound to: 8 - type: integer 
2default:defaulth p
x
� 
a
%s
*synth2I
5	Parameter IN_CHANNELS bound to: 40 - type: integer 
2default:defaulth p
x
� 
b
%s
*synth2J
6	Parameter OUT_CHANNELS bound to: 48 - type: integer 
2default:defaulth p
x
� 
b
%s
*synth2J
6	Parameter FEATURE_SIZE bound to: 14 - type: integer 
2default:defaulth p
x
� 
`
%s
*synth2H
4	Parameter PARALLELISM bound to: 4 - type: integer 
2default:defaulth p
x
� 
e
%s
*synth2M
9	Parameter PARALLEL_GROUPS bound to: 12 - type: integer 
2default:defaulth p
x
� 
�
"Detected attribute (* %s = "%s" *)3982*oasys2
	ram_style2default:default2
block2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
292default:default8@Z8-5534h px� 
�
display: %s251*oasys2J
6Loaded 1920 weights for parallel pointwise convolution2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
1322default:default8@Z8-251h px� 
�
display: %s251*oasys2C
/Parallel Input[x]: Data=0xxxxx, InCh=x, Group=x2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
1672default:default8@Z8-251h px� 
�
display: %s251*oasys2H
4Parallel Accumulation: Group=x, OutCh[x-x] processed2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
1862default:default8@Z8-251h px� 
�
display: %s251*oasys2T
@Parallel Output[x]: Data=0xxxxx, Channel=x, Accumulator=0xxxxxxx2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2102default:default8@Z8-251h px� 
�
'system function call '%s' not supported639*oasys2
time2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2282default:default8@Z8-639h px� 
�
display: %s251*oasys2I
5Parallel pointwise convolution completed at time 1'b02default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2282default:default8@Z8-251h px� 
�
-case statement is not full and has no default155*oasys2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2722default:default8@Z8-155h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2#
pixel_count_reg2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
1002default:default8@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2%
output_active_reg2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
1052default:default8@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2$
stage1_in_ch_reg2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
1092default:default8@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2#
pixel_count_reg2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2782default:default8@Z8-6014h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2"
pointwise_conv2default:default2
 2default:default2
12default:default2
12default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
12default:default8@Z8-6155h px� 
�
%s*synth2�
sFinished Synthesize : Time (s): cpu = 00:00:21 ; elapsed = 00:00:22 . Memory (MB): peak = 923.922 ; gain = 473.188
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
~Finished Constraint Validation : Time (s): cpu = 00:00:25 ; elapsed = 00:00:31 . Memory (MB): peak = 923.922 ; gain = 473.188
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
V
%s
*synth2>
*Start Loading Part and Timing Information
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
J
%s
*synth22
Loading part: xc7z020clg484-3
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished Loading Part and Timing Information : Time (s): cpu = 00:00:25 ; elapsed = 00:00:31 . Memory (MB): peak = 923.922 ; gain = 473.188
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
V
Loading part %s157*device2#
xc7z020clg484-32default:defaultZ21-403h px� 
�
3inferred FSM for state register '%s' in module '%s'802*oasys2
	state_reg2default:default2"
pointwise_conv2default:defaultZ8-802h px� 
�
%s
*synth2x
d---------------------------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s
*synth2t
`                   State |                     New Encoding |                Previous Encoding 
2default:defaulth p
x
� 
�
%s
*synth2x
d---------------------------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s
*synth2s
_                    IDLE |                               00 |                               00
2default:defaulth p
x
� 
�
%s
*synth2s
_              PROCESSING |                               01 |                               01
2default:defaulth p
x
� 
�
%s
*synth2s
_            ACCUMULATING |                               10 |                               10
2default:defaulth p
x
� 
�
%s
*synth2s
_              DONE_STATE |                               11 |                               11
2default:defaulth p
x
� 
�
%s
*synth2x
d---------------------------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
Gencoded FSM with state register '%s' using encoding '%s' in module '%s'3353*oasys2
	state_reg2default:default2

sequential2default:default2"
pointwise_conv2default:defaultZ8-3354h px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished RTL Optimization Phase 2 : Time (s): cpu = 00:01:03 ; elapsed = 00:01:12 . Memory (MB): peak = 1110.148 ; gain = 659.414
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
E
%s
*synth2-

Report RTL Partitions: 
2default:defaulth p
x
� 
j
%s
*synth2R
>+------+----------------------------+------------+----------+
2default:defaulth p
x
� 
j
%s
*synth2R
>|      |RTL Partition               |Replication |Instances |
2default:defaulth p
x
� 
j
%s
*synth2R
>+------+----------------------------+------------+----------+
2default:defaulth p
x
� 
j
%s
*synth2R
>|1     |pointwise_conv__GB0         |           1|     33050|
2default:defaulth p
x
� 
j
%s
*synth2R
>|2     |pointwise_conv__GB1         |           1|     30706|
2default:defaulth p
x
� 
j
%s
*synth2R
>|3     |pointwise_conv__GB2         |           1|     18014|
2default:defaulth p
x
� 
j
%s
*synth2R
>|4     |muxpart__448_pointwise_conv |           1|     30704|
2default:defaulth p
x
� 
j
%s
*synth2R
>|5     |muxpart__455_pointwise_conv |           1|     30704|
2default:defaulth p
x
� 
j
%s
*synth2R
>|6     |pointwise_conv__GB5         |           1|     31123|
2default:defaulth p
x
� 
j
%s
*synth2R
>|7     |pointwise_conv__GB6         |           1|     15040|
2default:defaulth p
x
� 
j
%s
*synth2R
>+------+----------------------------+------------+----------+
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
L
%s
*synth24
 Start RTL Component Statistics 
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
K
%s
*synth23
Detailed RTL Component Info : 
2default:defaulth p
x
� 
:
%s
*synth2"
+---Adders : 
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input     24 Bit       Adders := 5     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      6 Bit       Adders := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      4 Bit       Adders := 2     
2default:defaulth p
x
� 
=
%s
*synth2%
+---Registers : 
2default:defaulth p
x
� 
Z
%s
*synth2B
.	               24 Bit    Registers := 48    
2default:defaulth p
x
� 
Z
%s
*synth2B
.	               16 Bit    Registers := 1925  
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                6 Bit    Registers := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                4 Bit    Registers := 5     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                1 Bit    Registers := 53    
2default:defaulth p
x
� 
9
%s
*synth2!
+---Muxes : 
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input     24 Bit        Muxes := 276   
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input     16 Bit        Muxes := 6     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   3 Input     16 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      6 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      6 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      4 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      4 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      2 Bit        Muxes := 9     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      2 Bit        Muxes := 3     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      1 Bit        Muxes := 1228  
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   3 Input      1 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      1 Bit        Muxes := 3     
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
O
%s
*synth27
#Finished RTL Component Statistics 
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
Y
%s
*synth2A
-Start RTL Hierarchical Component Statistics 
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
O
%s
*synth27
#Hierarchical RTL Component report 
2default:defaulth p
x
� 
C
%s
*synth2+
Module pointwise_conv 
2default:defaulth p
x
� 
K
%s
*synth23
Detailed RTL Component Info : 
2default:defaulth p
x
� 
:
%s
*synth2"
+---Adders : 
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input     24 Bit       Adders := 5     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      6 Bit       Adders := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      4 Bit       Adders := 2     
2default:defaulth p
x
� 
=
%s
*synth2%
+---Registers : 
2default:defaulth p
x
� 
Z
%s
*synth2B
.	               24 Bit    Registers := 48    
2default:defaulth p
x
� 
Z
%s
*synth2B
.	               16 Bit    Registers := 1925  
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                6 Bit    Registers := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                4 Bit    Registers := 5     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                1 Bit    Registers := 53    
2default:defaulth p
x
� 
9
%s
*synth2!
+---Muxes : 
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input     24 Bit        Muxes := 276   
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input     16 Bit        Muxes := 6     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   3 Input     16 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      6 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      6 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      4 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      4 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      2 Bit        Muxes := 9     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      2 Bit        Muxes := 3     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      1 Bit        Muxes := 1228  
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   3 Input      1 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      1 Bit        Muxes := 3     
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
[
%s
*synth2C
/Finished RTL Hierarchical Component Statistics
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
H
%s
*synth20
Start Part Resource Summary
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s
*synth2k
WPart Resources:
DSPs: 220 (col length:60)
BRAMs: 280 (col length: RAMB18 60 RAMB36 30)
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
K
%s
*synth23
Finished Part Resource Summary
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
HMultithreading enabled for synth_design using a maximum of %s processes.4031*oasys2
22default:defaultZ8-5580h px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
W
%s
*synth2?
+Start Cross Boundary and Area Optimization
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB02default:default2
P[6]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB02default:default2
P[1]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB02default:default2
P[0]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB12default:default2
P[1]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB12default:default2
P[0]2default:default2
12default:defaultZ8-3917h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_group_reg[3:0]2default:default2)
stage1_group_reg[3:0]2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
1102default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_group_reg[3:0]2default:default2)
stage1_group_reg[3:0]2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
1102default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_group_reg[3:0]2default:default2)
stage1_group_reg[3:0]2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
1102default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_data_reg[15:0]2default:default2)
stage1_data_reg[15:0]2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
662default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_data_reg[15:0]2default:default2)
stage1_data_reg[15:0]2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
662default:default8@Z8-4471h px� 
r
%s
*synth2Z
FDSP Report: Generating DSP mult_results[2], operation Mode is: A2*B2.
2default:defaulth p
x
� 

%s
*synth2g
SDSP Report: register parallel_weights_reg[2] is absorbed into DSP mult_results[2].
2default:defaulth p
x
� 
w
%s
*synth2_
KDSP Report: register stage1_data_reg is absorbed into DSP mult_results[2].
2default:defaulth p
x
� 
w
%s
*synth2_
KDSP Report: operator mult_results[2] is absorbed into DSP mult_results[2].
2default:defaulth p
x
� 
r
%s
*synth2Z
FDSP Report: Generating DSP mult_results[1], operation Mode is: A2*B2.
2default:defaulth p
x
� 

%s
*synth2g
SDSP Report: register parallel_weights_reg[1] is absorbed into DSP mult_results[1].
2default:defaulth p
x
� 
w
%s
*synth2_
KDSP Report: register stage1_data_reg is absorbed into DSP mult_results[1].
2default:defaulth p
x
� 
w
%s
*synth2_
KDSP Report: operator mult_results[1] is absorbed into DSP mult_results[1].
2default:defaulth p
x
� 
r
%s
*synth2Z
FDSP Report: Generating DSP mult_results[0], operation Mode is: A2*B2.
2default:defaulth p
x
� 

%s
*synth2g
SDSP Report: register parallel_weights_reg[0] is absorbed into DSP mult_results[0].
2default:defaulth p
x
� 
w
%s
*synth2_
KDSP Report: register stage1_data_reg is absorbed into DSP mult_results[0].
2default:defaulth p
x
� 
w
%s
*synth2_
KDSP Report: operator mult_results[0] is absorbed into DSP mult_results[0].
2default:defaulth p
x
� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB22default:default2
P[6]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB22default:default2
P[1]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB22default:default2
P[0]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB22default:default2
O39[1]2default:default2
12default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB22default:default2
O39[0]2default:default2
02default:defaultZ8-3917h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[47] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[46] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[45] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[44] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[43] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[42] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[41] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[40] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[39] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[38] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[37] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[36] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[35] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[34] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[33] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[32] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[31] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[30] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[29] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[28] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[27] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[26] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[25] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[24] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[23] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[22] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[21] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[20] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[19] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[18] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[15] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[14] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[13] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[12] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[11] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2/
\accumulator_valid_reg[10] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulator_valid_reg[9] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulator_valid_reg[8] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulator_valid_reg[7] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulator_valid_reg[6] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulator_valid_reg[5] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulator_valid_reg[4] 2default:defaultZ8-3333h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[3]__0/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[2]__0/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[1]__0/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[0]__0/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
982default:default8@Z8-6858h px� 
r
%s
*synth2Z
FDSP Report: Generating DSP mult_results[3], operation Mode is: A2*B2.
2default:defaulth p
x
� 

%s
*synth2g
SDSP Report: register parallel_weights_reg[3] is absorbed into DSP mult_results[3].
2default:defaulth p
x
� 
w
%s
*synth2_
KDSP Report: register stage1_data_reg is absorbed into DSP mult_results[3].
2default:defaulth p
x
� 
w
%s
*synth2_
KDSP Report: operator mult_results[3] is absorbed into DSP mult_results[3].
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished Cross Boundary and Area Optimization : Time (s): cpu = 00:01:49 ; elapsed = 00:02:28 . Memory (MB): peak = 1154.359 ; gain = 703.625
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�---------------------------------------------------------------------------------
Start ROM, RAM, DSP and Shift Register Reporting
2default:defaulth px� 
~
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px� 
^
%s*synth2F
2
DSP: Preliminary Mapping	Report (see note below)
2default:defaulth px� 
�
%s*synth2�
+---------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+
2default:defaulth px� 
�
%s*synth2�
�|Module Name    | DSP Mapping | A Size | B Size | C Size | D Size | P Size | AREG | BREG | CREG | DREG | ADREG | MREG | PREG | 
2default:defaulth px� 
�
%s*synth2�
+---------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+
2default:defaulth px� 
�
%s*synth2�
�|pointwise_conv | A2*B2       | 16     | 16     | -      | -      | 32     | 1    | 1    | -    | -    | -     | 0    | 0    | 
2default:defaulth px� 
�
%s*synth2�
�|pointwise_conv | A2*B2       | 16     | 16     | -      | -      | 32     | 1    | 1    | -    | -    | -     | 0    | 0    | 
2default:defaulth px� 
�
%s*synth2�
�|pointwise_conv | A2*B2       | 16     | 16     | -      | -      | 32     | 1    | 1    | -    | -    | -     | 0    | 0    | 
2default:defaulth px� 
�
%s*synth2�
�|pointwise_conv | A2*B2       | 16     | 16     | -      | -      | 32     | 1    | 1    | -    | -    | -     | 0    | 0    | 
2default:defaulth px� 
�
%s*synth2�
�+---------------+-------------+--------+--------+--------+--------+--------+------+------+------+------+-------+------+------+

2default:defaulth px� 
�
%s*synth2�
�Note: The table above is a preliminary report that shows the DSPs inferred at the current stage of the synthesis flow. Some DSP may be reimplemented as non DSP primitives later in the synthesis flow. Multiple instantiated DSPs are reported only once.
2default:defaulth px� 
�
%s*synth2�
�---------------------------------------------------------------------------------
Finished ROM, RAM, DSP and Shift Register Reporting
2default:defaulth px� 
~
%s*synth2f
R---------------------------------------------------------------------------------
2default:defaulth px� 
E
%s
*synth2-

Report RTL Partitions: 
2default:defaulth p
x
� 
j
%s
*synth2R
>+------+----------------------------+------------+----------+
2default:defaulth p
x
� 
j
%s
*synth2R
>|      |RTL Partition               |Replication |Instances |
2default:defaulth p
x
� 
j
%s
*synth2R
>+------+----------------------------+------------+----------+
2default:defaulth p
x
� 
j
%s
*synth2R
>|1     |pointwise_conv__GB0         |           1|     33092|
2default:defaulth p
x
� 
j
%s
*synth2R
>|2     |pointwise_conv__GB1         |           1|     30729|
2default:defaulth p
x
� 
j
%s
*synth2R
>|3     |pointwise_conv__GB2         |           1|     13559|
2default:defaulth p
x
� 
j
%s
*synth2R
>|4     |muxpart__448_pointwise_conv |           1|     30704|
2default:defaulth p
x
� 
j
%s
*synth2R
>|5     |muxpart__455_pointwise_conv |           1|     30704|
2default:defaulth p
x
� 
j
%s
*synth2R
>|6     |pointwise_conv__GB5         |           1|     15424|
2default:defaulth p
x
� 
j
%s
*synth2R
>|7     |pointwise_conv__GB6         |           1|     15040|
2default:defaulth p
x
� 
j
%s
*synth2R
>+------+----------------------------+------------+----------+
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
F
%s
*synth2.
Start Timing Optimization
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[19][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[18][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[17][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[16][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[21][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[20][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[23][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[22][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[27][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[26][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[29][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[28][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[31][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[30][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[25][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[24][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[5][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[4][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[7][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[6][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[13][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[12][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[15][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[14][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[9][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[8][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[11][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[10][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[33][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[32][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[35][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[34][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[39][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[38][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[37][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[36][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[41][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[40][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[43][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[42][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[47][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[46][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[45][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[44][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[21][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[20][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[17][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[16][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[23][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[22][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[19][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[18][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[29][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[28][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[25][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[24][17] 2default:defaultZ8-3333h px� 
�
�Message '%s' appears more than %s times and has been disabled. User can change this message limit to see more message instances.
14*common2 
Synth 8-33332default:default2
1002default:defaultZ17-14h px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
}Finished Timing Optimization : Time (s): cpu = 00:01:53 ; elapsed = 00:02:32 . Memory (MB): peak = 1169.266 ; gain = 718.531
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
E
%s
*synth2-

Report RTL Partitions: 
2default:defaulth p
x
� 
b
%s
*synth2J
6+------+--------------------+------------+----------+
2default:defaulth p
x
� 
b
%s
*synth2J
6|      |RTL Partition       |Replication |Instances |
2default:defaulth p
x
� 
b
%s
*synth2J
6+------+--------------------+------------+----------+
2default:defaulth p
x
� 
b
%s
*synth2J
6|1     |pointwise_conv__GB0 |           1|     33042|
2default:defaulth p
x
� 
b
%s
*synth2J
6|2     |pointwise_conv__GB2 |           1|     13338|
2default:defaulth p
x
� 
b
%s
*synth2J
6|3     |pointwise_conv__GB5 |           1|       418|
2default:defaulth p
x
� 
b
%s
*synth2J
6|4     |pointwise_conv__GB6 |           1|     15040|
2default:defaulth p
x
� 
b
%s
*synth2J
6+------+--------------------+------------+----------+
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
E
%s
*synth2-
Start Technology Mapping
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
|Finished Technology Mapping : Time (s): cpu = 00:01:59 ; elapsed = 00:02:41 . Memory (MB): peak = 1169.668 ; gain = 718.934
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
E
%s
*synth2-

Report RTL Partitions: 
2default:defaulth p
x
� 
b
%s
*synth2J
6+------+--------------------+------------+----------+
2default:defaulth p
x
� 
b
%s
*synth2J
6|      |RTL Partition       |Replication |Instances |
2default:defaulth p
x
� 
b
%s
*synth2J
6+------+--------------------+------------+----------+
2default:defaulth p
x
� 
b
%s
*synth2J
6|1     |pointwise_conv__GB0 |           1|      3825|
2default:defaulth p
x
� 
b
%s
*synth2J
6|2     |pointwise_conv__GB2 |           1|     13239|
2default:defaulth p
x
� 
b
%s
*synth2J
6|3     |pointwise_conv__GB5 |           1|       350|
2default:defaulth p
x
� 
b
%s
*synth2J
6|4     |pointwise_conv__GB6 |           1|     15040|
2default:defaulth p
x
� 
b
%s
*synth2J
6+------+--------------------+------------+----------+
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
?
%s
*synth2'
Start IO Insertion
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
Q
%s
*synth29
%Start Flattening Before IO Insertion
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
T
%s
*synth2<
(Finished Flattening Before IO Insertion
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
H
%s
*synth20
Start Final Netlist Cleanup
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2,
output_ch_count_reg[0]/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
K
%s
*synth23
Finished Final Netlist Cleanup
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
vFinished IO Insertion : Time (s): cpu = 00:02:06 ; elapsed = 00:02:48 . Memory (MB): peak = 1169.668 ; gain = 718.934
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
O
%s
*synth27
#Start Renaming Generated Instances
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished Renaming Generated Instances : Time (s): cpu = 00:02:06 ; elapsed = 00:02:48 . Memory (MB): peak = 1169.668 ; gain = 718.934
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
E
%s
*synth2-

Report RTL Partitions: 
2default:defaulth p
x
� 
W
%s
*synth2?
++-+--------------+------------+----------+
2default:defaulth p
x
� 
W
%s
*synth2?
+| |RTL Partition |Replication |Instances |
2default:defaulth p
x
� 
W
%s
*synth2?
++-+--------------+------------+----------+
2default:defaulth p
x
� 
W
%s
*synth2?
++-+--------------+------------+----------+
2default:defaulth p
x
� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[5]2default:default2
1st2default:default2.
input_ch_count_reg[5]__0/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[5]2default:default2
2nd2default:default2+
input_ch_count_reg[5]/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[4]2default:default2
1st2default:default2.
input_ch_count_reg[4]__0/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[4]2default:default2
2nd2default:default2+
input_ch_count_reg[4]/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[3]2default:default2
1st2default:default2.
input_ch_count_reg[3]__0/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[3]2default:default2
2nd2default:default2+
input_ch_count_reg[3]/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[2]2default:default2
1st2default:default2.
input_ch_count_reg[2]__0/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[2]2default:default2
2nd2default:default2+
input_ch_count_reg[2]/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[1]2default:default2
1st2default:default2.
input_ch_count_reg[1]__0/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[1]2default:default2
2nd2default:default2+
input_ch_count_reg[1]/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[0]2default:default2
1st2default:default2.
input_ch_count_reg[0]__0/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2%
input_ch_count[0]2default:default2
2nd2default:default2+
input_ch_count_reg[0]/Q2default:default2H
2C:/intelFPGA/Final_Project/point/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
D
%s
*synth2,

Report Check Netlist: 
2default:defaulth p
x
� 
u
%s
*synth2]
I+------+------------------+-------+---------+-------+------------------+
2default:defaulth p
x
� 
u
%s
*synth2]
I|      |Item              |Errors |Warnings |Status |Description       |
2default:defaulth p
x
� 
u
%s
*synth2]
I+------+------------------+-------+---------+-------+------------------+
2default:defaulth p
x
� 
u
%s
*synth2]
I|1     |multi_driven_nets |      0|        6|Failed |Multi driven nets |
2default:defaulth p
x
� 
u
%s
*synth2]
I+------+------------------+-------+---------+-------+------------------+
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
L
%s
*synth24
 Start Rebuilding User Hierarchy
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished Rebuilding User Hierarchy : Time (s): cpu = 00:02:06 ; elapsed = 00:02:49 . Memory (MB): peak = 1169.668 ; gain = 718.934
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
K
%s
*synth23
Start Renaming Generated Ports
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished Renaming Generated Ports : Time (s): cpu = 00:02:06 ; elapsed = 00:02:49 . Memory (MB): peak = 1169.668 ; gain = 718.934
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
M
%s
*synth25
!Start Handling Custom Attributes
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished Handling Custom Attributes : Time (s): cpu = 00:02:06 ; elapsed = 00:02:49 . Memory (MB): peak = 1169.668 ; gain = 718.934
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
J
%s
*synth22
Start Renaming Generated Nets
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished Renaming Generated Nets : Time (s): cpu = 00:02:06 ; elapsed = 00:02:49 . Memory (MB): peak = 1169.668 ; gain = 718.934
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
K
%s
*synth23
Start Writing Synthesis Report
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
A
%s
*synth2)

Report BlackBoxes: 
2default:defaulth p
x
� 
J
%s
*synth22
+-+--------------+----------+
2default:defaulth p
x
� 
J
%s
*synth22
| |BlackBox name |Instances |
2default:defaulth p
x
� 
J
%s
*synth22
+-+--------------+----------+
2default:defaulth p
x
� 
J
%s
*synth22
+-+--------------+----------+
2default:defaulth p
x
� 
A
%s*synth2)

Report Cell Usage: 
2default:defaulth px� 
E
%s*synth2-
+------+--------+------+
2default:defaulth px� 
E
%s*synth2-
|      |Cell    |Count |
2default:defaulth px� 
E
%s*synth2-
+------+--------+------+
2default:defaulth px� 
E
%s*synth2-
|1     |BUFG    |     1|
2default:defaulth px� 
E
%s*synth2-
|2     |CARRY4  |    10|
2default:defaulth px� 
E
%s*synth2-
|3     |DSP48E1 |     1|
2default:defaulth px� 
E
%s*synth2-
|4     |LUT1    |     9|
2default:defaulth px� 
E
%s*synth2-
|5     |LUT2    |    28|
2default:defaulth px� 
E
%s*synth2-
|6     |LUT3    |    58|
2default:defaulth px� 
E
%s*synth2-
|7     |LUT4    |    33|
2default:defaulth px� 
E
%s*synth2-
|8     |LUT5    |    84|
2default:defaulth px� 
E
%s*synth2-
|9     |LUT6    |  2181|
2default:defaulth px� 
E
%s*synth2-
|10    |MUXF7   |  1088|
2default:defaulth px� 
E
%s*synth2-
|11    |MUXF8   |   544|
2default:defaulth px� 
E
%s*synth2-
|12    |FDRE    |  8256|
2default:defaulth px� 
E
%s*synth2-
|13    |IBUF    |  8218|
2default:defaulth px� 
E
%s*synth2-
|14    |OBUF    |    24|
2default:defaulth px� 
E
%s*synth2-
+------+--------+------+
2default:defaulth px� 
E
%s
*synth2-

Report Instance Areas: 
2default:defaulth p
x
� 
N
%s
*synth26
"+------+---------+-------+------+
2default:defaulth p
x
� 
N
%s
*synth26
"|      |Instance |Module |Cells |
2default:defaulth p
x
� 
N
%s
*synth26
"+------+---------+-------+------+
2default:defaulth p
x
� 
N
%s
*synth26
"|1     |top      |       | 20535|
2default:defaulth p
x
� 
N
%s
*synth26
"+------+---------+-------+------+
2default:defaulth p
x
� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished Writing Synthesis Report : Time (s): cpu = 00:02:06 ; elapsed = 00:02:49 . Memory (MB): peak = 1169.668 ; gain = 718.934
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
t
%s
*synth2\
HSynthesis finished with 0 errors, 27 critical warnings and 15 warnings.
2default:defaulth p
x
� 
�
%s
*synth2�
Synthesis Optimization Runtime : Time (s): cpu = 00:02:06 ; elapsed = 00:02:50 . Memory (MB): peak = 1169.668 ; gain = 718.934
2default:defaulth p
x
� 
�
%s
*synth2�
�Synthesis Optimization Complete : Time (s): cpu = 00:02:06 ; elapsed = 00:02:50 . Memory (MB): peak = 1169.668 ; gain = 718.934
2default:defaulth p
x
� 
B
 Translating synthesized netlist
350*projectZ1-571h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2.
Netlist sorting complete. 2default:default2
00:00:002default:default2 
00:00:00.2162default:default2
1169.6682default:default2
0.0002default:defaultZ17-268h px� 
h
-Analyzing %s Unisim elements for replacement
17*netlist2
16432default:defaultZ29-17h px� 
j
2Unisim Transformation completed in %s CPU seconds
28*netlist2
02default:defaultZ29-28h px� 
�
�Netlist '%s' is not ideal for floorplanning, since the cellview '%s' contains a large number of primitives.  Please consider enabling hierarchy in synthesis if you want to do floorplanning.
310*netlist2"
pointwise_conv2default:default2"
pointwise_conv2default:defaultZ29-101h px� 
K
)Preparing netlist for logic optimization
349*projectZ1-570h px� 
u
)Pushed %s inverter(s) to %s load pin(s).
98*opt2
02default:default2
02default:defaultZ31-138h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2.
Netlist sorting complete. 2default:default2
00:00:002default:default2 
00:00:00.0042default:default2
1221.9572default:default2
0.0002default:defaultZ17-268h px� 
~
!Unisim Transformation Summary:
%s111*project29
%No Unisim elements were transformed.
2default:defaultZ1-111h px� 
U
Releasing license: %s
83*common2
	Synthesis2default:defaultZ17-83h px� 
�
G%s Infos, %s Warnings, %s Critical Warnings and %s Errors encountered.
28*	vivadotcl2
1272default:default2
162default:default2
272default:default2
02default:defaultZ4-41h px� 
^
%s completed successfully
29*	vivadotcl2 
synth_design2default:defaultZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2"
synth_design: 2default:default2
00:02:282default:default2
00:03:162default:default2
1221.9572default:default2
796.0662default:defaultZ17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2.
Netlist sorting complete. 2default:default2
00:00:002default:default2 
00:00:00.0052default:default2
1221.9572default:default2
0.0002default:defaultZ17-268h px� 
K
"No constraints selected for write.1103*constraintsZ18-5210h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2default:default2h
TC:/intelFPGA/Final_Project/point/project_1/project_1.runs/synth_1/pointwise_conv.dcp2default:defaultZ17-1381h px� 
�
%s4*runtcl2�
rExecuting : report_utilization -file pointwise_conv_utilization_synth.rpt -pb pointwise_conv_utilization_synth.pb
2default:defaulth px� 
�
Exiting %s at %s...
206*common2
Vivado2default:default2,
Wed Jul  2 15:37:03 20252default:defaultZ17-206h px� 


End Record