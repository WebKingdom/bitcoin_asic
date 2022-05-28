-----------------------------------------------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com, jonnydoin@gridvortex.com
-- 
-- Create Date:     09:56:30 05/06/2016  
-- Module Name:     sha256_control - RTL
-- Project Name:    sha256 hash engine
-- Target Devices:  Spartan-6
-- Tool versions:   ISE 14.7
-- Description: 
--
--      This is the control path logic for the GV_SHA256 fast engine.
--
--      It is a fully synchronous design, with all signals synchronous to the rising edge of the system clock.
--      The sequencer state machine controls the hash datapath modules, generating addresses for the coefficients ROM, load/enable signals for the 
--      message schedule, hash core and output registers circuit blocks, and control signals for the input padding logic.
--
--      The SHA256 hash core follows the FIPS-180-4 logic description for the SHA-256 algorithm, optimized as a single-cycle per iteration engine. 
--                                                                                              
--      This implementation follows the implementation guidelines of the NIST Cryptographic Toolkit, and the NIST Approved Algorithms notes. 
--
--      RELEVANT NIST PUBLICATIONS
--      Link to Document                                                               | Description
--      ------------------------------------------------------------------------------ | ---------------------------------------------------------
--      http://csrc.nist.gov/publications/fips/fips140-2/fips1402.pdf                  | SECURITY REQUIREMENTS FOR CRYPTOGRAPHIC MODULES           
--      http://csrc.nist.gov/groups/ST/toolkit/index.html                              | NIST CRYPTOGRAPHIC TOOLKIT                                
--      http://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.180-4.pdf                      | Secure Hash Standard (SHS) SHA-256                        
--      http://csrc.nist.gov/publications/fips/fips198-1/FIPS-198-1_final.pdf          | The Keyed-Hash Message Authentication Code (HMAC)         
--      http://csrc.nist.gov/groups/ST/toolkit/documents/Examples/SHA256.pdf           | SHA-256 verification test vectors                         
--      http://csrc.nist.gov/groups/ST/toolkit/documents/Examples/SHA2_Additional.pdf  | Additional SHA-256 corner case verification test vectors  
--                                                                                             
--      RELEVANT RFCs
--      Link to PDF document                       | Description
--      ------------------------------------------ | ---------------------------------------------------------
--      https://tools.ietf.org/pdf/rfc2104.pdf     | RFC2104 - HMAC: Keyed-Hashing for Message Authentication
--      https://tools.ietf.org/pdf/rfc4231.pdf     | RFC4231 - Identifiers and Test Vectors for HMAC-SHA-256
--      https://tools.ietf.org/pdf/rfc4868.pdf     | RFC4868 - Using HMAC-SHA-256, HMAC-SHA-384, and HMAC-SHA-512 with IPsec
---------------------------------------------------------------------------------------------------------------------------------------------------------------
--      SHA256 ENGINE
--      =============
--
--      The setup of all circuit blocks is performed in a single extra clock cycle, besides the 64 steps needed to compute a hash block operation, 
--      resulting in a 65-cycle per block hash computation processor. Heavy pipelining is implemented to suppress control path operations logic steps. 
--      The engine is internally implemented as a 256-bit machine, with all combinational operations performed as a single-cycle operation on each
--      64 steps of the hash algorithm. Wide transfers of 256-bit data are also performed as single-cycle operations. 
--
--      The data input accepts 16 consecutive 32bit words for a total of 64 bytes per block, one word per clock cycle. The input signal 'wr_i' can be
--      used as a flow control input to hold the processor to wait for slower data.
--
--      A hash computation starts with a 'start_i' pulse that resets the processor. A pulse of the 'end_i' signal marks the last input data word. The
--      core will pad the last block according to the SHA256 rules, and present the results of the hash computation at the output registers, raising the
--      'data_valid' signal to mark the end of the computation. The hash results are available at the 256-bit output port.
--
--      The following waveforms describe the detailed operation for message start, update and end, with internal signals and FSM states. 
--
--      BEGIN BLOCK (1st block) - showing lookahead Wt and Kt
--      ======================
--
--      The hash operation starts with a 'start' sync pulse, which causes the RESET of the processor. The processor comes out of RESET only after 'start' is
--      released. 
--      The DATA_INPUT state is signalled by the data request signal 'di_req' going HIGH. The processor will latch 16 words from the 'di' port, at every 
--      rising edge of the system clock. At the end of the block input, the 'di_req' signal goes LOW. 
--      The input data can be held by bringing the 'ack' input LOW. When the 'ack' input is held LOW, it includes a wait state in the whole processor, to
--      cope with slow inputs or to allow periodic fetches of input data from multiple data sources. 
--
--      STATE              |reset| data                                    |wait |                                                     | process                  
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
--      STATE       ... process  |next | data                                    |wait |                                                     | process                    
--                    __    __    __    __    __    __    __    __    __    __   |__   |__    __    __    __    __    __    __    __    __    __ 
--      clk_i      __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \...        -- system clock
--                                                                                                                                                  
--      end_i      ______________________________________________________________________________________________________________________________...        -- 'end_i' marks end of last block data input
--                                      _____________________________________________________________________________________________________       
--      di_req_o   ____________________/                                                                                                     \___...        -- 'di_req_o' asserted during data input
--                          ___________________________________________________       _________________________________________________________     
--      wr_i       ________/__________/                                        \_____/                                                         \_...        -- 'wr_i' can hold the core for slow data
--                 _________________ _ ______ _____ _____ _____ _____ _____ ___________ _____ _____ _____ _____ _____ _____ _____ _____ _____ ____...
--      di_i       _________________\\\___W0_\__W1_\__W2_\__W3_\__W4_\__W5_\\\\\\\\_W6_\__W7_\__W8_\__W9_\_W10_\_W11_\_W12_\_W13_\_W14_\_W15_\\_X_...       -- user words on 'di_i' are latched on 'clk_i' rising edge
--                 
--
--      UPDATE BLOCK (delayed start)
--      ===========================
--
--      The data for the new block can be delayed, by keeping the 'ack' signal low until the data is present at the data input port. 
--
--      STATE      ..|next | data                                                                  |wait |                                         | process                    
--                    __    __    __    __    __    __    __    __    __    __    __    __    __   |__   |__    __    __    __    __    __    __    __ 
--      clk_i      __/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \__/  \...     -- system clock
--                                                                                                                                                       
--      end_i      ____________________________________________________________________________________________________________________________________...     -- 'end_i' marks end of last block data input
--                          _______ _ _ ___________________________________________________________________________________________________________      
--      di_req_o   ________/                                                                                                                       \___...     -- 'di_req_o' asserted during data input
--                                             __________________________________________________       _____________________________________________    
--      wr_i       ________________ _ _ ______/                                                  \_____/                                             \_...     -- 'wr_i' valid on rising edge of 'clk_i'
--                 ________________ _ _ ___________ _____ _____ _____ _____ _____ _____ _____ ___________ _____ _____ _____ _____ _____ _____ _____ ____...
--      di_i       ________________ _ _ ______\_W0_\__W1_\__W2_\__W3_\__W4_\__W5_\__W6_\__W7_\\\\\\\__W8_\__W9_\_W10_\_W11_\_W12_\_W13_\_W14_\_W15_\\_Z_...     -- user words on 'di_i' are latched on 'clk_i' rising edge
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
--      STATE      ..|next | data                              | padding         | process                     |next | valid     |reset| data     
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
--      STATE      ... data         |pad  | process   |next | pad                   | process   |next | valid     |reset| data
--                 __    __    __   |__   |__         |__   |__    __          __   |__         |__   |__    __   |__   |__    __     
--      clk_i        \__/  \__/  \__/  \__/  \_ _ _ __/  \__/  \__/  \_ _ _ __/  \__/  \_ _ _ __/  \__/  \__/  \__/  \__/  \__/  \_...     -- system clock
--                                                                                                               ______                  
--      start_i    ____________________________ _ _ ____________________________________________________________/   \__\___________...     -- 'start_i' resets the processor and starts a new hash
--                              _____                                                                                                         
--      end_i      ____________/     \_________ _ _ ___________________ _ _ _____________ _ _ _____________________________________...     -- 'end_i' marks end of last block data input
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
-- 2016/06/07   v0.01.0105  [JD]    verification against all NIST-FIPS-180-4 test vectors passed.
-- 2016/06/11   v0.01.0105  [JD]    verification against NIST-SHA2_Additional test vectors #1 to #10 passed.
-- 2016/06/11   v0.01.0110  [JD]    optimized controller states, reduced 2 clocks per block. 
-- 2016/06/18   v0.01.0120  [JD]    implemented error detection on 'bytes_i' input.
-- 2016/07/06   v0.01.0210  [JD]    optimized suspend logic on 'sch_ld' to supress possible glitch in 'pad_one_next'.
-- 2016/09/25   v0.01.0220  [JD]    changed 'ack_i' name to 'wr_i', and changed semantics to 'data write'.
-- 2016/10/01   v0.01.0250  [JD]    optimized the last null-padding state, making the algorithm isochronous for full last data blocks. 
-- 2016/10/01   v0.01.0260  [JD]    eliminated bytes error register, streamlined error logic.
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

