-----------------------------------------------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com, jonnydoin@gridvortex.com
-- 
-- Create Date:     09:56:30 05/06/2016  
-- Module Name:     sha256_hash_core - RTL
-- Project Name:    sha256 processor
-- Target Devices:  Spartan-6
-- Tool versions:   ISE 14.7
-- Description: 
--
--      This is the 256bit single-cycle hash core processing logic for each of the 64 block steps. 
--      The combinational depth of this block is 8 layers of logic and adders.
--      This module will be the largest limitation of the synthesis top operating frequency.
--      If extra pipelining is needed, the control logic must account for the extra clock delays.
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
-- 2016/06/05   v0.01.0095  [JD]    failed verification. misalignment of words in the datapath. 
-- 2016/06/06   v0.01.0100  [JD]    passed first simulation verification against NIST-FIPS-180-4 test vectors.
-- 2016/06/06   v0.01.0100  [JD]    passed first simulation verification against NIST-FIPS-180-4 test vectors.
-- 2016/06/07   v0.01.0105  [JD]    passed verification against all NIST-FIPS-180-4 test vectors.
-- 2016/06/11   v0.01.0105  [JD]    passed verification against NIST-SHA2_Additional test vectors #1 to #10.
--
-----------------------------------------------------------------------------------------------------------------------
--  TODO
--  ====
--
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sha256_hash_core is
    port (  
        clk_i : in std_logic := 'U';                                    -- system clock
        ce_i : in std_logic := 'U';                                     -- clock enable from control logic
        ld_i : in std_logic := 'U';                                     -- parallel load internal registers with input words
        A_i : in std_logic_vector (31 downto 0) := (others => 'U');     -- input for reg A
        B_i : in std_logic_vector (31 downto 0) := (others => 'U');     -- input for reg B
        C_i : in std_logic_vector (31 downto 0) := (others => 'U');     -- input for reg C
        D_i : in std_logic_vector (31 downto 0) := (others => 'U');     -- input for reg D
        E_i : in std_logic_vector (31 downto 0) := (others => 'U');     -- input for reg E
        F_i : in std_logic_vector (31 downto 0) := (others => 'U');     -- input for reg F
        G_i : in std_logic_vector (31 downto 0) := (others => 'U');     -- input for reg G
        H_i : in std_logic_vector (31 downto 0) := (others => 'U');     -- input for reg H
        A_o : out std_logic_vector (31 downto 0) := (others => 'U');    -- output for reg A
        B_o : out std_logic_vector (31 downto 0) := (others => 'U');    -- output for reg B
        C_o : out std_logic_vector (31 downto 0) := (others => 'U');    -- output for reg C
        D_o : out std_logic_vector (31 downto 0) := (others => 'U');    -- output for reg D
        E_o : out std_logic_vector (31 downto 0) := (others => 'U');    -- output for reg E
        F_o : out std_logic_vector (31 downto 0) := (others => 'U');    -- output for reg F
        G_o : out std_logic_vector (31 downto 0) := (others => 'U');    -- output for reg G
        H_o : out std_logic_vector (31 downto 0) := (others => 'U');    -- output for reg H
        Kt_i : in std_logic_vector (31 downto 0) := (others => 'U');    -- coefficients for the 64 steps of the message schedule
        Wt_i : in std_logic_vector (31 downto 0) := (others => 'U')     -- message schedule words for the 64 steps
    );                      
end sha256_hash_core;

architecture rtl of sha256_hash_core is
    -- core registers
    signal reg_a : unsigned (31 downto 0) := (others => '0');
    signal reg_b : unsigned (31 downto 0) := (others => '0');
    signal reg_c : unsigned (31 downto 0) := (others => '0');
    signal reg_d : unsigned (31 downto 0) := (others => '0');
    signal reg_e : unsigned (31 downto 0) := (others => '0');
    signal reg_f : unsigned (31 downto 0) := (others => '0');
    signal reg_g : unsigned (31 downto 0) := (others => '0');
    signal reg_h : unsigned (31 downto 0) := (others => '0');
    -- combinational inputs
    signal next_reg_a : unsigned (31 downto 0);
    signal next_reg_b : unsigned (31 downto 0);
    signal next_reg_c : unsigned (31 downto 0);
    signal next_reg_d : unsigned (31 downto 0);
    signal next_reg_e : unsigned (31 downto 0);
    signal next_reg_f : unsigned (31 downto 0);
    signal next_reg_g : unsigned (31 downto 0);
    signal next_reg_h : unsigned (31 downto 0);
    -- internal modulo adders
    signal sum0 : unsigned (31 downto 0);
    signal sum1 : unsigned (31 downto 0);
    signal sum2 : unsigned (31 downto 0);
    signal sum3 : unsigned (31 downto 0);
    signal sum4 : unsigned (31 downto 0);
    signal sum5 : unsigned (31 downto 0);
    signal sum6 : unsigned (31 downto 0);
    -- upper sigma functions
    signal SIG0 : unsigned (31 downto 0);
    signal SIG1 : unsigned (31 downto 0);
    -- Ch and Maj functions
    signal Ch : unsigned (31 downto 0);
    signal Maj : unsigned (31 downto 0);
