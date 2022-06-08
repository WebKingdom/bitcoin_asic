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

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) btc_miner_top

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/btc_miner_top.v \
	$script_dir/../../verilog/rtl/sha256.v"

set ::env(DESIGN_IS_CORE) 0

set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_NET) "miner_ctrl.clk"
set ::env(CLOCK_PERIOD) "10"

# always got: "There are hold violations in the design at the typical corner" when FP_SIZING was absolute... 
# no matter what PL or GLB parameters I set. tried increasing both HOLD_MAX_BUFFER_PERCENT and HOLD_SLACK_MARGIN to 80% and 0.3ns
set ::env(FP_SIZING) absolute
# max area in wrapper: 0 0 2920 3520
set ::env(DIE_AREA) "0 0 900 600"

set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg

set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY) 0.4
set ::env(FP_CORE_UTIL) 20
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
# with 20% and 0.4: 


# Not sure how FP_SIZING absolute and relative works excatly and how DIE_AREA affects the overall size and constraints

# set ::env(ROUTING_CORES) 4
set ::env(PL_RANDOM_GLB_PLACEMENT) 0
set ::env(PL_RESIZER_ALLOW_SETUP_VIOS) 1
set ::env(GLB_RESIZER_ALLOW_SETUP_VIOS) 1

set ::env(PL_RESIZER_HOLD_MAX_BUFFER_PERCENT) 90
set ::env(GLB_RESIZER_HOLD_MAX_BUFFER_PERCENT) 90
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.2ns
set ::env(GLB_RESIZER_HOLD_SLACK_MARGIN) 0.2ns

set ::nev(PL_RESIZER_SETUP_MAX_BUFFER_PERCENT) 90
set ::nev(GLB_RESIZER_SETUP_MAX_BUFFER_PERCENT) 90
set ::env(PL_RESIZER_SETUP_SLACK_MARGIN) 0.1ns
set ::env(GLB_RESIZER_SETUP_SLACK_MARGIN) 0.1ns

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
