/*
 * SPDX-FileCopyrightText: 2020 Efabless Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * SPDX-License-Identifier: Apache-2.0
 */

// This include is relative to $CARAVEL_PATH (see Makefile)
#include <defs.h>
#include <stub.c>

/*
	Wishbone Test:
		- Configures MPRJ lower 8-IO pins as outputs
		- Checks counter value through the wishbone port
*/

void main()
{

    // boolean for validating all tests
    uint32_t testsPassed = 1;
    // previous result
    uint32_t prevResult = 0x0000000F;

	/* 
	IO Control Registers
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 3-bits | 1-bit | 1-bit | 1-bit  | 1-bit  | 1-bit | 1-bit   | 1-bit   | 1-bit | 1-bit | 1-bit   |
	Output: 0000_0110_0000_1110  (0x1808) = GPIO_MODE_USER_STD_OUTPUT
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 110    | 0     | 0     | 0      | 0      | 0     | 0       | 1       | 0     | 0     | 0       |
	
	 
	Input: 0000_0001_0000_1111 (0x0402) = GPIO_MODE_USER_STD_INPUT_NOPULL
	| DM     | VTRIP | SLOW  | AN_POL | AN_SEL | AN_EN | MOD_SEL | INP_DIS | HOLDH | OEB_N | MGMT_EN |
	| 001    | 0     | 0     | 0      | 0      | 0     | 0       | 0       | 0     | 1     | 0       |
	*/

	/* Set up the housekeeping SPI to be connected internally so	*/
	/* that external pin changes don't affect it.			*/

    reg_spi_enable = 1;
    reg_wb_enable = 1;
	// reg_spimaster_config = 0xa002;	// Enable, prescaler = 2,
                                        // connect to housekeeping SPI

	// Connect the housekeeping SPI to the SPI master
	// so that the CSB line is not left floating.  This allows
	// all of the GPIO pins to be used for user functions.

    reg_mprj_io_31 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_30 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_29 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_28 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_27 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_26 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_25 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_24 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_23 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_22 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_21 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_20 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_19 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_18 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_17 = GPIO_MODE_MGMT_STD_OUTPUT;
    reg_mprj_io_16 = GPIO_MODE_MGMT_STD_OUTPUT;

     /* Apply configuration */
    reg_mprj_xfer = 1;
    while (reg_mprj_xfer == 1);

    // LA probes [31:0] input to the CPU
    reg_la0_oenb = reg_la0_iena = 0x00000000;    // [31:0]
    // LA probes [63:32] output from the CPU
    reg_la1_oenb = reg_la1_iena = 0xFFFFFFFF;    // [63:32]
    // LA probes [94:64]  input to the CPU and [95:94] output from CPU (for nAdd_Sub and use_prev_result)
	reg_la2_oenb = reg_la2_iena = 0xC0000000;    // [95:64]

    // set prev_result for testing
    reg_la1_data = prevResult;
    // LA probes [63:32] input to the CPU (disable counter writes)
    // reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32]

    // set nAdd_sub to 1 -> subtract operation
    reg_la2_data = 0x80000000;

    // Flag start of the test
	reg_mprj_datal = 0xAB600000;
    // reg_mprj_datah = 0x00000000;

    // 5 - 3 = 2
    reg_mprj_slave = 0x00050003;
    if (reg_mprj_slave == 0x00000002)
    {
        prevResult = reg_mprj_slave;
        testsPassed = testsPassed & 1;
    }
    else
    {
        prevResult = 0xBAD0BAD0;
        testsPassed = testsPassed & 0;
    }

    // LA probes [63:32] output from the CPU
    // reg_la1_oenb = reg_la1_iena = 0xFFFFFFFF;    // [63:32]
    // set prev_result
    reg_la1_data = prevResult;
    // LA probes [63:32] input to the CPU (disable counter writes)
    // reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32]

    // set nAdd_sub to 0 -> add operation
    reg_la2_data = 0x00000000;
    // 7 + 15 = 22 = 0x16
    reg_mprj_slave = 0x0007000F;
    if (reg_mprj_slave == 0x00000016)
    {
        prevResult = reg_mprj_slave;
        testsPassed = testsPassed & 1;
    }
    else
    {
        prevResult = 0xBAD0BAD0;
        testsPassed = testsPassed & 0;
    }

    // LA probes [63:32] output from the CPU
    // reg_la1_oenb = reg_la1_iena = 0xFFFFFFFF;    // [63:32]
    // set prev_result
    reg_la1_data = prevResult;
    // LA probes [63:32] input to the CPU (disable counter writes)
    // reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32]

    // set nAdd_sub to 1 -> subtract operation
    reg_la2_data = 0x80000000;
    // 0x7654 - 0x1234 = 0x6420
    reg_mprj_slave = 0x76541234;
    if (reg_mprj_slave == 0x00006420)
    {
        prevResult = reg_mprj_slave;
        testsPassed = testsPassed & 1;
    }
    else
    {
        prevResult = 0xBAD0BAD0;
        testsPassed = testsPassed & 0;
    }

    // set prev_result
    reg_la1_data = prevResult;

    if (testsPassed)
    {
        reg_mprj_datal = 0xAB610000;
    }
}
