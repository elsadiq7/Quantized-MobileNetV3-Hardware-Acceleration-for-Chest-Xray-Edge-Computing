
w
Command: %s
53*	vivadotcl2F
2synth_design -top shortcut -part xc7z020iclg400-1L2default:defaultZ4-113h px� 
:
Starting synth_design
149*	vivadotclZ4-321h px� 
�
@Attempting to get a license for feature '%s' and/or device '%s'
308*common2
	Synthesis2default:default2
xc7z020i2default:defaultZ17-347h px� 
�
0Got license for feature '%s' and/or device '%s'
310*common2
	Synthesis2default:default2
xc7z020i2default:defaultZ17-349h px� 
�
%s*synth2�
sStarting Synthesize : Time (s): cpu = 00:00:03 ; elapsed = 00:00:05 . Memory (MB): peak = 687.664 ; gain = 237.500
2default:defaulth px� 
�
synthesizing module '%s'%s4497*oasys2
shortcut2default:default2
 2default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
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
e
%s
*synth2M
9	Parameter SPATIAL_PARALLEL bound to: 2 - type: integer 
2default:defaulth p
x
� 
e
%s
*synth2M
9	Parameter CHANNEL_PARALLEL bound to: 4 - type: integer 
2default:defaulth p
x
� 
h
%s
*synth2P
<	Parameter TOTAL_PIXEL_GROUPS bound to: 98 - type: integer 
2default:defaulth p
x
� 
�
synthesizing module '%s'%s4497*oasys2"
pointwise_conv2default:default2
 2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
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
block2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
292default:default8@Z8-5534h px� 
�
display: %s251*oasys2J
6Loaded 1920 weights for parallel pointwise convolution2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1322default:default8@Z8-251h px� 
�
display: %s251*oasys2C
/Parallel Input[x]: Data=0xxxxx, InCh=x, Group=x2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1672default:default8@Z8-251h px� 
�
display: %s251*oasys2H
4Parallel Accumulation: Group=x, OutCh[x-x] processed2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1862default:default8@Z8-251h px� 
�
display: %s251*oasys2T
@Parallel Output[x]: Data=0xxxxx, Channel=x, Accumulator=0xxxxxxx2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2102default:default8@Z8-251h px� 
�
'system function call '%s' not supported639*oasys2
time2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2282default:default8@Z8-639h px� 
�
display: %s251*oasys2I
5Parallel pointwise convolution completed at time 1'b02default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2282default:default8@Z8-251h px� 
�
-case statement is not full and has no default155*oasys2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2722default:default8@Z8-155h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2#
pixel_count_reg2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1002default:default8@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2%
output_active_reg2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1052default:default8@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2$
stage1_in_ch_reg2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1092default:default8@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2#
pixel_count_reg2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2782default:default8@Z8-6014h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2"
pointwise_conv2default:default2
 2default:default2
12default:default2
12default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
12default:default8@Z8-6155h px� 
�
synthesizing module '%s'%s4497*oasys2
	batchnorm2default:default2
 2default:default2R