entity sha256_control is
    port (  
        -- inputs
        clk_i : in std_logic := 'U';                                    -- system clock
        ce_i : in std_logic := 'U';                                     -- core clock enable
        start_i : in std_logic := 'U';                                  -- reset the processor and start a new hash
        end_i : in std_logic := 'U';                                    -- marks end of last block data input
        wr_i  : in std_logic := 'U';                                    -- input word write/hold control
        bytes_i : in std_logic_vector (1 downto 0) := (others => 'U');  -- valid bytes in input word
        error_i : in std_logic := 'U';                                  -- datapath error input from other modules
        -- output control signals
        bitlen_o : out std_logic_vector (63 downto 0);                  -- message bit length
        words_sel_o : out std_logic_vector (1 downto 0);                -- bitlen insertion control
        Kt_addr_o : out std_logic_vector (5 downto 0);                  -- address for the Kt coefficients ROM
        sch_ld_o : out std_logic;                                       -- load/recirculate words for message scheduler
        core_ld_o : out std_logic;                                      -- load all registers for hash core
        oregs_ld_o : out std_logic;                                     -- load output registers
        sch_ce_o : out std_logic;                                       -- clock enable for message scheduler logic block
        core_ce_o : out std_logic;                                      -- clock enable for hash core logic block
        oregs_ce_o : out std_logic;                                     -- clock enable for output regs logic block
        bytes_ena_o : out std_logic_vector (3 downto 0);                -- byte lane selectors for padding logic block
        one_insert_o : out std_logic;                                   -- insert leading '1' in the padding
        di_req_o : out std_logic;                                       -- external data request by the 'di_i' port
        data_valid_o : out std_logic;                                   -- operation finished. output data is valid
        error_o : out std_logic                                         -- operation aborted. output data is not valid
    );                      
