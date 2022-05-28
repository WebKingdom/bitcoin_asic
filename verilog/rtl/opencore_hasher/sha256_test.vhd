-----------------------------------------------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com, jonnydoin@gridvortex.com
-- 
-- Create Date:     09:56:30 05/22/2016  
-- Module Name:     sha256_test.vhd
-- Project Name:    sha256 engine
-- Target Devices:  Spartan-6
-- Tool versions:   ISE 14.7
-- Description: 
--
--      Testbench for the GV_SHA256 engine.
--      This is the testbench for the GV_SHA256 engine. It exercises all the input control signals and error generation,
--      and tests the GV_SHA256 engine with the NIST SHA256 test vectors, including the additional NIST test vectors up to the 
--      1 million chars.
--
--      The logic implements a fast engine, with 65 cycles per 512-bit block. 
--
--      The following waveforms describe the operation of the engine control signals for message start, update and end.
--
--      BEGIN BLOCK (1st block)
--      ======================
--
--      The hash operation starts with a 'begin' sync pulse, which causes the RESET of the processor. The processor comes out of RESET only after 'begin' is
--      released. 
--      The DATA_INPUT state is signalled by the data request signal 'di_req' going HIGH. The processor will latch 16 words from the 'di' port, at every 
--      rising edge of the system clock. At the end of the block input, the 'di_req' signal goes LOW. 
--      The input data can be held by bringing the 'wr_i' input LOW. When the 'wr_i' input is held LOW during data write, it inserts a wait state in the 
--      processor, to cope with slow inputs or to allow periodic fetches of input data from multiple data sources. 
--      The 'di_req' signal will remain HIGH while data input is requested. When all 16 words are clocked in, 'di_req' goes LOW, and 'wr_i' is not allowed
--      during the internal processing phase.
--
--      state              |reset| data                                    |wait |                                                     | process                  
--                    __   |__   |__    __    __    __    __    __    __   |__   |__    __    __    __    __    __    __    __    __   |__    __    __ 
--      clk_i      __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \...     -- system clock
--                        _____                                                                                                                                      
--      start_i    ______/   \_\_______________________________________________________________________________________________________________________...     -- 'start_i' resets the processor and starts a new hash
--                                                                                                                                                       
--      end_i      ____________________________________________________________________________________________________________________________________...     -- 'end_i' marks end of last block data input
--                 __ _ _ _       _____________________________________________________________________________________________________                  
--      di_req_o   __ _ _ _\_____/                                                                                                     \_______________...     -- 'di_req_o' asserted during data input
--                            ___________________________________________       _________________________________________________________                
--      wr_i       __________/____/                                      \_____/                                                         \_____________...     -- 'wr_i' can hold the core for slow data
--                 __________ _________ _____ _____ _____ _____ _____ ___________ _____ _____ _____ _____ _____ _____ _____ _____ ______ ______________...
--      di_i       __________\___\_W0__\__W1_\__W2_\__W3_\__W4_\__W5_\\\\\\\__W6_\__W7_\__W8_\__W9_\_W10_\_W11_\_W12_\_W13_\_W14_\_W15__\______X_______...     -- user words on 'di_i' are latched on 'clk_i' rising edge
--                 ____________________ _____ _____ _____ _____ _____ ___________ _____ _____ _____ _____ _____ _____ _____ _____ _____________________...
--      st_cnt_reg ________/__0__/__0__/__1__/__2__/__3__/__4__/__5__/___6_______/__7__/__8__/__9__/__10_/__11_/__12_/__13_/__14_/__15_/__16_/__17_/_18...     -- internal state counter value
--                 __________ ___ _____ _____ _____ _____ _____ _____ ___________ _____ _____ _____ _____ _____ _____ _____ _____ _____________________...
--      Wt_i@core  __________\___\__W0_\__W1_\__W2_\__W3_\__W4_\__W5_\\\\\\\__W6_\__W7_\__W8_\__W9_\_W10_\_W11_\_W12_\_W13_\_W14_\_W15_________________...     -- msg scheduler lookahead output for Wt_i at core
--                 ______________ _____ _____ _____ _____ _____ _____ ___________ _____ _____ _____ _____ _____ _____ _____ _____ _____________________...
--      Kt_i@core  ______________/__K0_/__K1_/__K2_/__K3_/__K4_/__K5_/__K6_______/__K7_/__K8_/__K9_/_K10_/_K11_/_K12_/_K13_/_K14_/_K15_________________...     -- Kt rom synchronous with scheduler for Kt_i at core
--                 __ _ _ _                                                                                                                                            
--      error_o    __ _ _ _\___________________________________________________________________________________________________________________________...     -- 'start_i' clears any error condition
--                 __ _ _ _                                                                                                                                            
--      do_valid_o __ _ _ _\___________________________________________________________________________________________________________________________...     -- 'start_i' invalidates any previous results
--
--
--      UPDATE BLOCK (preload)
--      =====================
--
--      At the start of each block, the 'di_req' signal is raised to request new data.
--
--      state       ... process  |next | data                                    |wait |                                                     | process                    
--                    __    __    __    __    __    __    __    __    __    __   |__   |__    __    __    __    __    __    __    __    __    __ 
--      clk_i      __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \...        -- system clock
--                                                                                                                                                  
--      end_i      ______________________________________________________________________________________________________________________________...        -- 'end_i' marks end of last block data input
--                                      _____________________________________________________________________________________________________       
--      di_req_o   ____________________/                                                                                                     \___...        -- 'di_req_o' asserted during data input
--                                       ______________________________________       _________________________________________________________     
--      wr_i       _____________________/                                      \_____/                                                         \_...        -- 'wr_i' can hold the core for slow data
--                 _________________ _ ______ _____ _____ _____ _____ _____ ___________ _____ _____ _____ _____ _____ _____ _____ _____ _____ ____...
--      di_i       _________________\\\___W0_\__W1_\__W2_\__W3_\__W4_\__W5_\\\\\\\\_W6_\__W7_\__W8_\__W9_\_W10_\_W11_\_W12_\_W13_\_W14_\_W15_\\_X_...       -- user words on 'di_i' are latched on 'clk_i' rising edge
--                 
--
--      UPDATE BLOCK (delayed start)
--      ===========================
--
--      The data for the new block can be delayed, by keeping the 'wr_i' signal low until the data is present at the data input port. 
--
--      state      ..|next | wait                  | data                                          |wait |                                         | process                    
--                    __    __    __    __    __   |__    __    __    __    __    __    __    __   |__   |__    __    __    __    __    __    __    __ 
--      clk_i      __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \...     -- system clock
--                                                                                                                                                       
--      end_i      ____________________________________________________________________________________________________________________________________...     -- 'end_i' marks end of last block data input
--                          _______ _ _ ___________________________________________________________________________________________________________      
--      di_req_o   ________/                                                                                                                       \___...     -- 'di_req_o' asserted during data input
--                                             __________________________________________________       _____________________________________________    
--      wr_i       ________________ _ _ ______/                                                  \_____/                                             \_...     -- 'wr_i' valid on rising edge of 'clk_i'
--                 ________________ _ _ ___________ _____ _____ _____ _____ _____ _____ _____ ___________ _____ _____ _____ _____ _____ _____ _____ ____...
--      di_i       ________________ _ _ ______\_W0_\__W1_\__W2_\__W3_\__W4_\__W5_\__W6_\__W7_\\\\_____W8_\__W9_\_W10_\_W11_\_W12_\_W13_\_W14_\_W15_\__Z_...     -- user words on 'di_i' are latched on 'clk_i' rising edge
--                 
--
--      END BLOCK (success)
--      ==================
--
--      At the end of the last block the signal 'end' must be raised for at least one clock cycle. 
--      The 'bytes' input marks the number of valid bytes in the last word. 
--      A PADDING state completes the last data block and a BLK_PROCESS finishes the hash computation.
--      The 'do_valid' remains HIGH until the next RESET.
--
--      state      ..|next | data                              | padding         | process                     |next | valid     |reset| data     
--                    __    __    __    __    __    __    __    __    __          __    __    __          __    __    __    __    __    __    __  
--      clk_i      __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \_ _ _ __/  \__/  \__/  \_ _ _ __/  \__/  \__/  \__/  \__/  \__/  \__/  \_...     -- system clock
--                                                                                                                              ______                    
--      start_i    ____________________________________________________________________________________________________________/   \__\___________...     -- 'start_i' resets the processor and starts a new hash
--                                                           ______                                                                               
--      end_i      _________________________________________/      \______ _ _ ___________________ _ _ ___________________________________________...     -- 'end_i' marks end of last block data input
--                          ___________________________________                                                                         __________  
--      di_req_o   ________/                                   \__________ _ _ ___________________ _ _ ________________________________/          ...     -- 'di_req_o' asserted during data input
--                           ______________________________________                                                                      _________  
--      wr_i       _________/                                    \\\______ _ _ ___________________ _ _ _________________________________/         ...     -- 'wr_i' can hold the core for slow data
--                 ______________ _____ _____ _____ _____ _____ __________ _ _ ___________________ _ _ ______________________________________ ____...
--      di_i       _________\_W0_\__W1_\__W2_\__W3_\__W4_\__W5_\__________ _ _ ___________________ _ _ _________________________________\_W0_\__W1...     -- words after the end_i assertion are ignored
--                 __ _____ _____ _____ _____ _____ _____ _____ _____ ____ _ ____ _____ _____ ____ _ _ ______________________________________ ____
--      st_cnt_reg __/_64__/__0__/__1__/__2__/__3__/__4__/__5__/__6__/__7_ _ _15_/__16_/__17_/__18 _ _ __/__63_/__64_/______0__________/__0__/__1_...     -- internal state counter value
--                          _____ _____ _____ _____ _____ _____                                                                         _____ ____
--      bytes_i    --------<__0__\__0__\__0__\__0__\__0__\__3__>-----------------------------------------------------------------------<__0__\__0_...     -- bytes_i mark number of valid bytes in each word
--                                                                                                                                                   
--      error_o    _______________________________________________________ _ _ ___________________ _ _ ___________________________________________...     -- 'error_o' goes high on an invalid computation
--                                                                                                                    ___________                 
--      do_valid_o _______________________________________________________ _ _ ___________________ _ _ ______________/           \________________...     -- 'do_valid_o' goes high at the end of a computation
--                                                                                                                    ___________                 
--      H0_o       _______________________________________________________ _ _ ___________________ _ _ ______________/___H0______\________________...     -- H0 holds the bytes 0..3 of the output
--                                                                                                                    ___________                                 
--      H1_o       _______________________________________________________ _ _ ___________________ _ _ ______________/___H1______\________________...     -- H1 holds the bytes 4..7 of the output
--                                                                                                                    ___________                            
--      H2_o       _______________________________________________________ _ _ ___________________ _ _ ______________/___H2______\________________...     -- H2 holds the bytes 8..11 of the output
--                                                                                                                    ___________                            
--      H3_o       _______________________________________________________ _ _ ___________________ _ _ ______________/___H3______\________________...     -- H3 holds the bytes 12..15 of the output
--                                                                                                                    ___________                            
--      H4_o       _______________________________________________________ _ _ ___________________ _ _ ______________/___H4______\________________...     -- H4 holds the bytes 16..19 of the output
--                                                                                                                    ___________                            
--      H5_o       _______________________________________________________ _ _ ___________________ _ _ ______________/___H5______\________________...     -- H5 holds the bytes 20..23 of the output
--                                                                                                                    ___________                            
--      H6_o       _______________________________________________________ _ _ ___________________ _ _ ______________/___H6______\________________...     -- H6 holds the bytes 24..27 of the output
--                                                                                                                    ___________                            
--      H7_o       _______________________________________________________ _ _ ___________________ _ _ ______________/___H7______\________________...     -- H7 holds the bytes 28..31 of the output
--
--
--      END BLOCK (full last block)
--      ==================
--
--      If the last block has exactly 16 full words, the controller starts the block processing in the PADDING cycle, processes the input block, 
--      and inserts a last PADDING block followed by a last BLK_PROCESS block.
--
--      state      ... data         |pad  | process   |next | pad                   | process   |next | valid     |reset| data
--                 __    __    __    __    __          __    __    __          __    __          __    __    __    __    __    __     
--      clk_i        \__/  \__/  \__/  \__/  \_ _ _ __/  \__/  \__/  \_ _ _ __/  \__/  \_ _ _ __/  \__/  \__/  \__/  \__/  \__/  \_...     -- system clock
--                                                                                                               ______                  
--      start_i    _____________________________________________________________________________________________/   \__\___________...     -- 'start_i' resets the processor and starts a new hash
--                                ______                                                                                                      
--      end_i      ______________/      \______ _ _ ___________________ _ _ _____________ _ _ _____________________________________...     -- 'end_i' marks end of last block data input
--                 _________________                                                                                     __________  
--      di_req_o                    \__________ _ _ ___________________ _ _ _____________ _ _ __________________________/          ...     -- 'di_req_o' asserted on rising edge of 'clk_i'
--                 ____________________                                                                                   _________  
--      wr_i                         \\\_______ _ _ ___________________ _ _ _____________ _ _ ___________________________/         ...     -- 'wr_i' valid on rising edge of 'clk_i'
--                 _____ _____ _____ __________ _ _ ___________________ _ _ _____________ _ _ ________________________________ ____...
--      di_i       _W13_\_W14_\_W15_\__________ _ _ ___________________ _ _ _____________ _ _ ___________________________\_W0_\__W1...     -- words after the end_i assertion are ignored
--                 _____ _____ _____ _____ ____ _ ____ _____ _____ ____ _ _ ________ ____ _ ____ _____ _______________________ ____
--      st_cnt_reg _13__/_14__/_15__/_16__/_17_ _ _63_/__64_/__0__/__1_ _ _ __/_15__/_16_ _ _63_/__64_/_____0_____/__0__/__0__/__1_...     -- internal state counter value
--                 _____ _____ _____                                                                                     _____ ____
--      bytes_i    __0__/__0__/__0__>-----------------------------------------------------------------------------------<__0__/__0_...     -- bytes_i mark number of valid bytes in each word
--                                                                                                     ___________                 
--      do_valid_o ____________________________ _ _ ___________________ _ _ __________________________/           \________________...     -- 'do_valid_o' goes high at the end of a computation
--
------------------------------ COPYRIGHT NOTICE -----------------------------------------------------------------------
--                                                                   
--      This file is part of the SHA256 HASH CORE project http://opencores.org/project,sha256_hash_core
--                                                                   
--      Author(s):      Jonny Doin, jdoin@opencores.org, jonnydoin@gridvortex.com, jonnydoin@gmail.com
--                                                                   
--      Copyright (C) 2016 Jonny Doin
--      -----------------------------
--                                                                   
--      This source file may be used and distributed without restriction provided that this copyright statement is not    
--      removed from the file and that any derivative work contains the original copyright notice and the associated 
--      disclaimer. 
--                                                                   
--      This source file is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser 
--      General Public License as published by the Free Software Foundation; either version 2.1 of the License, or 
--      (at your option) any later version.
--                                                                   
--      This source is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
--      warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more  
--      details.
--
--      You should have received a copy of the GNU Lesser General Public License along with this source; if not, download 
--      it from http://www.gnu.org/licenses/lgpl.txt
--                                                                   
------------------------------ REVISION HISTORY -----------------------------------------------------------------------
--
-- 2016/05/22   v0.01.0010  [JD]    started development. design of blocks and port interfaces.
-- 2016/06/05   v0.01.0090  [JD]    all modules integrated. testbench for basic test vectors verification.
-- 2016/06/05   v0.01.0095  [JD]    verification failed. misalignment of words in the datapath. 
-- 2016/06/06   v0.01.0100  [JD]    first simulation verification against NIST-FIPS-180-4 test vectors "abc" passed.
-- 2016/06/07   v0.01.0101  [JD]    failed 2-block test for "abcdbcdecd..." vector. Fixed padding control logic.
-- 2016/06/07   v0.01.0105  [JD]    sha256 verification against all NIST-FIPS-180-4 test vectors passed.
-- 2016/06/11   v0.01.0105  [JD]    verification against NIST-SHA2_Additional test vectors #1 to #10 passed.
-- 2016/06/11   v0.01.0110  [JD]    optimized controller states, reduced 2 clocks per block. 
-- 2016/06/18   v0.01.0120  [JD]    implemented error detection on 'bytes_i' input.
-- 2016/09/25   v0.01.0220  [JD]    changed 'di_ack_i' name to 'di_wr_i', and changed semantics to 'data write'.
-- 2016/10/01   v0.01.0250  [JD]    optimized the last null-padding state, making the algorithm isochronous for full last data blocks. 
--
-----------------------------------------------------------------------------------------------------------------------
--  TODO
--  ====
--
--
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity testbench is
    Generic (   
        CLK_PERIOD : time := 10 ns;                     -- clock period for pclk_i (default 100MHz)
        START_DELAY : time := 200 ns                    -- start delay between each run
    );
