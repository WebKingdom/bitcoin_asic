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

// constants
#define ADDR_CTRL 0x08
#define CTRL_INIT_BIT 0
#define CTRL_NEXT_BIT 1
#define CTRL_MODE_BIT 2

#define ADDR_STATUS 0x09
#define STATUS_READY_BIT 0
#define STATUS_VALID_BIT 1

#define ADDR_BLOCK0 0x10
#define ADDR_BLOCK15 0x1f

#define ADDR_DIGEST0 0x20
#define ADDR_DIGEST6 0x26
#define ADDR_DIGEST7 0x27

#define MODE_SHA_224 0
#define MODE_SHA_256 1


/*
	Miner test 1
    - checks if automated state machine works as expected
*/

// void *memcpy(void *dest, const void *src, uint32_t n)
// {
//     for (uint32_t i = 0; i < n; i++)
//     {
//         ((char*)dest)[i] = ((char*)src)[i];
//     }
// }


// void *memcpy (void *dest, const void *src, uint32_t len)
// {
//   char *d = dest;
//   const char *s = src;
//   while (len--)
//     *d++ = *s++;
//   return dest;
// }


void main()
{
    // boolean for validating all tests
    uint32_t testsPassed = 1;

    // SHA info
    // uint32_t index = 0;
    // const uint32_t sha256_input[] = {
    //     0x00000001, 0x00000002, 0x00000003, 0x00000004,
    //     0x00000005, 0x00000006, 0x00000007, 0x00000008,
    //     0x00000009, 0x0000000A, 0x0000000B, 0x0000000C,
    //     0x0000000D, 0x0000000E, 0x0000000F, 0x00000010
    // };


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

    // LA probes [31:0] input to MGMT from USER
    reg_la0_oenb = reg_la0_iena = 0x00000000;    // [31:0]
    // LA probes [63:32] input to MGMT from USER
    reg_la1_oenb = reg_la1_iena = 0x00000000;    // [63:32]
    // LA probes [95:64]  input to MGMT from USER
	reg_la2_oenb = reg_la2_iena = 0x00000000;    // [95:64]
    // LA probes [127:96] output from MGMT into USER
	reg_la3_oenb = reg_la3_iena = 0xFFFF3FFF;    // [127:96]

    // set control information to SHA256, init, and auto_ctrl
    reg_la3_data = 0x00050800;

    // Flag start of the test
	reg_mprj_datal = 0xFEED0000;
    // reg_mprj_datah = 0x00000000;

    // set control information to SHA256: sha_mode, sha_init, auto_ctrl, and start_ctrl
    // TODO? init bit starts sha_core!?
    reg_la3_data = 0x00050C00;

    // TODO could put in loop?
    // Write input to sha module
    reg_mprj_slave = 0x0FAB0FAB;
    // reg_mprj_slave = sha256_input[index];
    // index++;
    // sha_addr == ADDR_CTRL && sha_we && sha_cs && sha_read_data == 0
    if (((reg_la2_data & 0xFF) == ADDR_CTRL) && ((reg_la2_data & 0xF00) == 0x3) && (reg_la1_data == 0x0))
    {
        // read 1st input
        testsPassed = testsPassed & 1;
    }
    else
    {
        // did not read input
        testsPassed = testsPassed & 0;
    }

    // set control information to SHA256: disable start_ctrl
    reg_la3_data = 0x00050800;

    // Write input to sha module
    reg_mprj_slave = 0x0000F00D;
    // reg_mprj_slave = sha256_input[index];
    // index++;
    // sha_addr == ADDR_CTRL && sha_we && sha_cs && sha_read_data == 0
    if (((reg_la2_data & 0xFF) == ADDR_BLOCK0) && ((reg_la2_data & 0xF00) == 0x3) && (reg_la1_data == 0x0))
    {
        // read 2nd input
        testsPassed = testsPassed & 1;
    }
    else
    {
        // did not read input
        testsPassed = testsPassed & 0;
    }


    if (testsPassed)
    {
        // Successfully ended test
        reg_mprj_datal = 0xDEAD0000;
    }
    else
    {
        reg_mprj_datal = 0xBAD0BAD0;
    }
}