end sha256_control;

architecture rtl of sha256_control is
    --=============================================================================================
    -- Type definitions
    --=============================================================================================
    -- controller states
    type hash_toplevel_control is 
            (   st_reset,                   -- core reset, initial state
                st_sha_data_input,          -- sha data input
                st_sha_blk_process,         -- sha block process
                st_sha_blk_nxt,             -- sha block next
                st_sha_padding,             -- sha padding    
                st_sha_data_valid,          -- sha data valid
                st_error                    -- fsm locks on error, exit only by reset
            );

    --=============================================================================================
    -- Signals for state machine control
    --=============================================================================================
    signal hash_control_st_reg  : hash_toplevel_control := st_reset;
    signal hash_control_st_next : hash_toplevel_control := st_reset;
  
    --=============================================================================================
    -- Signals for internal operation
    --=============================================================================================
    -- combinational flags: message data input / padding control / block internal process selection
    signal reset : std_logic;
    signal sha_reset : std_logic;
    signal sha_init : std_logic;
    signal wait_run_ce : std_logic;
    -- registered flags: last block, padding control
    signal sha_last_blk_reg : std_logic;
    signal sha_last_blk_next : std_logic;
    signal padding_reg : std_logic;
    signal padding_next : std_logic;
    signal pad_one_reg : std_logic;
    signal pad_one_next : std_logic;
    -- 64 bit message bit counter
    signal msg_bit_cnt_reg : unsigned (63 downto 0);
    signal msg_bit_cnt_next : unsigned (63 downto 0);
    signal bits_to_add : unsigned (5 downto 0);
    signal msg_bit_cnt_ce : std_logic;
    -- sequencer state counter
    signal st_cnt_reg : unsigned (6 downto 0);
    signal st_cnt_next : unsigned (6 downto 0);
    signal st_cnt_ce : std_logic;
    signal st_cnt_clr : std_logic;
    
    --=============================================================================================
    -- Output Control Signals
    --=============================================================================================
    -- unregistered control signals
    signal words_sel : std_logic_vector (1 downto 0);   -- bitlen insertion control
    signal sch_ld : std_logic;                          -- input data load into message scheduler control
    signal core_ld : std_logic;                         -- hash core load data registers control
    signal oregs_ld : std_logic;                        -- load initial value into output regs control
    signal sch_ce : std_logic;                          -- clock enable for message scheduler logic block
    signal core_ce : std_logic;                         -- clock enable for hash core logic block
    signal oregs_ce : std_logic;                        -- clock enable for output regs logic block
    signal bytes_ena : std_logic_vector (3 downto 0);   -- byte lane selectors for padding logic block
    signal one_insert : std_logic;                      -- insert leading one in the padding
    signal di_req : std_logic;                          -- data request
    signal di_wr_window : std_logic;                    -- valid data write window    
    signal data_valid : std_logic;                      -- operation finished. output data is valid
    signal data_input_error : std_logic;                -- data write outside write valid window
    signal bytes_error : std_logic;                     -- bytes selection error
    signal error_lock : std_logic;                      -- error state lock
    signal core_error : std_logic;                      -- operation aborted. output data is not valid
    