<C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/batchnorm.sv2default:default2
12default:default8@Z8-6157h px� 
[
%s
*synth2C
/	Parameter WIDTH bound to: 16 - type: integer 
2default:defaulth p
x
� 
Y
%s
*synth2A
-	Parameter FRAC bound to: 8 - type: integer 
2default:defaulth p
x
� 
^
%s
*synth2F
2	Parameter CHANNELS bound to: 48 - type: integer 
2default:defaulth p
x
� 
`
%s
*synth2H
4	Parameter EPSILON bound to: 16'sb0000000000010000 
2default:defaulth p
x
� 
�
"Detected attribute (* %s = "%s" *)3982*oasys2
	ram_style2default:default2
block2default:default2R
<C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/batchnorm.sv2default:default2
262default:default8@Z8-5534h px� 
�
"Detected attribute (* %s = "%s" *)3982*oasys2
	ram_style2default:default2
block2default:default2R
<C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/batchnorm.sv2default:default2
272default:default8@Z8-5534h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2 
x_reg_reg[2]2default:default2R
<C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/batchnorm.sv2default:default2
892default:default8@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2 
x_reg_reg[3]2default:default2R
<C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/batchnorm.sv2default:default2
892default:default8@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2$
gamma_reg_reg[2]2default:default2R
<C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/batchnorm.sv2default:default2
942default:default8@Z8-6014h px� 
�
+Unused sequential element %s was removed. 
4326*oasys2'
scaled_extended_reg2default:default2R
<C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/batchnorm.sv2default:default2
1022default:default8@Z8-6014h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
	batchnorm2default:default2
 2default:default2
22default:default2
12default:default2R
<C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/batchnorm.sv2default:default2
12default:default8@Z8-6155h px� 
�
display: %s251*oasys2_
KTransitioning to COMPLETING: input_finished=1'b1, output_count=x, target=732default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
1132default:default8@Z8-251h px� 
�
display: %s251*oasys2U
APROCESSING: input_finished=1'bx, output_count=x/98, input_count=x2default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
1192default:default8@Z8-251h px� 
�
'system function call '%s' not supported639*oasys2
time2default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
1312default:default8@Z8-639h px� 
�
display: %s251*oasys2R
>Transitioning to DONE_STATE at time 1'b0, completion_counter=x2default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
1302default:default8@Z8-251h px� 
�
'system function call '%s' not supported639*oasys2
time2default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
1902default:default8@Z8-639h px� 
�
display: %s251*oasys2U
AInput finished at time 1'b0, input_count=x, TOTAL_PIXEL_GROUPS=982default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
1892default:default8@Z8-251h px� 
�
'system function call '%s' not supported639*oasys2
time2default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
1992default:default8@Z8-639h px� 
�
display: %s251*oasys2N
:Input finished by timeout at time 1'b0, no_input_counter=x2default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
1982default:default8@Z8-251h px� 
�
'system function call '%s' not supported639*oasys2
time2default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
2212default:default8@Z8-639h px� 
�
display: %s251*oasys2:
&Entering COMPLETING state at time 1'b02default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
2212default:default8@Z8-251h px� 
�
display: %s251*oasys2<
(Input finished: 1'bx, Output count: x/982default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
2222default:default8@Z8-251h px� 
�
-case statement is not full and has no default155*oasys2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
1642default:default8@Z8-155h px� 
�
'done synthesizing module '%s'%s (%s#%s)4495*oasys2
shortcut2default:default2
 2default:default2
32default:default2
12default:default2Q
;C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut.sv2default:default2
12default:default8@Z8-6155h px� 
�
%s*synth2�
sFinished Synthesize : Time (s): cpu = 00:00:15 ; elapsed = 00:00:17 . Memory (MB): peak = 930.988 ; gain = 480.824
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
~Finished Constraint Validation : Time (s): cpu = 00:00:17 ; elapsed = 00:00:19 . Memory (MB): peak = 930.988 ; gain = 480.824
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
L
%s
*synth24
 Loading part: xc7z020iclg400-1L
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
�Finished Loading Part and Timing Information : Time (s): cpu = 00:00:17 ; elapsed = 00:00:19 . Memory (MB): peak = 930.988 ; gain = 480.824
2default:defaulth px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
X
Loading part %s157*device2%
xc7z020iclg400-1L2default:defaultZ21-403h px� 
�
3inferred FSM for state register '%s' in module '%s'802*oasys2
	state_reg2default:default2"
pointwise_conv2default:defaultZ8-802h px� 
�
3inferred FSM for state register '%s' in module '%s'802*oasys2
	state_reg2default:default2
shortcut2default:defaultZ8-802h px� 
�
3inferred FSM for state register '%s' in module '%s'802*oasys2
	state_reg2default:default22
pointwise_conv__hierPathDup__12default:defaultZ8-802h px� 
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

sequential2default:default22
pointwise_conv__hierPathDup__12default:defaultZ8-3354h px� 
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
_                    IDLE |                             0001 |                              000
2default:defaulth p
x
� 
�
%s
*synth2s
_              PROCESSING |                             0010 |                              001
2default:defaulth p
x
� 
�
%s
*synth2s
_              COMPLETING |                             0100 |                              010
2default:defaulth p
x
� 
�
%s
*synth2s
_              DONE_STATE |                             1000 |                              011
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
	state_reg2default:default2
one-hot2default:default2
shortcut2default:defaultZ8-3354h px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished RTL Optimization Phase 2 : Time (s): cpu = 00:01:04 ; elapsed = 00:01:06 . Memory (MB): peak = 1357.785 ; gain = 907.621
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
z
%s
*synth2b
N+------+--------------------------------------------+------------+----------+
2default:defaulth p
x
� 
z
%s
*synth2b
N|      |RTL Partition                               |Replication |Instances |
2default:defaulth p
x
� 
z
%s
*synth2b
N+------+--------------------------------------------+------------+----------+
2default:defaulth p
x
� 
z
%s
*synth2b
N|1     |pointwise_conv__hierPathDup__1__GB0         |           1|     32000|
2default:defaulth p
x
� 
z
%s
*synth2b
N|2     |muxpart__443_pointwise_conv__hierPathDup__1 |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|3     |pointwise_conv__hierPathDup__1__GB2         |           1|     16522|
2default:defaulth p
x
� 
z
%s
*synth2b
N|4     |muxpart__448_pointwise_conv__hierPathDup__1 |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|5     |muxpart__455_pointwise_conv__hierPathDup__1 |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|6     |pointwise_conv__hierPathDup__1__GB5         |           1|     41513|
2default:defaulth p
x
� 
z
%s
*synth2b
N|7     |pointwise_conv__GB0                         |           1|     32000|
2default:defaulth p
x
� 
z
%s
*synth2b
N|8     |muxpart__1216_pointwise_conv                |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|9     |pointwise_conv__GB2                         |           1|     16522|
2default:defaulth p
x
� 
z
%s
*synth2b
N|10    |muxpart__1221_pointwise_conv                |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|11    |muxpart__1228_pointwise_conv                |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|12    |pointwise_conv__GB5                         |           1|     41513|
2default:defaulth p
x
� 
z
%s
*synth2b
N|13    |shortcut__GC0                               |           1|      7016|
2default:defaulth p
x
� 
z
%s
*synth2b
N+------+--------------------------------------------+------------+----------+
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
.	   2 Input     24 Bit       Adders := 10    
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input     16 Bit       Adders := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      8 Bit       Adders := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      7 Bit       Adders := 3     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      6 Bit       Adders := 4     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      4 Bit       Adders := 6     
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
.	               24 Bit    Registers := 96    
2default:defaulth p
x
� 
Z
%s
*synth2B
.	               16 Bit    Registers := 4058  
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                7 Bit    Registers := 3     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                6 Bit    Registers := 12    
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                4 Bit    Registers := 12    
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                1 Bit    Registers := 123   
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
.	   2 Input     24 Bit        Muxes := 552   
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input     16 Bit        Muxes := 18    
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   3 Input     16 Bit        Muxes := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input     16 Bit        Muxes := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   5 Input     16 Bit        Muxes := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   3 Input      9 Bit        Muxes := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      7 Bit        Muxes := 3     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      6 Bit        Muxes := 6     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      6 Bit        Muxes := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      4 Bit        Muxes := 7     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      4 Bit        Muxes := 5     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      2 Bit        Muxes := 18    
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      2 Bit        Muxes := 6     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      1 Bit        Muxes := 2466  
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   3 Input      1 Bit        Muxes := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      1 Bit        Muxes := 17    
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
=
%s
*synth2%
Module shortcut 
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
.	   2 Input      8 Bit       Adders := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      7 Bit       Adders := 3     
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
.	                7 Bit    Registers := 3     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                4 Bit    Registers := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                1 Bit    Registers := 3     
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
.	   4 Input      7 Bit        Muxes := 3     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      4 Bit        Muxes := 5     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      4 Bit        Muxes := 3     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      1 Bit        Muxes := 4     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input      1 Bit        Muxes := 11    
2default:defaulth p
x
� 
S
%s
*synth2;
'Module pointwise_conv__hierPathDup__1 
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
A
%s
*synth2)
Module batchnorm__1 
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
.	   2 Input     16 Bit       Adders := 1     
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
.	               16 Bit    Registers := 104   
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                6 Bit    Registers := 5     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                1 Bit    Registers := 7     
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
.	   2 Input     16 Bit        Muxes := 3     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input     16 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   5 Input     16 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   3 Input      9 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      6 Bit        Muxes := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      1 Bit        Muxes := 3     
2default:defaulth p
x
� 
>
%s
*synth2&
Module batchnorm 
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
.	   2 Input     16 Bit       Adders := 1     
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
.	               16 Bit    Registers := 104   
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                6 Bit    Registers := 5     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	                1 Bit    Registers := 7     
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
.	   2 Input     16 Bit        Muxes := 3     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   4 Input     16 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   5 Input     16 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   3 Input      9 Bit        Muxes := 1     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      6 Bit        Muxes := 2     
2default:defaulth p
x
� 
Z
%s
*synth2B
.	   2 Input      1 Bit        Muxes := 3     
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
%s
*synth2p
\DSP Report: Generating DSP gen_bn[0].bn_inst/mult_result_reg, operation Mode is: (A''*B2)'.
2default:defaulth p
x
� 
�
%s
*synth2�
pDSP Report: register gen_bn[0].bn_inst/gamma_reg_reg[1] is absorbed into DSP gen_bn[0].bn_inst/mult_result_reg.
2default:defaulth p
x
� 
�
%s
*synth2�
lDSP Report: register gen_bn[0].bn_inst/x_reg_reg[0] is absorbed into DSP gen_bn[0].bn_inst/mult_result_reg.
2default:defaulth p
x
� 
�
%s
*synth2�
lDSP Report: register gen_bn[0].bn_inst/x_reg_reg[1] is absorbed into DSP gen_bn[0].bn_inst/mult_result_reg.
2default:defaulth p
x
� 
�
%s
*synth2�
oDSP Report: register gen_bn[0].bn_inst/mult_result_reg is absorbed into DSP gen_bn[0].bn_inst/mult_result_reg.
2default:defaulth p
x
� 
�
%s
*synth2�
lDSP Report: operator gen_bn[0].bn_inst/mult_result0 is absorbed into DSP gen_bn[0].bn_inst/mult_result_reg.
2default:defaulth p
x
� 
�
%s
*synth2p
\DSP Report: Generating DSP gen_bn[1].bn_inst/mult_result_reg, operation Mode is: (A''*B2)'.
2default:defaulth p
x
� 
�
%s
*synth2�
pDSP Report: register gen_bn[1].bn_inst/gamma_reg_reg[1] is absorbed into DSP gen_bn[1].bn_inst/mult_result_reg.
2default:defaulth p
x
� 
�
%s
*synth2�
lDSP Report: register gen_bn[1].bn_inst/x_reg_reg[0] is absorbed into DSP gen_bn[1].bn_inst/mult_result_reg.
2default:defaulth p
x
� 
�
%s
*synth2�
lDSP Report: register gen_bn[1].bn_inst/x_reg_reg[1] is absorbed into DSP gen_bn[1].bn_inst/mult_result_reg.
2default:defaulth p
x
� 
�
%s
*synth2�
oDSP Report: register gen_bn[1].bn_inst/mult_result_reg is absorbed into DSP gen_bn[1].bn_inst/mult_result_reg.
2default:defaulth p
x
� 
�
%s
*synth2�
lDSP Report: operator gen_bn[1].bn_inst/mult_result0 is absorbed into DSP gen_bn[1].bn_inst/mult_result_reg.
2default:defaulth p
x
� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2@
,i_0/gen_bn[0].bn_inst/memory_initialized_reg2default:default2
FDRE2default:default2@
,i_0/gen_bn[1].bn_inst/memory_initialized_reg2default:defaultZ8-3886h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_group_reg[3:0]2default:default2)
stage1_group_reg[3:0]2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1102default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_group_reg[3:0]2default:default2)
stage1_group_reg[3:0]2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1102default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_group_reg[3:0]2default:default2)
stage1_group_reg[3:0]2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1102default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_data_reg[15:0]2default:default2)
stage1_data_reg[15:0]2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
662default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_data_reg[15:0]2default:default2)
stage1_data_reg[15:0]2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
662default:default8@Z8-4471h px� 
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
�
+design %s has port %s driven by constant %s3447*oasys27
#pointwise_conv__hierPathDup__1__GB22default:default2
O1[6]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys27
#pointwise_conv__hierPathDup__1__GB22default:default2
O1[1]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys27
#pointwise_conv__hierPathDup__1__GB22default:default2
O1[0]2default:default2
02default:defaultZ8-3917h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2'
stage1_group_reg[0]2default:default2
FDRE2default:default2'
stage1_group_reg[1]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2'
stage1_group_reg[1]2default:default2
FDRE2default:default2'
stage1_group_reg[2]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2'
stage1_group_reg[2]2default:default2
FDRE2default:default2'
stage1_group_reg[3]2default:defaultZ8-3886h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2)
\stage1_group_reg[3] 2default:defaultZ8-3333h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[3]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[2]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[1]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[0]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
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
�
"merging instance '%s' (%s) to '%s'3436*oasys2&
channel_out_reg[0]2default:default2
FDRE2default:default2&
channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2&
channel_out_reg[1]2default:default2
FDRE2default:default2&
channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2&
channel_out_reg[2]2default:default2
FDRE2default:default2&
channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2&
channel_out_reg[3]2default:default2
FDRE2default:default2&
channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2&
channel_out_reg[4]2default:default2
FDRE2default:default2&
channel_out_reg[5]2default:defaultZ8-3886h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2(
\channel_out_reg[5] 2default:defaultZ8-3333h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_group_reg[3:0]2default:default2)
stage1_group_reg[3:0]2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1102default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_group_reg[3:0]2default:default2)
stage1_group_reg[3:0]2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1102default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_group_reg[3:0]2default:default2)
stage1_group_reg[3:0]2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
1102default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_data_reg[15:0]2default:default2)
stage1_data_reg[15:0]2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
662default:default8@Z8-4471h px� 
�
merging register '%s' into '%s'3619*oasys2)
stage1_data_reg[15:0]2default:default2)
stage1_data_reg[15:0]2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
662default:default8@Z8-4471h px� 
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
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB22default:default2
O109[6]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB22default:default2
O109[1]2default:default2
02default:defaultZ8-3917h px� 
�
+design %s has port %s driven by constant %s3447*oasys2'
pointwise_conv__GB22default:default2
O109[0]2default:default2
02default:defaultZ8-3917h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2'
stage1_group_reg[0]2default:default2
FDRE2default:default2'
stage1_group_reg[1]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2'
stage1_group_reg[1]2default:default2
FDRE2default:default2'
stage1_group_reg[2]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2'
stage1_group_reg[2]2default:default2
FDRE2default:default2'
stage1_group_reg[3]2default:defaultZ8-3886h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2)
\stage1_group_reg[3] 2default:defaultZ8-3333h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[3]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[2]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[1]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2+
group_count_reg[0]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
982default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
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
�
"merging instance '%s' (%s) to '%s'3436*oasys2&
channel_out_reg[0]2default:default2
FDRE2default:default2&
channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2&
channel_out_reg[1]2default:default2
FDRE2default:default2&
channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2&
channel_out_reg[2]2default:default2
FDRE2default:default2&
channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2&
channel_out_reg[3]2default:default2
FDRE2default:default2&
channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2&
channel_out_reg[4]2default:default2
FDRE2default:default2&
channel_out_reg[5]2default:defaultZ8-3886h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2(
\channel_out_reg[5] 2default:defaultZ8-3333h px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
�Finished Cross Boundary and Area Optimization : Time (s): cpu = 00:02:04 ; elapsed = 00:03:15 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
�|batchnorm      | (A''*B2)'   | 16     | 16     | -      | -      | 32     | 2    | 1    | -    | -    | -     | 1    | 0    | 
2default:defaulth px� 
�
%s*synth2�
�|batchnorm      | (A''*B2)'   | 16     | 16     | -      | -      | 32     | 2    | 1    | -    | -    | -     | 1    | 0    | 
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
z
%s
*synth2b
N+------+--------------------------------------------+------------+----------+
2default:defaulth p
x
� 
z
%s
*synth2b
N|      |RTL Partition                               |Replication |Instances |
2default:defaulth p
x
� 
z
%s
*synth2b
N+------+--------------------------------------------+------------+----------+
2default:defaulth p
x
� 
z
%s
*synth2b
N|1     |pointwise_conv__hierPathDup__1__GB0         |           1|     32000|
2default:defaulth p
x
� 
z
%s
*synth2b
N|2     |muxpart__443_pointwise_conv__hierPathDup__1 |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|3     |pointwise_conv__hierPathDup__1__GB2         |           1|     14612|
2default:defaulth p
x
� 
z
%s
*synth2b
N|4     |muxpart__448_pointwise_conv__hierPathDup__1 |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|5     |muxpart__455_pointwise_conv__hierPathDup__1 |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|6     |pointwise_conv__hierPathDup__1__GB5         |           1|     30586|
2default:defaulth p
x
� 
z
%s
*synth2b
N|7     |pointwise_conv__GB0                         |           1|     32000|
2default:defaulth p
x
� 
z
%s
*synth2b
N|8     |muxpart__1216_pointwise_conv                |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|9     |pointwise_conv__GB2                         |           1|     14612|
2default:defaulth p
x
� 
z
%s
*synth2b
N|10    |muxpart__1221_pointwise_conv                |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|11    |muxpart__1228_pointwise_conv                |           1|     30704|
2default:defaulth p
x
� 
z
%s
*synth2b
N|12    |pointwise_conv__GB5                         |           1|     30586|
2default:defaulth p
x
� 
z
%s
*synth2b
N|13    |shortcut__GC0                               |           1|      6840|
2default:defaulth p
x
� 
z
%s
*synth2b
N+------+--------------------------------------------+------------+----------+
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
\accumulators_reg[25][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[24][16] 2default:defaultZ8-3333h px� 
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
\accumulators_reg[31][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[30][16] 2default:defaultZ8-3333h px� 
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
\accumulators_reg[17][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[16][16] 2default:defaultZ8-3333h px� 
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
\accumulators_reg[23][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[22][16] 2default:defaultZ8-3333h px� 
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
\accumulators_reg[15][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[14][16] 2default:defaultZ8-3333h px� 
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
\accumulators_reg[11][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[10][16] 2default:defaultZ8-3333h px� 
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
\accumulators_reg[35][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[34][16] 2default:defaultZ8-3333h px� 
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
\accumulators_reg[41][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[40][16] 2default:defaultZ8-3333h px� 
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
\accumulators_reg[43][16] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[42][16] 2default:defaultZ8-3333h px� 
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
02default:default2-
\accumulators_reg[7][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[6][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[5][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[4][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[11][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[10][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[9][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[8][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[15][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[14][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[13][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[12][17] 2default:defaultZ8-3333h px� 
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
\accumulators_reg[19][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[18][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[31][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[30][17] 2default:defaultZ8-3333h px� 
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
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[27][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[26][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[39][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[38][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[37][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[36][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[33][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[32][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[35][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[34][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[41][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[40][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[43][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[42][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[47][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[46][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[45][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[44][17] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[7][18] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[6][18] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[5][18] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[4][18] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[9][18] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2-
\accumulators_reg[8][18] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[13][18] 2default:defaultZ8-3333h px� 
�
6propagating constant %s across sequential element (%s)3333*oasys2
02default:default2.
\accumulators_reg[12][18] 2default:defaultZ8-3333h px� 
�
�Message '%s' appears more than %s times and has been disabled. User can change this message limit to see more message instances.
14*common2 
Synth 8-33332default:default2
1002default:defaultZ17-14h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2M
9gen_pw_conv1[1].pw_conv1_insti_5/accumulator_valid_reg[3]2default:default2
FDRE2default:default2M
9gen_pw_conv1[1].pw_conv1_insti_5/accumulator_valid_reg[2]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2M
9gen_pw_conv1[1].pw_conv1_insti_5/accumulator_valid_reg[2]2default:default2
FDRE2default:default2M
9gen_pw_conv1[1].pw_conv1_insti_5/accumulator_valid_reg[1]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2M
9gen_pw_conv1[0].pw_conv1_insti_2/accumulator_valid_reg[3]2default:default2
FDRE2default:default2M
9gen_pw_conv1[0].pw_conv1_insti_2/accumulator_valid_reg[2]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2M
9gen_pw_conv1[0].pw_conv1_insti_2/accumulator_valid_reg[2]2default:default2
FDRE2default:default2M
9gen_pw_conv1[0].pw_conv1_insti_2/accumulator_valid_reg[1]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[1][0]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[1][1]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[1][1]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[1][2]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[1][2]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[1][3]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[1][3]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[1][4]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[1][4]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[1][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[1][0]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[1][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[1][1]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[1][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[1][2]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[1][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[1][3]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[1][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[1][4]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[1][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[2][0]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[2][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[2][1]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[2][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[2][2]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[2][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[2][3]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[2][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[2][4]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[2][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[2][0]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[2][1]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[2][1]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[2][2]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[2][2]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[2][3]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[2][3]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[2][4]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[2][4]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[2][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[3][0]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[3][1]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[3][1]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[3][2]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[3][2]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[3][3]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[3][3]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[3][4]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[3][4]2default:default2
FDRE2default:default2:
&i_0/gen_bn[0].bn_inst/ch_reg_reg[3][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[3][0]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[3][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[3][1]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[3][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[3][2]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[3][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[3][3]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[3][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[3][4]2default:default2
FDRE2default:default2:
&i_0/gen_bn[1].bn_inst/ch_reg_reg[3][5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2<
(i_0/gen_bn[0].bn_inst/channel_out_reg[0]2default:default2
FDR2default:default2<
(i_0/gen_bn[0].bn_inst/channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2<
(i_0/gen_bn[0].bn_inst/channel_out_reg[1]2default:default2
FDR2default:default2<
(i_0/gen_bn[0].bn_inst/channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2<
(i_0/gen_bn[0].bn_inst/channel_out_reg[2]2default:default2
FDR2default:default2<
(i_0/gen_bn[0].bn_inst/channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2<
(i_0/gen_bn[0].bn_inst/channel_out_reg[3]2default:default2
FDR2default:default2<
(i_0/gen_bn[0].bn_inst/channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2<
(i_0/gen_bn[0].bn_inst/channel_out_reg[4]2default:default2
FDR2default:default2<
(i_0/gen_bn[0].bn_inst/channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2<
(i_0/gen_bn[1].bn_inst/channel_out_reg[0]2default:default2
FDR2default:default2<
(i_0/gen_bn[1].bn_inst/channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2<
(i_0/gen_bn[1].bn_inst/channel_out_reg[1]2default:default2
FDR2default:default2<
(i_0/gen_bn[1].bn_inst/channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2<
(i_0/gen_bn[1].bn_inst/channel_out_reg[2]2default:default2
FDR2default:default2<
(i_0/gen_bn[1].bn_inst/channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2<
(i_0/gen_bn[1].bn_inst/channel_out_reg[3]2default:default2
FDR2default:default2<
(i_0/gen_bn[1].bn_inst/channel_out_reg[5]2default:defaultZ8-3886h px� 
�
"merging instance '%s' (%s) to '%s'3436*oasys2<
(i_0/gen_bn[1].bn_inst/channel_out_reg[4]2default:default2
FDR2default:default2<
(i_0/gen_bn[1].bn_inst/channel_out_reg[5]2default:defaultZ8-3886h px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
}Finished Timing Optimization : Time (s): cpu = 00:02:15 ; elapsed = 00:03:27 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
r
%s
*synth2Z
F+------+------------------------------------+------------+----------+
2default:defaulth p
x
� 
r
%s
*synth2Z
F|      |RTL Partition                       |Replication |Instances |
2default:defaulth p
x
� 
r
%s
*synth2Z
F+------+------------------------------------+------------+----------+
2default:defaulth p
x
� 
r
%s
*synth2Z
F|1     |pointwise_conv__hierPathDup__1__GB0 |           1|      1008|
2default:defaulth p
x
� 
r
%s
*synth2Z
F|2     |pointwise_conv__hierPathDup__1__GB2 |           1|       206|
2default:defaulth p
x
� 
r
%s
*synth2Z
F|3     |pointwise_conv__hierPathDup__1__GB5 |           1|      1201|
2default:defaulth p
x
� 
r
%s
*synth2Z
F|4     |pointwise_conv__GB0                 |           1|      1008|
2default:defaulth p
x
� 
r
%s
*synth2Z
F|5     |pointwise_conv__GB2                 |           1|       206|
2default:defaulth p
x
� 
r
%s
*synth2Z
F|6     |pointwise_conv__GB5                 |           1|      1200|
2default:defaulth p
x
� 
r
%s
*synth2Z
F|7     |shortcut__GC0                       |           1|       680|
2default:defaulth p
x
� 
r
%s
*synth2Z
F+------+------------------------------------+------------+----------+
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
]
%s
*synth2E
1Warning: Parallel synthesis criteria is not met 
2default:defaulth p
x
� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[0].pw_conv1_inst/output_ch_count_reg[5]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[0].pw_conv1_inst/output_ch_count_reg[4]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[0].pw_conv1_inst/output_ch_count_reg[3]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[0].pw_conv1_inst/output_ch_count_reg[2]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[0].pw_conv1_inst/output_ch_count_reg[1]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[0].pw_conv1_inst/output_ch_count_reg[0]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[1].pw_conv1_inst/output_ch_count_reg[5]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[1].pw_conv1_inst/output_ch_count_reg[4]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[1].pw_conv1_inst/output_ch_count_reg[3]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[1].pw_conv1_inst/output_ch_count_reg[2]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[1].pw_conv1_inst/output_ch_count_reg[1]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
1st2default:default2J
6gen_pw_conv1[1].pw_conv1_inst/output_ch_count_reg[0]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2
Q2default:default2
2nd2default:default2
GND2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6859h px� 
�
rmulti-driven net %s is connected to at least one constant driver which has been preserved, other driver is ignored4707*oasys2
Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2872default:default8@Z8-6858h px� 
~
%s
*synth2f
R---------------------------------------------------------------------------------
2default:defaulth p
x
� 
�
%s*synth2�
|Finished Technology Mapping : Time (s): cpu = 00:02:16 ; elapsed = 00:03:28 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
vFinished IO Insertion : Time (s): cpu = 00:02:20 ; elapsed = 00:03:33 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
�Finished Renaming Generated Instances : Time (s): cpu = 00:02:20 ; elapsed = 00:03:33 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[5]2default:default2
1st2default:default2L
8gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[5]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[5]2default:default2
2nd2default:default2I
5gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[5]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[4]2default:default2
1st2default:default2L
8gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[4]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[4]2default:default2
2nd2default:default2I
5gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[4]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[3]2default:default2
1st2default:default2L
8gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[3]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[3]2default:default2
2nd2default:default2I
5gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[3]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[2]2default:default2
1st2default:default2L
8gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[2]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[2]2default:default2
2nd2default:default2I
5gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[2]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[1]2default:default2
1st2default:default2L
8gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[1]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[1]2default:default2
2nd2default:default2I
5gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[1]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[0]2default:default2
1st2default:default2L
8gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[0]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[0].pw_conv1_inst/input_ch_count[0]2default:default2
2nd2default:default2I
5gen_pw_conv1[0].pw_conv1_inst/input_ch_count_reg[0]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[5]2default:default2
1st2default:default2L
8gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[5]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[5]2default:default2
2nd2default:default2I
5gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[5]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[4]2default:default2
1st2default:default2L
8gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[4]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[4]2default:default2
2nd2default:default2I
5gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[4]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[3]2default:default2
1st2default:default2L
8gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[3]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[3]2default:default2
2nd2default:default2I
5gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[3]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[2]2default:default2
1st2default:default2L
8gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[2]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[2]2default:default2
2nd2default:default2I
5gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[2]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[1]2default:default2
1st2default:default2L
8gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[1]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[1]2default:default2
2nd2default:default2I
5gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[1]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
2982default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[0]2default:default2
1st2default:default2L
8gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[0]__0/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
992default:default8@Z8-6859h px� 
�
2multi-driven net on pin %s with %s driver pin '%s'4708*oasys2C
/gen_pw_conv1[1].pw_conv1_inst/input_ch_count[0]2default:default2
2nd2default:default2I
5gen_pw_conv1[1].pw_conv1_inst/input_ch_count_reg[0]/Q2default:default2W
AC:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/pointwise_conv.sv2default:default2
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
I|1     |multi_driven_nets |      0|       12|Failed |Multi driven nets |
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
�Finished Rebuilding User Hierarchy : Time (s): cpu = 00:02:21 ; elapsed = 00:03:33 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
�Finished Renaming Generated Ports : Time (s): cpu = 00:02:21 ; elapsed = 00:03:33 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
�Finished Handling Custom Attributes : Time (s): cpu = 00:02:21 ; elapsed = 00:03:33 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
�Finished Renaming Generated Nets : Time (s): cpu = 00:02:21 ; elapsed = 00:03:33 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
|2     |CARRY4  |    26|
2default:defaulth px� 
E
%s*synth2-
|3     |DSP48E1 |     4|
2default:defaulth px� 
E
%s*synth2-
|4     |LUT1    |    16|
2default:defaulth px� 
E
%s*synth2-
|5     |LUT2    |    63|
2default:defaulth px� 
E
%s*synth2-
|6     |LUT3    |   151|
2default:defaulth px� 
E
%s*synth2-
|7     |LUT4    |    83|
2default:defaulth px� 
E
%s*synth2-
|8     |LUT5    |    63|
2default:defaulth px� 
E
%s*synth2-
|9     |LUT6    |   580|
2default:defaulth px� 
E
%s*synth2-
|10    |MUXF7   |   256|
2default:defaulth px� 
E
%s*synth2-
|11    |MUXF8   |   128|
2default:defaulth px� 
E
%s*synth2-
|12    |FDRE    |  2478|
2default:defaulth px� 
E
%s*synth2-
|13    |FDSE    |     3|
2default:defaulth px� 
E
%s*synth2-
|14    |IBUF    |  1113|
2default:defaulth px� 
E
%s*synth2-
|15    |OBUF    |    62|
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

%s
*synth2g
S+------+----------------------------------+-------------------------------+------+
2default:defaulth p
x
� 

%s
*synth2g
S|      |Instance                          |Module                         |Cells |
2default:defaulth p
x
� 

%s
*synth2g
S+------+----------------------------------+-------------------------------+------+
2default:defaulth p
x
� 

%s
*synth2g
S|1     |top                               |                               |  5027|
2default:defaulth p
x
� 

%s
*synth2g
S|2     |  \gen_bn[0].bn_inst              |batchnorm                      |   178|
2default:defaulth p
x
� 

%s
*synth2g
S|3     |  \gen_bn[1].bn_inst              |batchnorm_0                    |   186|
2default:defaulth p
x
� 

%s
*synth2g
S|4     |  \gen_pw_conv1[0].pw_conv1_inst  |pointwise_conv__hierPathDup__1 |  1700|
2default:defaulth p
x
� 

%s
*synth2g
S|5     |  \gen_pw_conv1[1].pw_conv1_inst  |pointwise_conv                 |  1700|
2default:defaulth p
x
� 

%s
*synth2g
S+------+----------------------------------+-------------------------------+------+
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
�Finished Writing Synthesis Report : Time (s): cpu = 00:02:21 ; elapsed = 00:03:33 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
HSynthesis finished with 0 errors, 84 critical warnings and 19 warnings.
2default:defaulth p
x
� 
�
%s
*synth2�
Synthesis Optimization Runtime : Time (s): cpu = 00:02:21 ; elapsed = 00:03:34 . Memory (MB): peak = 1405.840 ; gain = 955.676
2default:defaulth p
x
� 
�
%s
*synth2�
�Synthesis Optimization Complete : Time (s): cpu = 00:02:21 ; elapsed = 00:03:34 . Memory (MB): peak = 1405.840 ; gain = 955.676
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
00:00:00.1012default:default2
1405.8402default:default2
0.0002default:defaultZ17-268h px� 
g
-Analyzing %s Unisim elements for replacement
17*netlist2
4142default:defaultZ29-17h px� 
j
2Unisim Transformation completed in %s CPU seconds
28*netlist2
12default:defaultZ29-28h px� 
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
00:00:00.0022default:default2
1405.8402default:default2
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
2112default:default2
192default:default2
842default:default2
02default:defaultZ4-41h px� 
^
%s completed successfully
29*	vivadotcl2 
synth_design2default:defaultZ4-42h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2"
synth_design: 2default:default2
00:02:382default:default2
00:03:542default:default2
1405.8402default:default2
980.5162default:defaultZ17-268h px� 
�
I%sTime (s): cpu = %s ; elapsed = %s . Memory (MB): peak = %s ; gain = %s
268*common2.
Netlist sorting complete. 2default:default2
00:00:002default:default2 
00:00:00.0012default:default2
1405.8402default:default2
0.0002default:defaultZ17-268h px� 
K
"No constraints selected for write.1103*constraintsZ18-5210h px� 
�
 The %s '%s' has been generated.
621*common2

checkpoint2default:default2o
[C:/intelFPGA/Final_Project/BOTTEL NECK/SHORTCUT/shortcut/shortcut.runs/synth_1/shortcut.dcp2default:defaultZ17-1381h px� 
�
%s4*runtcl2z
fExecuting : report_utilization -file shortcut_utilization_synth.rpt -pb shortcut_utilization_synth.pb
2default:defaulth px� 
�
Exiting %s at %s...
206*common2
Vivado2default:default2,
Tue Jul  1 12:17:59 20252default:defaultZ17-206h px� 


End Record