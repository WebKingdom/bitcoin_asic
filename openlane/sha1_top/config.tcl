# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set ::env(PDK) $::env(PDK)
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) sha1_top

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/sha1_top.v \
	$script_dir/../../verilog/rtl/sha1.v \
	$script_dir/../../verilog/rtl/sha1_core.v \
	$script_dir/../../verilog/rtl/sha1_w_mem.v"

set ::env(DESIGN_IS_CORE) 0

set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) "sha1_ctrl.clk"
set ::env(CLOCK_PERIOD) "10"

# always got: "There are hold violations in the design at the typical corner" when FP_SIZING was absolute... 
# no matter what PL or GLB parameters I set. tried increasing both HOLD_MAX_BUFFER_PERCENT and HOLD_SLACK_MARGIN to 80% and 0.3ns
set ::env(FP_SIZING) relative
# max area in wrapper: 0 0 2920 3520
# set ::env(DIE_AREA) "0 0 6000 8000"

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY) 0.4
set ::env(FP_CORE_UTIL) 30
set ::env(CELL_PAD) 2
# with 10%: detailed placement faild and had setup violations
# with 50%: detailed placement faild and had setup violations
# with 100% and 0.7: "Utilization exceeds 100%." Ran out of space?
# with 90% and 0.7: "Use a higher -density or re-floorplan with a larger core area. Suggested target density: 0.92" 
# with 95% and 0.9: "Use a higher -density or re-floorplan with a larger core area. Suggested target density: 0.98"

# DIE_AREA: "0 0 2920 3520" and FP_SIZING: relative
# with 98% and 0.98: "Utilization exceeds 100%." (Chip area: 158121.651200) (PlaceInstsArea: 158121651200) (NonPlaceInstsArea: 3992579200) (CoreArea: 160567747200)
# with 95% and 1: "Detailed placement failed." "Error: resizer.tcl, 78 DPL-0036" 
# with 95% and 0.98: "Use a higher -density or re-floorplan with a larger core area." (PlaceInstsArea: 158121651200) (NonPlaceInstsArea: 4046380800) (Util(%): 98.13) (CoreArea: 165175916800)

# DIE_AREA: "0 0 2920 3520" and FP_SIZING: absolute
# with 95% and 0.98: "Detailed placement failed." "Error: resizer.tcl, 78 DPL-0036"


# * Simplified design:
# DIE_AREA: "0 0 2920 3520" (absolute)
# with 80% and 0.7: Routing congestion too high.

# DIE_AREA: "0 0 1400 1000" (absolute)
# with 40% and 0.55: Routing congestion too high.

# DIE_AREA: "0 0 1000 800" (absolute)
# with 8% and 0.55: Routing congestion too high.

# DIE_AREA: "0 0 900 600" (absolute)
# with 5% and 0.15: There are hold violations in the design at the typical corner. Antenna pins violated: 120, nets violated: 118

# DIE_AREA: "0 0 900 600" (absolute)
# with 5% and 0.2: There are hold violations in the design at the typical corner. Antenna pins violated: 109, nets violated: 109

# DIE_AREA: "0 0 900 600" (absolute)
# with 10% and 0.3: There are hold violations in the design at the typical corner. Antenna pins violated: 86, nets violated: 86 (about -2ns violated)

# DIE_AREA: "0 0 900 600" (absolute)
# with 20% and 0.4: There are hold violations in the design at the typical corner. Antenna pins violated: 73, nets violated: 72 (about -2.9ns violated)


# DIE_AREA: "0 0 900 600" (absolute)
# with 5% and 0.1: "Use a higher -density or re-floorplan with a larger core area."

# DIE_AREA: "0 0 600 400" (absolute)
# with 10% and 0.4: Detailed placement failed

# DIE_AREA: "0 0 600 400" (absolute)
# with 20% and 0.55: Detailed placement failed

# DIE_AREA: "0 0 900 600" (relative and commented out all other settings)
# with 10% and 0.4: "There are max slew violations in the design at the typical corner." "There are hold violations in the design at the typical corner."

# DIE_AREA: "0 0 900 600" (relative and other settings included)
# with 8% and 0.3: There are hold violations in the design at the typical corner. Antenna pins violated: 12, nets violated: 12 (about -1.65ns violated)



# * SHA1 design:
# DIE_AREA: "0 0 2920 3520" (relative and other settings included)
# with 94% and 0.9: Does not fit but dimensions of chip are small and not take up full max area

