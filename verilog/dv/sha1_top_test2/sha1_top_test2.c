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
    SHA1 test 2
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
    reg_la0_oenb = reg_la0_iena = 0x00000000; // [31:0]
    // LA probes [63:32] input to MGMT from USER
    reg_la1_oenb = reg_la1_iena = 0x00000000; // [63:32]
                                              // LA probes [95:64]  input to MGMT from USER
    reg_la2_oenb = reg_la2_iena = 0x00000000; // [95:64]
                                              // LA probes [127:96] output from MGMT into USER
    reg_la3_oenb = reg_la3_iena = 0xFFFF3FFF; // [127:96]

    // Flag start of the test
    reg_mprj_datal = 0xFEEDFEED;
    // reg_mprj_datah = 0x00000000;


    // * data I/O from MSB to LSB
    // * TC1 (from SHA1 repo)
    // TC1: Single block message: "abc".
    // tc1 = 512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
    // res1 = 160'h a9993e36 4706816a ba3e2571 7850c26c 9cd0d89d;

    // set control information to SHA256: sha_next: 0, sha_init: 1, auto_ctrl: 1, and start_ctrl: 1
    // *init bit starts sha_core, but only write to control register after reading in 512-bit input!
    reg_la3_data = 0x00010C00;
    reg_mprj_slave = 0x61626380;
    reg_la3_data = 0x00010800;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;

    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;

    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;

    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000018;

    // read valid output hash (digest)
    hash_out4 = reg_mprj_slave;
    hash_out3 = reg_mprj_slave;
    hash_out2 = reg_mprj_slave;
    hash_out1 = reg_mprj_slave;
    hash_out0 = reg_mprj_slave;

    if (!((hash_out4 == 0xa9993e36) && (hash_out3 == 0x4706816a) && (hash_out2 == 0xba3e2571) &&
        (hash_out1 == 0x7850c26c) && (hash_out0 == 0x9cd0d89d)))
    {
        reg_mprj_datal = 0xBAD0BAD0;    // failed test
    }


    // * TC2_1 (from SHA1 repo)
    // TC2: Double block message.
    // "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
    // tc2_1 = 512'h 61626364 62636465 63646566 64656667 65666768 66676869 6768696A 68696A6B 696A6B6C 6A6B6C6D 6B6C6D6E 6C6D6E6F 6D6E6F70 6E6F7071 80000000 00000000;
    // res2_1 = 160'h f4286818 c37b27ae 0408f581 84677148 4a566572;
    reg_la3_data = 0x00010C00;
    reg_mprj_slave = 0x61626364;
    reg_la3_data = 0x00010800;
    reg_mprj_slave = 0x62636465;
    reg_mprj_slave = 0x63646566;
    reg_mprj_slave = 0x64656667;

    reg_mprj_slave = 0x65666768;
    reg_mprj_slave = 0x66676869;
    reg_mprj_slave = 0x6768696A;
    reg_mprj_slave = 0x68696A6B;

    reg_mprj_slave = 0x696A6B6C;
    reg_mprj_slave = 0x6A6B6C6D;
    reg_mprj_slave = 0x6B6C6D6E;
    reg_mprj_slave = 0x6C6D6E6F;

    reg_mprj_slave = 0x6D6E6F70;
    reg_mprj_slave = 0x6E6F7071;
    reg_mprj_slave = 0x80000000;
    reg_mprj_slave = 0x00000000;

    // read valid output hash (digest)
    hash_out4 = reg_mprj_slave;
    hash_out3 = reg_mprj_slave;
    hash_out2 = reg_mprj_slave;
    hash_out1 = reg_mprj_slave;
    hash_out0 = reg_mprj_slave;

    if (!((hash_out4 == 0xf4286818) && (hash_out3 == 0xc37b27ae) && (hash_out2 == 0x0408f581) &&
        (hash_out1 == 0x84677148) && (hash_out0 == 0x4a566572)))
    {
        reg_mprj_datal = 0xBAD0BAD0;    // failed test
    }


    // * TC2_2 (from SHA1 repo)
    // tc2_2 = 512'h000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001C0;
    // res2_2 = 160'h 84983e44 1c3bd26e baae4aa1 f95129e5 e54670f1;
    reg_la3_data = 0x00020C00;      // * Double block message must set sha_next bit and disable sha_init
    reg_mprj_slave = 0x00000000;
    reg_la3_data = 0x00020800;      // * Double block message must set sha_next bit and disable sha_init
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;

    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;

    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;

    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x00000000;
    reg_mprj_slave = 0x000001c0;

    // read valid output hash (digest)
    hash_out4 = reg_mprj_slave;
    hash_out3 = reg_mprj_slave;
    hash_out2 = reg_mprj_slave;
    hash_out1 = reg_mprj_slave;
    hash_out0 = reg_mprj_slave;

    if (!((hash_out4 == 0x84983e44) && (hash_out3 == 0x1c3bd26e) && (hash_out2 == 0xbaae4aa1) &&
        (hash_out1 == 0xf95129e5) && (hash_out0 == 0xe54670f1)))
    {
        reg_mprj_datal = 0xBAD0BAD0;    // failed test
    }
    else
    {
        // Successfully ended test
        reg_mprj_datal = 0xDEADDEAD;
    }




    // TODO more tests
    // *Custom test
    // aa55aa55
    // deadbeef
    // 55aa55aa
    // f00ff00f
    // reg_mprj_slave = 0xaa55aa55;
    // reg_la3_data = 0x00010800;
    // reg_mprj_slave = 0xdeadbeef;
    // reg_mprj_slave = 0x55aa55aa;
    // reg_mprj_slave = 0xf00ff00f;

    // reg_mprj_slave = 0xaa55aa55;
    // reg_mprj_slave = 0xdeadbeef;
    // reg_mprj_slave = 0x55aa55aa;
    // reg_mprj_slave = 0xf00ff00f;

    // reg_mprj_slave = 0xaa55aa55;
    // reg_mprj_slave = 0xdeadbeef;
    // reg_mprj_slave = 0x55aa55aa;
    // reg_mprj_slave = 0xf00ff00f;

    // reg_mprj_slave = 0xaa55aa55;
    // reg_mprj_slave = 0xdeadbeef;
    // reg_mprj_slave = 0x55aa55aa;
    // reg_mprj_slave = 0xf00ff00f;

}
