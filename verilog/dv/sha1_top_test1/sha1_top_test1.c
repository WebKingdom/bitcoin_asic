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

#define ADDR_STATUS 0x09
#define STATUS_READY_BIT 0
#define STATUS_VALID_BIT 1

#define ADDR_BLOCK0 0x10
#define ADDR_BLOCK15 0x1f

#define ADDR_DIGEST0 0x20
#define ADDR_DIGEST4 0x24

#define NUM_TRIALS_LIMIT 4


/*
	SHA1 test 1
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
    // number of trials for checking read back values
    uint32_t num_trials = 0;
    // temporary register value to be stored
    uint32_t reg_val = 0;

    // could put into array
    uint32_t hash_out0 = 0;
    uint32_t hash_out1 = 0;
    uint32_t hash_out2 = 0;
    uint32_t hash_out3 = 0;
    uint32_t hash_out4 = 0;

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

    // Flag start of the test
	reg_mprj_datal = 0xFEEDFEED;
    // reg_mprj_datah = 0x00000000;

    // set control information to SHA256: sha_init, auto_ctrl, and start_ctrl
    // *init bit starts sha_core, but only write to control register after reading in 512-bit input!
    reg_la3_data = 0x00010C00;
    
    // TODO could put in loop?
// aa55aa55
// deadbeef
// 55aa55aa
// f00ff00f
    reg_mprj_slave = 0x0FAB0FAB;
    // reg_mprj_slave = sha256_input[index];
    // index++;
    // sha_addr == ADDR_BLOCK0 && sha_we && sha_cs && sha_read_data == 0
    // * removed because can not read register value
    // reg_val = reg_la2_data;
    // while ((reg_val & 0x00000FFF) != 0x310)
    // {
    //     num_trials++;
    //     if (num_trials > NUM_TRIALS_LIMIT) {
    //         // did not read input
    //         testsPassed = testsPassed & 0;
    //         reg_mprj_datal = 0xBAD0BAD0;
    //         break;
    //     }
    //     reg_val = reg_la2_data;
    // }
    // num_trials = 0; // reset number of trials

    // set control information to SHA256: disable start_ctrl
    reg_la3_data = 0x00010800;

    reg_mprj_slave = 0x0000F00D;
    // reg_mprj_slave = sha256_input[index];
    // index++;
    // sha_addr == ADDR_BLOCK1 && sha_we && sha_cs && sha_read_data == 0
    // * removed because can not read register value
    // reg_val = reg_la2_data;
    // while ((reg_val & 0x00000FFF) != 0x311)
    // {
    //     num_trials++;
    //     if (num_trials > NUM_TRIALS_LIMIT) {
    //         // did not read input
    //         testsPassed = testsPassed & 0;
    //         reg_mprj_datal = 0xBAD0BAD0;
    //         break;
    //     }
    //     reg_val = reg_la2_data;
    // }
    // num_trials = 0; // reset number of trials

    reg_mprj_slave = 0x0001F00D;
    reg_mprj_slave = 0x0002F00D;
    reg_mprj_slave = 0x0003F00D;
    reg_mprj_slave = 0x0004F00D;
    reg_mprj_slave = 0x0005F00D;
    reg_mprj_slave = 0x0006F00D;
    reg_mprj_slave = 0x0007F00D;
    reg_mprj_slave = 0x0008F00D;
    reg_mprj_slave = 0x0009F00D;
    reg_mprj_slave = 0x000AF00D;
    reg_mprj_slave = 0x000BF00D;
    reg_mprj_slave = 0x000CF00D;
    reg_mprj_slave = 0x000DF00D;
    reg_mprj_slave = 0x000EF00D;

    // read valid output hash (digest)
    hash_out0 = reg_mprj_slave;
    // reg_val = reg_la2_data;
    // if ((reg_val & 0x00000FFF) == 0x120)
    // {
    //     testsPassed = testsPassed & 1;
    // }
    // else
    // {
    //     testsPassed = testsPassed & 0;
    //     reg_mprj_datal = 0xBAD0BAD0;
    // }

    hash_out1 = reg_mprj_slave;
    // reg_val = reg_la2_data;
    // if ((reg_val & 0x00000FFF) == 0x121)
    // {
    //     testsPassed = testsPassed & 1;
    // }
    // else
    // {
    //     testsPassed = testsPassed & 0;
    //     reg_mprj_datal = 0xBAD0BAD0;
    // }

    hash_out2 = reg_mprj_slave;
    // reg_val = reg_la2_data;
    // if ((reg_val & 0x00000FFF) == 0x122)
    // {
    //     testsPassed = testsPassed & 1;
    // }
    // else
    // {
    //     testsPassed = testsPassed & 0;
    //     reg_mprj_datal = 0xBAD0BAD0;
    // }

    hash_out3 = reg_mprj_slave;
    // reg_val = reg_la2_data;
    // if ((reg_val & 0x00000FFF) == 0x123)
    // {
    //     testsPassed = testsPassed & 1;
    // }
    // else
    // {
    //     testsPassed = testsPassed & 0;
    //     reg_mprj_datal = 0xBAD0BAD0;
    // }

    hash_out4 = reg_mprj_slave;
    // reg_val = reg_la2_data;
    // if ((reg_val & 0x00000FFF) == 0x124)
    // {
    //     testsPassed = testsPassed & 1;
    // }
    // else
    // {
    //     testsPassed = testsPassed & 0;
    //     reg_mprj_datal = 0xBAD0BAD0;
    // }

    if (hash_out0 == 0x11111111) {
        // TODO 
    }


    if (testsPassed)
    {
        // Successfully ended test
        reg_mprj_datal = 0xDEADDEAD;
    }
    else
    {
        reg_mprj_datal = 0xBAD0BAD0;
    }
}