# DIE_AREA: "0 0 2920 3520" (absolute and other settings included)
# with 94% and 0.9: [ERROR STA-0414] -setup_margin '0.2ns' is not a positive float. Error: resizer_timing.tcl, 52 STA-0414
# [ERROR]: Last 10 lines:
# set_timing_derate -early 0.9500
# set_timing_derate -late 1.0500

# DIE_AREA: "0 0 2900 3500" (absolute and other settings included)
# with 60% and 0.6:
# [STEP 15]
# [INFO]: Running Global Routing Resizer Timing Optimizations...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/resizer_routing_timing.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_27_00_25/logs/routing/15-resizer.log
# [ERROR]: Last 10 lines:
# [INFO GRT-0101] Running extra iterations to remove overflow.
# [WARNING GRT-0227] Reached 20 congestion iterations with less than 15% of reduction between iterations.
# [INFO GRT-0197] Via related to pin nodes: 73931
# [INFO GRT-0198] Via related Steiner nodes: 4327
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 122644
# [INFO GRT-0112] Final usage 3D: 685557
# [ERROR GRT-0118] Routing congestion too high.
# Error: resizer_routing_timing.tcl, 53 GRT-0118

# DIE_AREA: "0 0 2900 3500" (absolute and other settings included)
# with 40% and default PL_TARGET_DENSITY:
# [STEP 15]
# [INFO]: Running Global Routing Resizer Timing Optimizations...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/resizer_routing_timing.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_27_00_43/logs/routing/15-resizer.log
# [ERROR]: Last 10 lines:
# [INFO GRT-0101] Running extra iterations to remove overflow.
# [WARNING GRT-0227] Reached 20 congestion iterations with less than 15% of reduction between iterations.
# [INFO GRT-0197] Via related to pin nodes: 72754
# [INFO GRT-0198] Via related Steiner nodes: 3490
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 113486
# [INFO GRT-0112] Final usage 3D: 610405
# [ERROR GRT-0118] Routing congestion too high.
# Error: resizer_routing_timing.tcl, 53 GRT-0118


# DIE_AREA: "0 0 2700 3300" (absolute and other settings included)
# with 10% and default PL_TARGET_DENSITY:
# [STEP 15]
# [INFO]: Running Global Routing Resizer Timing Optimizations...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/resizer_routing_timing.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_27_01_02/logs/routing/15-resizer.log
# [ERROR]: Last 10 lines:
# [INFO GRT-0101] Running extra iterations to remove overflow.
# [WARNING GRT-0227] Reached 20 congestion iterations with less than 15% of reduction between iterations.
# [INFO GRT-0197] Via related to pin nodes: 73302
# [INFO GRT-0198] Via related Steiner nodes: 3153
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 112526
# [INFO GRT-0112] Final usage 3D: 602109
# [ERROR GRT-0118] Routing congestion too high.
# Error: resizer_routing_timing.tcl, 53 GRT-0118



# DIE_AREA: "0 0 1000 1500" (absolute and other settings included)
# with 8% and default PL_TARGET_DENSITY:
# [STEP 21]
# [INFO]: Running Global Routing...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/groute.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_27_01_15/logs/routing/21-global.log
# [ERROR]: Last 10 lines:
# [INFO GRT-0101] Running extra iterations to remove overflow.
# [INFO GRT-0103] Extra Run for hard benchmark.
# [INFO GRT-0197] Via related to pin nodes: 91123
# [INFO GRT-0198] Via related Steiner nodes: 7024
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 148074
# [INFO GRT-0112] Final usage 3D: 715064
# [ERROR GRT-0118] Routing congestion too high.
# Error: groute.tcl, 55 GRT-0118


# DIE_AREA: "0 0 800 1000" (absolute and other settings included)
# with 5% and default PL_TARGET_DENSITY:
# [STEP 15]
# [INFO]: Running Global Routing Resizer Timing Optimizations...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/resizer_routing_timing.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_27_01_32/logs/routing/15-resizer.log
# [ERROR]: Last 10 lines:
# [INFO GRT-0101] Running extra iterations to remove overflow.
# [INFO GRT-0103] Extra Run for hard benchmark.
# [INFO GRT-0197] Via related to pin nodes: 70951
# [INFO GRT-0198] Via related Steiner nodes: 2639
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 106400
# [INFO GRT-0112] Final usage 3D: 491648
# [ERROR GRT-0118] Routing congestion too high.
# Error: resizer_routing_timing.tcl, 53 GRT-0118