begin
    --=============================================================================================
    --  REGISTER TRANSFER PROCESSES
    --=============================================================================================
    -- control fsm register transfer logic
    control_fsm_proc: process (clk_i) is
    begin
        -- FSM state register: sync RESET on 'reset', and sync PRESET on error_i
        if clk_i'event and clk_i = '1' then
            if reset = '1' then
                -- all registered values are reset on master clear
                hash_control_st_reg <= st_reset;
            elsif core_error = '1' then
                -- error latch: lock on the error state
                hash_control_st_reg <= st_error;
            elsif ce_i = '1' then
                -- all registered values are held on master clock enable
                hash_control_st_reg <= hash_control_st_next;
            end if;
        end if;
        -- SHA256 registers, RESET on 'sha_init'
        if clk_i'event and clk_i = '1' then
            if sha_init = '1' then
                -- all SHA256 registered values are reset on SHA master clear
                sha_last_blk_reg <= '0';
                padding_reg <= '0';
            elsif ce_i = '1' then
                -- all registered values are held on master clock enable
                sha_last_blk_reg <= sha_last_blk_next;
                padding_reg <= padding_next;
            end if;
        end if;
    end process control_fsm_proc;

    -- bit counter register transfer logic
    bit_counter_proc: process (clk_i) is
    begin
        -- bit counter
        if clk_i'event and clk_i = '1' then
            if sha_init = '1' then
                msg_bit_cnt_reg <= (others => '0');
            elsif ce_i = '1' and msg_bit_cnt_ce = '1' then
                msg_bit_cnt_reg <= msg_bit_cnt_next;
            end if;
        end if;
    end process bit_counter_proc;

    -- state counter register transfer process
    state_counter_proc: process (clk_i) is
    begin
        -- core state counter
        if clk_i'event and clk_i = '1' then
            if (sha_init = '1') or (st_cnt_clr = '1') then
                st_cnt_reg <= (others => '0');
            elsif (ce_i = '1') and (st_cnt_ce = '1') then
                st_cnt_reg <= st_cnt_next;
            end if;
        end if;
    end process state_counter_proc;
    
    -- one-padding register transfer logic
    pad_one_fsm_proc: process (clk_i) is
    begin
        if clk_i'event and clk_i = '1' then
            if sha_init = '1' then
                -- all registered values are reset on master clear
                pad_one_reg <= '1';
            elsif (ce_i = '1') and (sch_ce = '1') then
                -- one-padding register is clocked synchronous with the message schedule
                pad_one_reg <= pad_one_next;
            end if;
        end if;
    end process pad_one_fsm_proc;

    --=============================================================================================
    --  COMBINATIONAL NEXT-STATE LOGIC
    --=============================================================================================
    -- State and control path combinational logic
    -- The hash_control_st_reg state register controls the SHA256 algorithm.
    control_combi_proc : process (  hash_control_st_reg, sha_last_blk_reg, padding_reg, wait_run_ce, 
                                    end_i, st_cnt_reg, sha_last_blk_next, one_insert, sha_reset ) is
    begin
        -- default logic that applies to all states at each fsm clock --

        -- assign default values to all unchanging combinational outputs (avoid latches)
        hash_control_st_next <= hash_control_st_reg;
        sha_last_blk_next <= sha_last_blk_reg;
        padding_next <= padding_reg;
        -- handshaking
        sha_init <= '0';
        error_lock <= '0';
        di_wr_window <= '0';        
        words_sel <= b"00";
        data_valid <= '0';
        di_req <= '0';              -- data request only during data input
        -- state counter
        st_cnt_clr <= '0';          -- only clear the state counter at the beginning of each block
        st_cnt_ce <= '0';
        -- message scheduler
        sch_ld <= '1';              -- enable pass-thru input through message schedule
        sch_ce <= '0';              -- stop message schedule clock
        -- hash core
        core_ld <= '0';             -- enable internal hash core logic
        core_ce <= '0';             -- core computation enabled only for data input and processing
        -- output registers
        oregs_ld <= '0';            -- defaults for accumulate blk hash
        oregs_ce <= '0';            -- only register init values and end of computation
        case hash_control_st_reg is
        
            when st_reset =>                -- master reset: starts a new hash/hmac processing
                -- moore outputs
                sha_init <= '1';            -- reset SHA256 engine
                oregs_ld <= '1';            -- load initial hash values
                oregs_ce <= '1';            -- latch initial hash values into output registers
                core_ld <= '1';             -- load initial value into core registers
                core_ce <= '1';             -- latch initial value into core registers
                st_cnt_clr <= '1';          -- reset state counter
                di_wr_window <= '1';        -- enable data write window                
                -- next state
                hash_control_st_next <= st_sha_data_input;

            when st_sha_data_input =>       -- message data words are clocked into the processor
                -- moore outputs
                di_req <= '1';              -- request message data
                di_wr_window <= '1';        -- enable data write window                
                sch_ce <= wait_run_ce;      -- hold the message scheduler with data hold
                st_cnt_ce <= wait_run_ce;   -- hold state count with data hold
                core_ce <= wait_run_ce;     -- hold processing clock with data hold
                -- next state
                if wait_run_ce = '1' then
                    if end_i = '1' then 
                        hash_control_st_next <= st_sha_padding;     -- pad incomplete blocks
                    elsif st_cnt_reg = 15 then
                        hash_control_st_next <= st_sha_blk_process; -- process one more block
                    end if;
                end if;

            when st_sha_blk_process =>      -- internal block hash processing
                -- moore outputs
                st_cnt_ce <= '1';           -- enable state counter
                sch_ld <= '0';              -- recirculate scheduler data
                sch_ce <= '1';              -- enable message scheduler clock
                core_ce <= '1';             -- enable processing clock
                -- next state
                if st_cnt_reg = 63 then
                    hash_control_st_next <= st_sha_blk_nxt;
                end if;

            when st_sha_blk_nxt =>          -- prepare for next block
                -- moore outputs
                st_cnt_clr <= '1';          -- reset state counter at the beginning of each block
                sch_ce <= '0';              -- stop the message schedule
                core_ld <= '1';             -- load result value into core registers
                core_ce <= '1';             -- latch result value into core registers
                oregs_ce <= '1';            -- latch core result into regs accumulator
                -- next state
                if sha_last_blk_reg = '1' then
                    hash_control_st_next <= st_sha_data_valid;  -- no hmac operation: publish data valid
                elsif padding_reg = '1' then
                    hash_control_st_next <= st_sha_padding;     -- additional padding block
                else
                    hash_control_st_next <= st_sha_data_input;  -- continue requesting input data
                end if;
            
            when st_sha_padding =>          -- padding of bits on the last message block
                -- moore outputs                
                padding_next <= '1';
                if st_cnt_reg = 16 then     -- if word 16, data block was full: proceed to process this block
                    -- process state #16 in this cycle and proceed to process the rest of the block
                    st_cnt_ce <= '1';           -- enable state counter
                    sch_ld <= '0';              -- recirculate scheduler data
                    sch_ce <= '1';              -- enable message scheduler clock
                    core_ce <= '1';             -- enable processing clock
                    -- next state
                    hash_control_st_next <= st_sha_blk_process;
                else                        -- incomplete block: pad words until data block completes
                    sch_ld <= '1';          -- load padded data into scheduler
                    sch_ce <= '1';          -- enable message scheduler clock
                    core_ce <= '1';         -- enable processing clock
                    st_cnt_ce <= '1';       -- enable state counter
                    if st_cnt_reg = 15 then -- pad up to word 15
                        if sha_last_blk_next = '1' then
                            words_sel <= b"10";  -- insert bitlen lo
                        end if;
                        -- next state
                        hash_control_st_next <= st_sha_blk_process;
                    elsif (one_insert = '0') and (st_cnt_reg = 14) then
                        words_sel <= b"01";     -- insert bitlen hi
                        sha_last_blk_next <= '1';   -- mark this as the last block
                    elsif st_cnt_reg = 13 then
                        sha_last_blk_next <= '1';   -- mark this as the last block
                    end if;
                end if;

            when st_sha_data_valid =>       -- process is finished, waiting for begin command
                -- moore outputs
                data_valid <= '1';          -- output results are valid
                -- wait for core reset with 'start'               

            when st_error =>                -- processing or input error: reset with 'reset' = 1
                -- moore outputs
                error_lock <= '1';          -- lock error state
                st_cnt_clr <= '1';          -- clear state counter
                -- wait for core reset with 'start'               

            when others =>                  -- internal state machine error
                -- next state
                hash_control_st_next <= st_error;

        end case; 
    end process control_combi_proc;

    --=============================================================================================
    --  COMBINATIONAL CONTROL LOGIC
    --=============================================================================================

    -- controller RESET signal logic
    sha_reset_combi_proc:   sha_reset <= '1' when start_i = '1'   else '0';
    reset_combi_proc:       reset <= '1'     when sha_reset = '1' else '0';

    -- pad-one flag register
    pad_one_next_combi_proc: process (bytes_ena, sch_ld, pad_one_reg) is
    begin
        -- after one-insertion, clear the pad-one flag register 
        if (bytes_ena /= b"1111") and (sch_ld = '1') then
            pad_one_next <= '0';
        else 
            pad_one_next <= pad_one_reg;
        end if;
    end process pad_one_next_combi_proc;

    -- padding byte lane selectors
    bytes_ena_combi_proc: process (bytes_i, padding_next, di_req, one_insert, end_i) is
    begin
        if di_req = '1' and end_i /= '1' then
            -- accept only full words before last word
            bytes_ena <= b"1111";
        elsif di_req = '1' and end_i = '1' then
            -- user data: bytes controlled by 'bytes_i'
            case bytes_i is
                when b"01"  => bytes_ena <= b"0001";
                when b"10"  => bytes_ena <= b"0011";
                when b"11"  => bytes_ena <= b"0111";
                when others => bytes_ena <= b"1111";
            end case;
        else
            -- no data input: force zero bits valid
            bytes_ena <= b"0000";
        end if;
    end process bytes_ena_combi_proc;

    -- bit counter next logic
    msg_bit_cnt_next_combi_proc: process (bytes_ena, msg_bit_cnt_reg, bits_to_add) is
    begin
        case bytes_ena is
            when b"0001"    => bits_to_add <= to_unsigned( 8, 6);
            when b"0011"    => bits_to_add <= to_unsigned(16, 6);
            when b"0111"    => bits_to_add <= to_unsigned(24, 6);
            when b"1111"    => bits_to_add <= to_unsigned(32, 6);
            when others     => bits_to_add <= to_unsigned( 0, 6);
        end case;
        msg_bit_cnt_next <= msg_bit_cnt_reg + bits_to_add;
    end process msg_bit_cnt_next_combi_proc;

    -- data input wait/run: insert wait states during data input for 'wr_i' = '0'
    wait_run_ce_proc:       wait_run_ce <= '1' when di_req = '1' and wr_i  = '1' else '0';

    -- padding one-insertion control
    one_insert_proc:        one_insert <= '1' when pad_one_reg = '1' else '0';

    -- bit counter clock enable
    msg_bit_cnt_ce_proc :   msg_bit_cnt_ce <= '1' when wait_run_ce = '1' else '0';

    -- state counter next logic
    st_cnt_next_proc:       st_cnt_next <= st_cnt_reg + 1;

    -- bytes_i error logic
    bytes_error_proc:       bytes_error <= '1' when bytes_i /= b"00" and end_i /= '1' and di_req = '1' and wr_i = '1' else '0';

    -- data input error logic
    data_input_error_proc:  data_input_error <= '1' when wr_i = '1' and di_wr_window /= '1' else '0';

    -- error detection logic
    core_error_combi_proc:  core_error <= '1' when error_i = '1' or error_lock = '1' or bytes_error = '1' or data_input_error = '1' else '0';
    
    --=============================================================================================
    --  OUTPUT LOGIC PROCESSES
    --=============================================================================================
    
    bitlen_o_proc :         bitlen_o        <= std_logic_vector(msg_bit_cnt_reg);
    bytes_ena_o_proc :      bytes_ena_o     <= bytes_ena;
    one_insert_o_proc :     one_insert_o    <= one_insert;
    words_sel_o_proc :      words_sel_o     <= words_sel;
    sch_ce_o_proc :         sch_ce_o        <= sch_ce;
    sch_ld_o_proc :         sch_ld_o        <= sch_ld;
    core_ce_o_proc :        core_ce_o       <= core_ce;
    core_ld_o_proc :        core_ld_o       <= core_ld;
    oregs_ce_o_proc :       oregs_ce_o      <= oregs_ce;
    oregs_ld_o_proc :       oregs_ld_o      <= oregs_ld;
    Kt_addr_o_proc :        Kt_addr_o       <= std_logic_vector(st_cnt_reg(5 downto 0));
    di_req_o_proc :         di_req_o        <= di_req;
    data_valid_o_proc :     data_valid_o    <= data_valid;
    error_o_proc :          error_o         <= core_error;
    
end rtl;