begin
    --=============================================================================================
    -- HASH BLOCK CORE LOGIC
    --=============================================================================================
    -- The hash core block implements the hash kernel operation that is used in each of the 64 block hash steps. 
    -- All operations for a kernel step execute in a single clock cycle.
    -- The longest combinational path is the 'next_reg_a', with 12 logic layers total, including the upstream 
    -- datapath from the message scheduler. 
    
    -- core register transfer logic
    core_regs_proc: process (clk_i, ce_i) is
    begin
        if clk_i'event and clk_i = '1' then
            if ce_i = '1' then
                reg_a <= next_reg_a;
                reg_b <= next_reg_b;
                reg_c <= next_reg_c;
                reg_d <= next_reg_d;
                reg_e <= next_reg_e;
                reg_f <= next_reg_f;
                reg_g <= next_reg_g;
                reg_h <= next_reg_h;
            end if;
        end if;
    end process core_regs_proc;

    --=============================================================================================
    --  COMBINATIONAL LOGIC
    --=============================================================================================
    -- word rotation and bit manipulation for each cycle
    
    -- input muxes and word shifter wires
    next_reg_a_proc: next_reg_a <= unsigned(A_i) when ld_i = '1' else sum0;
    next_reg_b_proc: next_reg_b <= unsigned(B_i) when ld_i = '1' else reg_a;
    next_reg_c_proc: next_reg_c <= unsigned(C_i) when ld_i = '1' else reg_b;
    next_reg_d_proc: next_reg_d <= unsigned(D_i) when ld_i = '1' else reg_c;
    next_reg_e_proc: next_reg_e <= unsigned(E_i) when ld_i = '1' else sum2;
    next_reg_f_proc: next_reg_f <= unsigned(F_i) when ld_i = '1' else reg_e;
    next_reg_g_proc: next_reg_g <= unsigned(G_i) when ld_i = '1' else reg_f;
    next_reg_h_proc: next_reg_h <= unsigned(H_i) when ld_i = '1' else reg_g;
    
    -- adders for the ARX functions
    sum0_proc: sum0 <= sum1 + sum3;
    sum1_proc: sum1 <= SIG0 + Maj;
    sum2_proc: sum2 <= sum3 + reg_d;
    sum3_proc: sum3 <= sum4 + SIG1;
    sum4_proc: sum4 <= sum5 + unsigned(Wt_i);
    sum5_proc: sum5 <= sum6 + unsigned(Kt_i);
    sum6_proc: sum6 <= reg_h + Ch;
    
    -- upper sigma functions
    SIG0_proc: SIG0 <= (reg_a(1 downto 0) & reg_a(31 downto 2)) xor (reg_a(12 downto 0) & reg_a(31 downto 13)) xor (reg_a(21 downto 0) & reg_a(31 downto 22));
    SIG1_proc: SIG1 <= (reg_e(5 downto 0) & reg_e(31 downto 6)) xor (reg_e(10 downto 0) & reg_e(31 downto 11)) xor (reg_e(24 downto 0) & reg_e(31 downto 25));
    
    -- Maj and Ch functions
    Maj_proc: Maj <= (reg_a and reg_b) xor (reg_a and reg_c) xor (reg_b and reg_c);
    Ch_proc:  Ch <= (reg_e and reg_f) xor ((not reg_e) and reg_g);
    
    --=============================================================================================
    -- OUTPUT LOGIC
    --=============================================================================================
    -- connect output ports
    A_o_proc:       A_o <= std_logic_vector(reg_a);
    B_o_proc:       B_o <= std_logic_vector(reg_b);
    C_o_proc:       C_o <= std_logic_vector(reg_c);
    D_o_proc:       D_o <= std_logic_vector(reg_d);
    E_o_proc:       E_o <= std_logic_vector(reg_e);
    F_o_proc:       F_o <= std_logic_vector(reg_f);
    G_o_proc:       G_o <= std_logic_vector(reg_g);
    H_o_proc:       H_o <= std_logic_vector(reg_h);
end rtl;