# DIE_AREA: "0 0 800 1000" (absolute and other settings included)
# with 2% and default PL_TARGET_DENSITY:
# [STEP 15]
# [INFO]: Running Global Routing Resizer Timing Optimizations...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/resizer_routing_timing.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_27_13_08/logs/routing/15-resizer.log
# [ERROR]: Last 10 lines:
# [INFO GRT-0101] Running extra iterations to remove overflow.
# [INFO GRT-0103] Extra Run for hard benchmark.
# [INFO GRT-0197] Via related to pin nodes: 70951
# [INFO GRT-0198] Via related Steiner nodes: 2639
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 106400
# [INFO GRT-0112] Final usage 3D: 491648
# [ERROR GRT-0118] Routing congestion too high.
# Error: resizer_routing_timing.tcl, 53 GRT-0118


# DIE_AREA: "0 0 2800 3400" (absolute and other settings included)
# with 2% and default PL_TARGET_DENSITY:
# [STEP 15]
# [INFO]: Running Global Routing Resizer Timing Optimizations...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/resizer_routing_timing.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_27_13_51/logs/routing/15-resizer.log
# [ERROR]: Last 10 lines:
# [INFO GRT-0101] Running extra iterations to remove overflow.
# [WARNING GRT-0227] Reached 20 congestion iterations with less than 15% of reduction between iterations.
# [INFO GRT-0197] Via related to pin nodes: 72763
# [INFO GRT-0198] Via related Steiner nodes: 3306
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 111562
# [INFO GRT-0112] Final usage 3D: 591028
# [ERROR GRT-0118] Routing congestion too high.
# Error: resizer_routing_timing.tcl, 53 GRT-0118


# DIE_AREA: "0 0 600 900" (absolute and other settings included)
# with 1% and default PL_TARGET_DENSITY:
# [STEP 15]
# [INFO]: Running Global Routing Resizer Timing Optimizations...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/resizer_routing_timing.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_27_14_13/logs/routing/15-resizer.log
# [ERROR]: Last 10 lines:
# [INFO GRT-0101] Running extra iterations to remove overflow.
# [INFO GRT-0197] Via related to pin nodes: 70245
# [INFO GRT-0198] Via related Steiner nodes: 1910
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 94700
# [INFO GRT-0112] Final usage 3D: 449660
# [ERROR GRT-0118] Routing congestion too high.
# Error: resizer_routing_timing.tcl, 53 GRT-0118


# DIE_AREA: "0 0 2900 3500" (absolute and commented out everything except PL_RANDOM_GLB_PLACEMENT == 0 and all buffer % = 80)
# with 90% and default PL_TARGET_DENSITY:
# [STEP 21]
# [INFO]: Running Global Routing...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/groute.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_27_14_26/logs/routing/21-global.log
# [ERROR]: Last 10 lines:
# [INFO GRT-0101] Running extra iterations to remove overflow.
# [INFO GRT-0103] Extra Run for hard benchmark.
# [INFO GRT-0197] Via related to pin nodes: 83886
# [INFO GRT-0198] Via related Steiner nodes: 8027
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 163913
# [INFO GRT-0112] Final usage 3D: 936594
# [ERROR GRT-0118] Routing congestion too high.
# Error: groute.tcl, 55 GRT-0118


# DIE_AREA: "0 0 2920 3520" (absolute and commented out everything except PL_RANDOM_GLB_PLACEMENT == 0 and all buffer % = 80)
# with 94% and default PL_TARGET_DENSITY:
# [STEP 21]
# [INFO]: Running Global Routing...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/groute.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_27_15_07/logs/routing/21-global.log
# [ERROR]: Last 10 lines:
# [INFO GRT-0101] Running extra iterations to remove overflow.
# [INFO GRT-0103] Extra Run for hard benchmark.
# [INFO GRT-0197] Via related to pin nodes: 83898
# [INFO GRT-0198] Via related Steiner nodes: 8049
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 165868
# [INFO GRT-0112] Final usage 3D: 949355
# [ERROR GRT-0118] Routing congestion too high.
# Error: groute.tcl, 55 GRT-0118


# DIE_AREA: "0 0 6000 8000" (absolute and commented out everything except PL_RANDOM_GLB_PLACEMENT == 0 and all buffer % = 80)
# with 90% and default PL_TARGET_DENSITY:
# [STEP 15]
# [INFO]: Running Global Routing Resizer Timing Optimizations...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/resizer_routing_timing.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_29_11_16/logs/routing/15-resizer.log
# [ERROR]: Last 10 lines:

# [INFO GRT-0101] Running extra iterations to remove overflow.
# [INFO GRT-0197] Via related to pin nodes: 66525
# [INFO GRT-0198] Via related Steiner nodes: 1333
# [INFO GRT-0199] Via filling finished.
# [INFO GRT-0111] Final number of vias: 86746
# [INFO GRT-0112] Final usage 3D: 466964
# [ERROR GRT-0118] Routing congestion too high.
# Error: resizer_routing_timing.tcl, 53 GRT-0118


# Commented out: DIE_AREA: "0 0 6000 8000" (FP_SIZING = relative and commented out everything except PL_RANDOM_GLB_PLACEMENT == 0 and all buffer % = 80)
# with 30% and default PL_TARGET_DENSITY:
# [STEP 18]
# [INFO]: Running Detailed Placement...
# [ERROR]: during executing openroad script /openlane/scripts/openroad/opendp.tcl
# [ERROR]: Exit code: 1
# [ERROR]: full log: ../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_08_29_13_53/logs/routing/18-diode_legalization.log
# [ERROR]: Last 10 lines:
# [INFO DPL-0035]  ANTENNA__14155__A1
# [INFO DPL-0035]  ANTENNA__14155__A1
# [INFO DPL-0035]  ANTENNA__20474__A2
# [INFO DPL-0035]  ANTENNA__20930__A
# [INFO DPL-0035]  ANTENNA__20930__A
# [INFO DPL-0035]  ANTENNA__16103__A0
# [INFO DPL-0035] message limit reached, this message will no longer print
# [ERROR DPL-0036] Detailed placement failed.
# Error: opendp.tcl, 32 DPL-0036


# Commented out: DIE_AREA: "0 0 6000 8000" and commented out everything except PL_RANDOM_GLB_PLACEMENT == 0 and all buffer % = 80
# set ::env(FP_SIZING) relative
# set ::env(PL_TARGET_DENSITY) 0.4
# set ::env(FP_CORE_UTIL) 30
# set ::env(CELL_PAD) 2
# [STEP 39]
# [INFO]: Running Magic DRC...
# [INFO]: Converting Magic DRC Violations to Magic Readable Format...
# [INFO]: Converting Magic DRC Violations to Klayout XML Database...
# [ERROR]: There are violations in the design after Magic DRC.
# [ERROR]: Total Number of violations is 5
# [INFO]: Saving current set of views in '../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_09_01_01_54/results/final'...
# [INFO]: Generating final set of reports...
# [INFO]: Created manufacturability report at '../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_09_01_01_54/reports/manufacturability.rpt'.
# [INFO]: Created metrics report at '../Users/somasz/Documents/GitHub/mpw_6c/caravel_design/caravel_bitcoin_asic/openlane/sha1_top/runs/22_09_01_01_54/reports/metrics.csv'.
# [INFO]: Saving runtime environment...
# [ERROR]: Flow failed.



# TODO 


# Not sure how FP_SIZING absolute and relative works excatly and how DIE_AREA affects the overall size and constraints

# set ::env(ROUTING_CORES) 4
set ::env(PL_RANDOM_GLB_PLACEMENT) 0
# set ::env(PL_RESIZER_ALLOW_SETUP_VIOS) 0
# set ::env(GLB_RESIZER_ALLOW_SETUP_VIOS) 0

set ::env(PL_RESIZER_HOLD_MAX_BUFFER_PERCENT) 80
set ::env(GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT) 80
# set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.4
# set ::env(GLB_RESIZER_HOLD_SLACK_MARGIN) 0.2

set ::nev(PL_RESIZER_SETUP_MAX_BUFFER_PERCENT) 80
set ::nev(GLB_RESIZER_SETUP_MAX_BUFFER_PERCENT) 80
# set ::env(PL_RESIZER_SETUP_SLACK_MARGIN) 0.2
# set ::env(GLB_RESIZER_SETUP_SLACK_MARGIN) 0.1

# set ::anv(CTS_TARGET_SKEW) 200

# Maximum layer used for routing is metal 4.
# This is because this macro will be inserted in a top level (user_project_wrapper) 
# where the PDN is planned on metal 5. So, to avoid having shorts between routes
# in this macro and the top level metal 5 stripes, we have to restrict routes to metal4.  
# 
# set ::env(GLB_RT_MAXLAYER) 5

set ::env(RT_MAX_LAYER) {met4}

# You can draw more power domains if you need to 
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(DIODE_INSERTION_STRATEGY) 4 
# If you're going to use multiple power domains, then disable cvc run.
set ::env(RUN_CVC) 1