end testbench;

architecture behavior of testbench is 

    --=============================================================================================
    -- Constants
    --=============================================================================================
    -- clock period
    constant PCLK_PERIOD : time := CLK_PERIOD;          -- parallel high-speed clock
    
    --=============================================================================================
    -- Signals for state machine control
    --=============================================================================================

    --=============================================================================================
    -- Signals for internal operation
    --=============================================================================================
    --- clock signals ---
    signal pclk             : std_logic := '1';                 -- 100MHz clock
    signal dut_ce           : std_logic;
    -- input data
    signal dut_di           : std_logic_vector (31 downto 0);   -- big endian input message words
    signal dut_bytes        : std_logic_vector (1 downto 0);    -- valid bytes in input word
    -- start/end commands
    signal dut_start        : std_logic;                        -- reset the processor and start a new hash
    signal dut_end          : std_logic;                        -- marks end of last block data input
    -- handshake
    signal dut_di_req       : std_logic;                        -- requests data input for next word
    signal dut_di_wr        : std_logic;                        -- high for di_i write, low for hold
    signal dut_error        : std_logic;                        -- signalizes error. output data is invalid
    signal dut_do_valid     : std_logic;                        -- when high, the output is valid
    -- 256bit output registers
    signal dut_H0           : std_logic_vector (31 downto 0);
    signal dut_H1           : std_logic_vector (31 downto 0);
    signal dut_H2           : std_logic_vector (31 downto 0);
    signal dut_H3           : std_logic_vector (31 downto 0);
    signal dut_H4           : std_logic_vector (31 downto 0);
    signal dut_H5           : std_logic_vector (31 downto 0);
    signal dut_H6           : std_logic_vector (31 downto 0);
    signal dut_H7           : std_logic_vector (31 downto 0);

    -- testbench control signals
    signal words            : natural;
    signal blocks           : natural;
    signal test_case        : natural;
