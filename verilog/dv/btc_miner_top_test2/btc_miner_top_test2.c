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

// global variables
uint32_t data_in0;
uint32_t data_in1;
uint32_t data_in2;
uint32_t data_in3;
uint32_t data_in4;
uint32_t data_in5;
uint32_t data_in6;
uint32_t data_in7;
uint32_t data_in8;
uint32_t data_in9;
uint32_t data_in10;
uint32_t data_in11;
uint32_t data_in12;
uint32_t data_in13;
uint32_t data_in14;
uint32_t data_in15;

uint32_t data_out0;
uint32_t data_out1;
uint32_t data_out2;
uint32_t data_out3;
uint32_t data_out4;
uint32_t data_out5;
uint32_t data_out6;
uint32_t data_out7;

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

int is_data_out_valid()
{
    return ((data_in0 + data_in1) == data_out0) && ((data_in2 + data_in3) == data_out1) &&
           ((data_in4 + data_in5) == data_out2) && ((data_in6 + data_in7) == data_out3) &&
           ((data_in8 + data_in9) == data_out4) && ((data_in10 + data_in11) == data_out5) &&
           ((data_in12 + data_in13) == data_out6) && ((data_in14 + data_in15) == data_out7);
}

void main()
{
    // boolean for validating all tests
    uint32_t testsPassed = 1;

    // set variables
    data_in0 = 0x0FAB0FAB;
    data_in1 = 0x000F00D1;
    data_in2 = 0x000F00D2;
    data_in3 = 0x000F00D3;
    data_in4 = 0x000F00D4;
    data_in5 = 0x000F00D5;
    data_in6 = 0x000F00D6;
    data_in7 = 0x000F00D7;
    data_in8 = 0x000F00D8;
    data_in9 = 0x000F00D9;
    data_in10 = 0x000F00DA;
    data_in11 = 0x000F00DB;
    data_in12 = 0x000F00DC;
    data_in13 = 0x000F00DD;
    data_in14 = 0x000F00DE;
    data_in15 = 0x000F00DF;

    data_out0 = 0;
    data_out1 = 0;
    data_out2 = 0;
    data_out3 = 0;
    data_out4 = 0;
    data_out5 = 0;
    data_out6 = 0;
    data_out7 = 0;

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

    // set control information to SHA256: sha_mode, sha_init, auto_ctrl, and start_ctrl
    // *init bit starts sha_core, but only write to control register after reading in 512-bit input!
    reg_la3_data = 0x00050C00;

    reg_mprj_slave = data_in0;

    // set control information to SHA256: disable start_ctrl
    reg_la3_data = 0x00050800;

    reg_mprj_slave = data_in1;
    reg_mprj_slave = data_in2;
    reg_mprj_slave = data_in3;
    reg_mprj_slave = data_in4;
    reg_mprj_slave = data_in5;
    reg_mprj_slave = data_in6;
    reg_mprj_slave = data_in7;
    reg_mprj_slave = data_in8;
    reg_mprj_slave = data_in9;
    reg_mprj_slave = data_in10;
    reg_mprj_slave = data_in11;
    reg_mprj_slave = data_in12;
    reg_mprj_slave = data_in13;
    reg_mprj_slave = data_in14;
    reg_mprj_slave = data_in15;

    // read valid output hash (digest)
    data_out0 = reg_mprj_slave;
    data_out1 = reg_mprj_slave;
    data_out2 = reg_mprj_slave;
    data_out3 = reg_mprj_slave;
    data_out4 = reg_mprj_slave;
    data_out5 = reg_mprj_slave;
    data_out6 = reg_mprj_slave;
    data_out7 = reg_mprj_slave;


    if (is_data_out_valid())
    {
        // Success
        testsPassed = testsPassed & 1;
    }
    else
    {
        testsPassed = testsPassed & 0;
    }


    // * 2nd round of additions
    // set global variables
    data_in0 = 0x000DABB1;
    data_in1 = 0x00FDABB2;
    data_in2 = 0x0A0DABB3;
    data_in3 = 0x000DABB4;
    data_in4 = 0x0E0DABB5;
    data_in5 = 0x000DABB6;
    data_in6 = 0x50EDABB7;
    data_in7 = 0x000DABB8;
    data_in8 = 0x700DABB9;
    data_in9 = 0x000DABBA;
    data_in10 = 0x600DABBB;
    data_in11 = 0x300DABBC;
    data_in12 = 0x000DABBD;
    data_in13 = 0x100DABBE;
    data_in14 = 0x000DABBF;
    data_in15 = 0x0FEDABC0;

    data_out0 = 0;
    data_out1 = 0;
    data_out2 = 0;
    data_out3 = 0;
    data_out4 = 0;
    data_out5 = 0;
    data_out6 = 0;
    data_out7 = 0;

    // set control information to SHA256: sha_mode, sha_init, auto_ctrl, and start_ctrl
    reg_la3_data = 0x00050C00;
    
    reg_mprj_slave = data_in0;

    // set control information to SHA256: disable start_ctrl
    reg_la3_data = 0x00050800;

    reg_mprj_slave = data_in1;
    reg_mprj_slave = data_in2;
    reg_mprj_slave = data_in3;
    reg_mprj_slave = data_in4;
    reg_mprj_slave = data_in5;
    reg_mprj_slave = data_in6;
    reg_mprj_slave = data_in7;
    reg_mprj_slave = data_in8;
    reg_mprj_slave = data_in9;
    reg_mprj_slave = data_in10;
    reg_mprj_slave = data_in11;
    reg_mprj_slave = data_in12;
    reg_mprj_slave = data_in13;
    reg_mprj_slave = data_in14;
    reg_mprj_slave = data_in15;

    // read valid output hash (digest)
    data_out0 = reg_mprj_slave;
    data_out1 = reg_mprj_slave;
    data_out2 = reg_mprj_slave;
    data_out3 = reg_mprj_slave;
    data_out4 = reg_mprj_slave;
    data_out5 = reg_mprj_slave;
    data_out6 = reg_mprj_slave;
    data_out7 = reg_mprj_slave;

    if (is_data_out_valid() && testsPassed)
    {
        // Successfully ended test
        testsPassed = testsPassed & 1;
        reg_mprj_datal = 0xDEADDEAD;
    }
    else
    {
        testsPassed = testsPassed & 0;
        reg_mprj_datal = 0xBAD0BAD0;
    }
}
