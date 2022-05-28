-----------------------------------------------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com, jonnydoin@gridvortex.com
-- 
-- Create Date:     09:56:30 05/06/2016  
-- Module Name:     sha256_msg_sch - RTL
-- Project Name:    sha256 processor
-- Target Devices:  Spartan-6
-- Tool versions:   ISE 14.7
-- Description: 
--
--      This is the message scheduler datapath for the sha256 processor.
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
-- 2016/06/06   v0.01.0100  [JD]    first simulation verification against NIST-FIPS-180-4 test vectors passed.
--
-----------------------------------------------------------------------------------------------------------------------
--  TODO
--  ====
--
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sha256_msg_sch is
    port (  
        clk_i : in std_logic := 'U';                                            -- system clock
        ce_i : in std_logic := 'U';                                             -- clock input to word shifter
        ld_i : in std_logic := 'U';                                             -- transparent load input to output
        M_i : in std_logic_vector (31 downto 0) := (others => 'U');             -- big endian input message words
        Wt_o : out std_logic_vector (31 downto 0)                               -- message schedule output words
    );                      
end sha256_msg_sch;

architecture rtl of sha256_msg_sch is
    -- datapath pipeline 
    signal r0 : unsigned (31 downto 0) := (others => '0');              -- internal message register
    signal r1 : unsigned (31 downto 0) := (others => '0');              -- internal message register
    signal r2 : unsigned (31 downto 0) := (others => '0');              -- internal message register
    signal r3 : unsigned (31 downto 0) := (others => '0');              -- internal message register
    signal r4 : unsigned (31 downto 0) := (others => '0');              -- internal message register
    signal r5 : unsigned (31 downto 0) := (others => '0');              -- internal message register
    signal r6 : unsigned (31 downto 0) := (others => '0');              -- internal message register
    signal r7 : unsigned (31 downto 0) := (others => '0');              -- internal message register
    signal r8 : unsigned (31 downto 0) := (others => '0');              -- internal message register
    signal r9 : unsigned (31 downto 0) := (others => '0');              -- internal message register
    signal r10 : unsigned (31 downto 0) := (others => '0');             -- internal message register
    signal r11 : unsigned (31 downto 0) := (others => '0');             -- internal message register
    signal r12 : unsigned (31 downto 0) := (others => '0');             -- internal message register
    signal r13 : unsigned (31 downto 0) := (others => '0');             -- internal message register
    signal r14 : unsigned (31 downto 0) := (others => '0');             -- internal message register
    signal r15 : unsigned (31 downto 0) := (others => '0');             -- internal message register
    -- input mux feedback
    signal next_M : unsigned (31 downto 0);                             -- sum feedback
    -- word shifter wires
    signal next_r0 : unsigned (31 downto 0);
    signal next_r1 : unsigned (31 downto 0);
    signal next_r2 : unsigned (31 downto 0);
    signal next_r3 : unsigned (31 downto 0);
    signal next_r4 : unsigned (31 downto 0);
    signal next_r5 : unsigned (31 downto 0);
    signal next_r6 : unsigned (31 downto 0);
    signal next_r7 : unsigned (31 downto 0);
    signal next_r8 : unsigned (31 downto 0);
    signal next_r9 : unsigned (31 downto 0);
    signal next_r10 : unsigned (31 downto 0);
    signal next_r11 : unsigned (31 downto 0);
    signal next_r12 : unsigned (31 downto 0);
    signal next_r13 : unsigned (31 downto 0);
    signal next_r14 : unsigned (31 downto 0);
    signal next_r15 : unsigned (31 downto 0);
    -- internal modulo adders
    signal sum0 : unsigned (31 downto 0);               -- modulo adder r1 + sum1
    signal sum1 : unsigned (31 downto 0);               -- modulo adder s0 + sum2
    signal sum2 : unsigned (31 downto 0);               -- modulo adder s1 + r10
    -- lower sigma functions
    signal s0 : unsigned (31 downto 0);                 -- lower sigma0 function
    signal s1 : unsigned (31 downto 0);                 -- lower sigma1 function
begin
    --=============================================================================================
    -- MESSAGE SCHEDULER LOGIC
    --=============================================================================================
    -- This logic implements the 256 bytes message schedule as a folded 16 word circular word shifter.
    -- The Add-Rotate-Xor functions s0 and s1 are implemented and fed back to the word shifter.
    -- To avoid a datapath pipeline delay insertion, the output is taken from the r0 input, rather than
    -- the registered r0 output. This lookahead reduces one clock cycle in the overall hash computation,
    -- but increases the combinational path from the input to the processor core.
    -- The next_r0 combinational function has 5 layers of logic, including 3 carry chains.
    
    -- word shifter register transfer logic
    word_shifter_proc: process (clk_i, ce_i) is
    begin
        if clk_i'event and clk_i = '1' then
            if ce_i = '1' then
                r0 <= next_r0;
                r1 <= next_r1;
                r2 <= next_r2;
                r3 <= next_r3;
                r4 <= next_r4;
                r5 <= next_r5;
                r6 <= next_r6;
                r7 <= next_r7;
                r8 <= next_r8;
                r9 <= next_r9;
                r10 <= next_r10;
                r11 <= next_r11;
                r12 <= next_r12;
                r13 <= next_r13;
                r14 <= next_r14;
                r15 <= next_r15;
            end if;
        end if;
    end process word_shifter_proc;
    
    -- input mux 
    next_r0_proc: next_r0 <= unsigned(M_i) when ld_i = '1' else next_M;
    next_m_proc:  next_M <= sum0;
    
    -- word shifter wires
    next_r15_proc: next_r15 <= r0;
    next_r14_proc: next_r14 <= r15;
    next_r13_proc: next_r13 <= r14;
    next_r12_proc: next_r12 <= r13;
    next_r11_proc: next_r11 <= r12;
    next_r10_proc: next_r10 <= r11;
    next_r9_proc: next_r9 <= r10;
    next_r8_proc: next_r8 <= r9;
    next_r7_proc: next_r7 <= r8;
    next_r6_proc: next_r6 <= r7;
    next_r5_proc: next_r5 <= r6;
    next_r4_proc: next_r4 <= r5;
    next_r3_proc: next_r3 <= r4;
    next_r2_proc: next_r2 <= r3;
    next_r1_proc: next_r1 <= r2;
    
    -- adders 
    sum0_proc: sum0 <= sum1 + r1;
    sum1_proc: sum1 <= sum2 + s0;
    sum2_proc: sum2 <= r10 + s1;
    
    -- lower sigma functions
    s0_proc: s0 <= (B"000" & r2(31 downto 3)) xor (r2(17 downto 0) & r2(31 downto 18)) xor (r2(6 downto 0) & r2(31 downto 7));
    s1_proc: s1 <= (B"0000000000" & r15(31 downto 10)) xor (r15(18 downto 0) & r15(31 downto 19)) xor (r15(16 downto 0) & r15(31 downto 17));
    
    --=============================================================================================
    -- OUTPUT LOGIC
    --=============================================================================================
    -- connect output ports
    Wt_o_proc:      Wt_o <= std_logic_vector(next_r0);  -- message scheduler output look ahead
end rtl;