begin

    --=============================================================================================
    -- INSTANTIATION FOR THE DEVICE UNDER TEST
    --=============================================================================================
	Inst_sha_256_dut: entity work.gv_sha256(rtl)
        port map(
            -- clock and core enable
            clk_i => pclk,
            ce_i => dut_ce,
            -- input data
            di_i => dut_di,
            bytes_i => dut_bytes,
            -- start/end commands
            start_i => dut_start,
            end_i => dut_end,
            -- handshake
            di_req_o => dut_di_req,
            di_wr_i => dut_di_wr,
            error_o => dut_error,
            do_valid_o => dut_do_valid,
            -- 256bit output registers 
            H0_o => dut_H0,
            H1_o => dut_H1,
            H2_o => dut_H2,
            H3_o => dut_H3,
            H4_o => dut_H4,
            H5_o => dut_H5,
            H6_o => dut_H6,
            H7_o => dut_H7
        );

    --=============================================================================================
    -- CLOCK GENERATION
    --=============================================================================================
    pclk_proc: process is
    begin
        loop
            pclk <= not pclk;
            wait for PCLK_PERIOD / 2;
        end loop;
    end process pclk_proc;
    --=============================================================================================
    -- TEST BENCH STIMULI
    --=============================================================================================
    -- This testbench exercises the SHA256 toplevel with the NIST-FIPS-180-4 test vectors.
    --
    tb1 : process is
        variable count_words  : natural := 0;
        variable count_blocks : natural := 0;
        variable temp_di      : unsigned (31 downto 0) := (others => '0');
    begin
        wait for START_DELAY; -- wait until global set/reset completes
        -------------------------------------------------------------------------------------------
        -- test vector 1
        -- src: NIST-FIPS-180-4 
        -- msg := "abc" 
        -- hash:= BA7816BF 8F01CFEA 414140DE 5DAE2223 B00361A3 96177A9C B410FF61 F20015AD
        test_case <= 1;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"61626300";
        dut_bytes <= b"11";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: BA7816BF 8F01CFEA 414140DE 5DAE2223 B00361A3 96177A9C B410FF61 F20015AD
        assert dut_H0 = x"BA7816BF" report "test #1 failed on H0" severity error;
        assert dut_H1 = x"8F01CFEA" report "test #1 failed on H1" severity error;
        assert dut_H2 = x"414140DE" report "test #1 failed on H2" severity error;
        assert dut_H3 = x"5DAE2223" report "test #1 failed on H3" severity error;
        assert dut_H4 = x"B00361A3" report "test #1 failed on H4" severity error;
        assert dut_H5 = x"96177A9C" report "test #1 failed on H5" severity error;
        assert dut_H6 = x"B410FF61" report "test #1 failed on H6" severity error;
        assert dut_H7 = x"F20015AD" report "test #1 failed on H7" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 2
        -- src: NIST-FIPS-180-4 
        -- msg := "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
        -- hash:= 248D6A61 D20638B8 E5C02693 0C3E6039 A33CE459 64FF2167 F6ECEDD4 19DB06C1
        test_case <= 2;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        wait until pclk'event and pclk = '1';   -- 'begin' pulse minimum width is one clock
        wait for 25 ns;                         -- TEST: stretch 'begin' pulse
        dut_start <= '0';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';
        dut_bytes <= b"00";
        dut_di <= x"61626364";
        wait until pclk'event and pclk = '1';
        dut_di <= x"62636465";
        wait until pclk'event and pclk = '1';
        dut_di <= x"63646566";
        wait until pclk'event and pclk = '1';
        dut_di <= x"64656667";
        wait until pclk'event and pclk = '1';
        dut_di <= x"65666768";
        wait until pclk'event and pclk = '1';
        dut_di <= x"66676869";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6768696A";
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';                      -- TEST: slow inputs with 'wr_i' handshake
        wait until pclk'event and pclk = '1';
        dut_di <= x"68696A6B";
        wait until pclk'event and pclk = '1';
        dut_di <= x"696A6B6C";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6A6B6C6D";
        dut_bytes <= b"01";                     -- induce ERROR
        wait until pclk'event and pclk = '1';
        dut_di <= x"6B6C6D6E";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6C6D6E6F";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6D6E6F70";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6E6F7071";
        dut_end <= '1';
        wait until pclk'event and pclk = '1';   -- 'end' pulse minimum width is one clock
        dut_bytes <= b"01";                     -- TEST: change 'bytes' value after END
        wait for 75 ns;                         -- TEST: stretch 'end' pulse
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;
        -------------------------------------------------------------------------
        -- restart test #2: force error by stretching the write strobe
        dut_ce <= '0';
        test_case <= 0;
        wait until pclk'event and pclk = '1';
        test_case <= 2;
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        wait until pclk'event and pclk = '1';   -- 'begin' pulse minimum width is one clock
        wait for 25 ns;                         -- TEST: stretch 'begin' pulse
        dut_start <= '0';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';
        dut_bytes <= b"00";
        dut_di <= x"61626364";
        wait until pclk'event and pclk = '1';
        dut_di <= x"62636465";
        wait until pclk'event and pclk = '1';
        dut_di <= x"63646566";
        wait until pclk'event and pclk = '1';
        dut_di <= x"64656667";
        wait until pclk'event and pclk = '1';
        dut_di <= x"65666768";
        wait until pclk'event and pclk = '1';
        dut_di <= x"66676869";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6768696A";
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';                      -- TEST: slow inputs with 'wr_i' handshake
        wait until pclk'event and pclk = '1';
        dut_di <= x"68696A6B";
        wait until pclk'event and pclk = '1';
        dut_di <= x"696A6B6C";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6A6B6C6D";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6B6C6D6E";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6C6D6E6F";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6D6E6F70";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6E6F7071";
        wait for 75 ns;
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;
        -------------------------------------------------------------------------
        -- restart test #2
        dut_ce <= '0';
        test_case <= 0;
        wait until pclk'event and pclk = '1';
        test_case <= 2;
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"61626364";
        dut_bytes <= b"00";
        wait until pclk'event and pclk = '1';   -- 'begin' pulse minimum width is one clock
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        dut_di <= x"62636465";
        wait until pclk'event and pclk = '1';
        dut_di <= x"63646566";
        wait until pclk'event and pclk = '1';
        dut_di <= x"64656667";
        wait until pclk'event and pclk = '1';
        dut_di <= x"65666768";
        wait until pclk'event and pclk = '1';
        dut_di <= x"66676869";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6768696A";
        wait until pclk'event and pclk = '1';
        dut_di <= x"68696A6B";
        wait until pclk'event and pclk = '1';
        dut_di <= x"696A6B6C";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6A6B6C6D";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6B6C6D6E";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6C6D6E6F";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6D6E6F70";
        wait until pclk'event and pclk = '1';
        dut_di <= x"6E6F7071";
        dut_end <= '1';
        wait until pclk'event and pclk = '1';   -- 'end' pulse minimum width is one clock
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: 248D6A61 D20638B8 E5C02693 0C3E6039 A33CE459 64FF2167 F6ECEDD4 19DB06C1
        assert dut_H0 = x"248D6A61" report "test #2 failed on H0" severity error;
        assert dut_H1 = x"D20638B8" report "test #2 failed on H1" severity error;
        assert dut_H2 = x"E5C02693" report "test #2 failed on H2" severity error;
        assert dut_H3 = x"0C3E6039" report "test #2 failed on H3" severity error;
        assert dut_H4 = x"A33CE459" report "test #2 failed on H4" severity error;
        assert dut_H5 = x"64FF2167" report "test #2 failed on H5" severity error;
        assert dut_H6 = x"F6ECEDD4" report "test #2 failed on H6" severity error;
        assert dut_H7 = x"19DB06C1" report "test #2 failed on H7" severity error;

        -------------------------------------------------------------------------------------------
        -- test vector 3
        -- src: NIST-ADDITIONAL-SHA256
        -- #1) 1 byte 0xbd
        -- msg := x"bd"
        -- hash:= 68325720 aabd7c82 f30f554b 313d0570 c95accbb 7dc4b5aa e11204c0 8ffe732b
        test_case <= 3;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"bd000000";
        dut_bytes <= b"01";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: 68325720 aabd7c82 f30f554b 313d0570 c95accbb 7dc4b5aa e11204c0 8ffe732b
        assert dut_H0 = x"68325720" report "test #3 failed on H0" severity error;
        assert dut_H1 = x"aabd7c82" report "test #3 failed on H1" severity error;
        assert dut_H2 = x"f30f554b" report "test #3 failed on H2" severity error;
        assert dut_H3 = x"313d0570" report "test #3 failed on H3" severity error;
        assert dut_H4 = x"c95accbb" report "test #3 failed on H4" severity error;
        assert dut_H5 = x"7dc4b5aa" report "test #3 failed on H5" severity error;
        assert dut_H6 = x"e11204c0" report "test #3 failed on H6" severity error;
        assert dut_H7 = x"8ffe732b" report "test #3 failed on H7" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 4
        -- src: NIST-ADDITIONAL-SHA256
        -- #2) 4 bytes 0xc98c8e55
        -- msg := x"c98c8e55"
        -- hash:= 7abc22c0 ae5af26c e93dbb94 433a0e0b 2e119d01 4f8e7f65 bd56c61c cccd9504
        test_case <= 4;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"c98c8e55";
        dut_bytes <= b"00";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        dut_di_wr <= '1';
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: 7abc22c0 ae5af26c e93dbb94 433a0e0b 2e119d01 4f8e7f65 bd56c61c cccd9504 
        assert dut_H0 = x"7abc22c0" report "test #4 failed on H0" severity error;
        assert dut_H1 = x"ae5af26c" report "test #4 failed on H1" severity error;
        assert dut_H2 = x"e93dbb94" report "test #4 failed on H2" severity error;
        assert dut_H3 = x"433a0e0b" report "test #4 failed on H3" severity error;
        assert dut_H4 = x"2e119d01" report "test #4 failed on H4" severity error;
        assert dut_H5 = x"4f8e7f65" report "test #4 failed on H5" severity error;
        assert dut_H6 = x"bd56c61c" report "test #4 failed on H6" severity error;
        assert dut_H7 = x"cccd9504" report "test #4 failed on H7" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 5
        -- src: NIST-ADDITIONAL-SHA256
        -- #3) 55 bytes of zeros
        -- msg := 55 x"00"
        -- hash:= 02779466 cdec1638 11d07881 5c633f21 90141308 1449002f 24aa3e80 f0b88ef7
        test_case <= 5;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"00000000";
        dut_bytes <= b"00";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '1';
        dut_bytes <= b"11";
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: 02779466 cdec1638 11d07881 5c633f21 90141308 1449002f 24aa3e80 f0b88ef7
        assert dut_H0 = x"02779466" report "test #5 failed on H0" severity error;
        assert dut_H1 = x"cdec1638" report "test #5 failed on H1" severity error;
        assert dut_H2 = x"11d07881" report "test #5 failed on H2" severity error;
        assert dut_H3 = x"5c633f21" report "test #5 failed on H3" severity error;
        assert dut_H4 = x"90141308" report "test #5 failed on H4" severity error;
        assert dut_H5 = x"1449002f" report "test #5 failed on H5" severity error;
        assert dut_H6 = x"24aa3e80" report "test #5 failed on H6" severity error;
        assert dut_H7 = x"f0b88ef7" report "test #5 failed on H7" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 6
        -- src: NIST-ADDITIONAL-SHA256
        -- #4) 56 bytes of zeros
        -- msg := 56 x"00"
        -- hash:= d4817aa5 497628e7 c77e6b60 6107042b bba31308 88c5f47a 375e6179 be789fbb
        test_case <= 6;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"00000000";
        dut_bytes <= b"00";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: d4817aa5 497628e7 c77e6b60 6107042b bba31308 88c5f47a 375e6179 be789fbb
        assert dut_H0 = x"d4817aa5" report "test #6 failed on H0" severity error;
        assert dut_H1 = x"497628e7" report "test #6 failed on H1" severity error;
        assert dut_H2 = x"c77e6b60" report "test #6 failed on H2" severity error;
        assert dut_H3 = x"6107042b" report "test #6 failed on H3" severity error;
        assert dut_H4 = x"bba31308" report "test #6 failed on H4" severity error;
        assert dut_H5 = x"88c5f47a" report "test #6 failed on H5" severity error;
        assert dut_H6 = x"375e6179" report "test #6 failed on H6" severity error;
        assert dut_H7 = x"be789fbb" report "test #6 failed on H7" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 7
        -- src: NIST-ADDITIONAL-SHA256
        -- #5) 57 bytes of zeros
        -- msg := 57 x"00"
        -- hash:= 65a16cb7 861335d5 ace3c607 18b5052e 44660726 da4cd13b b745381b 235a1785
        test_case <= 7;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"00000000";
        dut_bytes <= b"00";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '1';
        dut_bytes <= b"01";
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: 65a16cb7 861335d5 ace3c607 18b5052e 44660726 da4cd13b b745381b 235a1785
        assert dut_H0 = x"65a16cb7" report "test #7 failed on H0" severity error;
        assert dut_H1 = x"861335d5" report "test #7 failed on H1" severity error;
        assert dut_H2 = x"ace3c607" report "test #7 failed on H2" severity error;
        assert dut_H3 = x"18b5052e" report "test #7 failed on H3" severity error;
        assert dut_H4 = x"44660726" report "test #7 failed on H4" severity error;
        assert dut_H5 = x"da4cd13b" report "test #7 failed on H5" severity error;
        assert dut_H6 = x"b745381b" report "test #7 failed on H6" severity error;
        assert dut_H7 = x"235a1785" report "test #7 failed on H7" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 8
        -- src: NIST-ADDITIONAL-SHA256
        -- #6) 64 bytes of zeros
        -- msg := 64 x"00"
        -- hash:= f5a5fd42 d16a2030 2798ef6e d309979b 43003d23 20d9f0e8 ea9831a9 2759fb4b
        test_case <= 8;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        dut_di <= x"00000000";
        dut_bytes <= b"00";
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_di_wr <= '1';
        if dut_di_req = '0' then
            wait until dut_di_req = '1';
        end if;
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: f5a5fd42 d16a2030 2798ef6e d309979b 43003d23 20d9f0e8 ea9831a9 2759fb4b
        assert dut_H0 = x"f5a5fd42" report "test #8 failed on H0" severity error;
        assert dut_H1 = x"d16a2030" report "test #8 failed on H1" severity error;
        assert dut_H2 = x"2798ef6e" report "test #8 failed on H2" severity error;
        assert dut_H3 = x"d309979b" report "test #8 failed on H3" severity error;
        assert dut_H4 = x"43003d23" report "test #8 failed on H4" severity error;
        assert dut_H5 = x"20d9f0e8" report "test #8 failed on H5" severity error;
        assert dut_H6 = x"ea9831a9" report "test #8 failed on H6" severity error;
        assert dut_H7 = x"2759fb4b" report "test #8 failed on H7" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 9
        -- src: NIST-ADDITIONAL-SHA256
        -- #7) 1000 bytes of zeros
        -- msg := 1000 x"00"
        -- hash:= 541b3e9d aa09b20b f85fa273 e5cbd3e8 0185aa4e c298e765 db87742b 70138a53
        test_case <= 9;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_bytes <= b"00";
        dut_di <= x"00000000";
        count_words := 0;
        words <= count_words;
        count_blocks := 0;
        blocks <= count_blocks;
        loop
            wait until dut_di_req = '1';
            wait until pclk'event and pclk = '1';
            dut_di_wr <= '1';
            loop
                wait until pclk'event and pclk = '1';
                count_words := count_words + 1;
                words <= count_words;
                exit when words = 15;
            end loop;
            dut_di_wr <= '0';
            count_words := 0;
            words <= count_words;
            count_blocks := count_blocks + 1;
            blocks <= count_blocks;
            exit when blocks = 14;
        end loop;
        count_words := 0;
        words <= count_words;
        wait until dut_di_req = '1';
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';
        loop
            wait until pclk'event and pclk = '1';
            count_words := count_words + 1;
            words <= count_words;
            exit when words = 8;
        end loop;
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: 541b3e9d aa09b20b f85fa273 e5cbd3e8 0185aa4e c298e765 db87742b 70138a53
        assert dut_H0 = x"541b3e9d" report "test #9 failed on H0" severity error;
        assert dut_H1 = x"aa09b20b" report "test #9 failed on H1" severity error;
        assert dut_H2 = x"f85fa273" report "test #9 failed on H2" severity error;
        assert dut_H3 = x"e5cbd3e8" report "test #9 failed on H3" severity error;
        assert dut_H4 = x"0185aa4e" report "test #9 failed on H4" severity error;
        assert dut_H5 = x"c298e765" report "test #9 failed on H5" severity error;
        assert dut_H6 = x"db87742b" report "test #9 failed on H6" severity error;
        assert dut_H7 = x"70138a53" report "test #9 failed on H7" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 10
        -- src: NIST-ADDITIONAL-SHA256
        -- #8) 1000 bytes of 0x41 'A'
        -- msg := 1000 x"41"
        -- hash:= c2e68682 3489ced2 017f6059 b8b23931 8b6364f6 dcd835d0 a519105a 1eadd6e4
        test_case <= 10;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_bytes <= b"00";
        dut_di <= x"41414141";
        count_words := 0;
        words <= count_words;
        count_blocks := 0;
        blocks <= count_blocks;
        loop
            wait until dut_di_req = '1';
            wait until pclk'event and pclk = '1';
            dut_di_wr <= '1';
            loop
                wait until pclk'event and pclk = '1';
                count_words := count_words + 1;
                words <= count_words;
                exit when words = 15;
            end loop;
            dut_di_wr <= '0';
            count_words := 0;
            words <= count_words;
            count_blocks := count_blocks + 1;
            blocks <= count_blocks;
            exit when blocks = 14;
        end loop;
        count_words := 0;
        words <= count_words;
        wait until dut_di_req = '1';
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';
        loop
            wait until pclk'event and pclk = '1';
            count_words := count_words + 1;
            words <= count_words;
            exit when words = 8;
        end loop;
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: c2e68682 3489ced2 017f6059 b8b23931 8b6364f6 dcd835d0 a519105a 1eadd6e4
        assert dut_H0 = x"c2e68682" report "test #10 failed on H0" severity error;
        assert dut_H1 = x"3489ced2" report "test #10 failed on H1" severity error;
        assert dut_H2 = x"017f6059" report "test #10 failed on H2" severity error;
        assert dut_H3 = x"b8b23931" report "test #10 failed on H3" severity error;
        assert dut_H4 = x"8b6364f6" report "test #10 failed on H4" severity error;
        assert dut_H5 = x"dcd835d0" report "test #10 failed on H5" severity error;
        assert dut_H6 = x"a519105a" report "test #10 failed on H6" severity error;
        assert dut_H7 = x"1eadd6e4" report "test #10 failed on H7" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 11
        -- src: NIST-ADDITIONAL-SHA256
        -- #9) 1005 bytes of 0x55 'U'
        -- msg := 1000 x"55"
        -- hash:= f4d62dde c0f3dd90 ea1380fa 16a5ff8d c4c54b21 740650f2 4afc4120 903552b0
        test_case <= 11;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_bytes <= b"00";
        dut_di <= x"55555555";
        count_words := 0;
        words <= count_words;
        count_blocks := 0;
        blocks <= count_blocks;
        loop
            wait until dut_di_req = '1';
            wait until pclk'event and pclk = '1';
            dut_di_wr <= '1';
            loop
                wait until pclk'event and pclk = '1';
                count_words := count_words + 1;
                words <= count_words;
                exit when words = 15;
            end loop;
            dut_di_wr <= '0';
            count_words := 0;
            words <= count_words;
            count_blocks := count_blocks + 1;
            blocks <= count_blocks;
            exit when blocks = 14;
        end loop;
        count_words := 0;
        words <= count_words;
        wait until dut_di_req = '1';
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';
        loop
            wait until pclk'event and pclk = '1';
            count_words := count_words + 1;
            words <= count_words;
            exit when words = 9;
        end loop;
        wait until pclk'event and pclk = '1';
        dut_bytes <= b"01";
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: f4d62dde c0f3dd90 ea1380fa 16a5ff8d c4c54b21 740650f2 4afc4120 903552b0
        assert dut_H0 = x"f4d62dde" report "test #11 failed on H0" severity error;
        assert dut_H1 = x"c0f3dd90" report "test #11 failed on H1" severity error;
        assert dut_H2 = x"ea1380fa" report "test #11 failed on H2" severity error;
        assert dut_H3 = x"16a5ff8d" report "test #11 failed on H3" severity error;
        assert dut_H4 = x"c4c54b21" report "test #11 failed on H4" severity error;
        assert dut_H5 = x"740650f2" report "test #11 failed on H5" severity error;
        assert dut_H6 = x"4afc4120" report "test #11 failed on H6" severity error;
        assert dut_H7 = x"903552b0" report "test #11 failed on H7" severity error;
        
        -------------------------------------------------------------------------------------------
        -- test vector 12
        -- src: NIST-ADDITIONAL-SHA256
        -- #10) 1000000 bytes of zeros
        -- msg := 1000000 x"00"
        -- hash:= d29751f2 649b32ff 572b5e0a 9f541ea6 60a50f94 ff0beedf b0b692b9 24cc8025
        test_case <= 12;
        dut_ce <= '0';
        dut_di <= (others => '0');
        dut_bytes <= b"00";
        dut_start <= '0';
        dut_end <= '0';
        dut_di_wr <= '0';
        wait until pclk'event and pclk = '1';
        dut_ce <= '1';
        dut_start <= '1';
        wait until pclk'event and pclk = '1';
        dut_start <= '0';
        dut_bytes <= b"00";
        dut_di <= x"00000000";
        count_words := 0;
        words <= count_words;
        count_blocks := 0;
        blocks <= count_blocks;
        loop
            wait until dut_di_req = '1';
            wait until pclk'event and pclk = '1';
            dut_di_wr <= '1';
            loop
                wait until pclk'event and pclk = '1';
                count_words := count_words + 1;
                words <= count_words;
                exit when words = 15;
            end loop;
            dut_di_wr <= '0';
            count_words := 0;
            words <= count_words;
            count_blocks := count_blocks + 1;
            blocks <= count_blocks;
            exit when blocks = 15623;
        end loop;
        count_words := 0;
        words <= count_words;
        wait until dut_di_req = '1';
        wait until pclk'event and pclk = '1';
        dut_di_wr <= '1';
        loop
            wait until pclk'event and pclk = '1';
            count_words := count_words + 1;
            words <= count_words;
            exit when words = 14;
        end loop;
        dut_end <= '1';
        wait until pclk'event and pclk = '1';
        dut_end <= '0';
        dut_di_wr <= '0';
        if dut_error /= '1' and dut_do_valid /= '1' then 
            while dut_error /= '1' and dut_do_valid /= '1' loop
                wait until pclk'event and pclk = '1';
            end loop;
        end if;
        wait for CLK_PERIOD*20;

        -- expected: d29751f2 649b32ff 572b5e0a 9f541ea6 60a50f94 ff0beedf b0b692b9 24cc8025
        assert dut_H0 = x"d29751f2" report "test #12 failed on H0" severity error;
        assert dut_H1 = x"649b32ff" report "test #12 failed on H1" severity error;
        assert dut_H2 = x"572b5e0a" report "test #12 failed on H2" severity error;
        assert dut_H3 = x"9f541ea6" report "test #12 failed on H3" severity error;
        assert dut_H4 = x"60a50f94" report "test #12 failed on H4" severity error;
        assert dut_H5 = x"ff0beedf" report "test #12 failed on H5" severity error;
        assert dut_H6 = x"b0b692b9" report "test #12 failed on H6" severity error;
        assert dut_H7 = x"24cc8025" report "test #12 failed on H7" severity error;


        assert false report "End Simulation" severity failure; -- stop simulation
    end process tb1;
    --  End Test Bench 
END;
