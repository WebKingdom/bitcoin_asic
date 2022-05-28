-----------------------------------------------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com, jonnydoin@gridvortex.com
-- 
-- Create Date:     09:56:30 05/06/2016  
-- Module Name:     sha256_regs - RTL
-- Project Name:    sha256 processor
-- Target Devices:  Spartan-6
-- Tool versions:   ISE 14.7
-- Description: 
--
--      The regs block has the output result registers for the SHA256 processor.
--      It is a single-cycle 256bit Accumulator for the block hash results, and can be implemented
--      as a 32bit MUX and a 32bit carry chain for each register.
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

entity sha256_regs is
    port (  
        clk_i : in std_logic := 'U';                                            -- system clock
        ce_i : in std_logic := 'U';                                             -- clock enable from control logic
        ld_i : in std_logic := 'U';                                             -- internal mux selection from control logic
        A_i : in std_logic_vector (31 downto 0) := (others => 'U');
        B_i : in std_logic_vector (31 downto 0) := (others => 'U');
        C_i : in std_logic_vector (31 downto 0) := (others => 'U');
        D_i : in std_logic_vector (31 downto 0) := (others => 'U');
        E_i : in std_logic_vector (31 downto 0) := (others => 'U');
        F_i : in std_logic_vector (31 downto 0) := (others => 'U');
        G_i : in std_logic_vector (31 downto 0) := (others => 'U');
        H_i : in std_logic_vector (31 downto 0) := (others => 'U');
        K0_i : in std_logic_vector (31 downto 0) := (others => 'U');
        K1_i : in std_logic_vector (31 downto 0) := (others => 'U');
        K2_i : in std_logic_vector (31 downto 0) := (others => 'U');
        K3_i : in std_logic_vector (31 downto 0) := (others => 'U');
        K4_i : in std_logic_vector (31 downto 0) := (others => 'U');
        K5_i : in std_logic_vector (31 downto 0) := (others => 'U');
        K6_i : in std_logic_vector (31 downto 0) := (others => 'U');
        K7_i : in std_logic_vector (31 downto 0) := (others => 'U');
        N0_o : out std_logic_vector (31 downto 0) := (others => 'U');
        N1_o : out std_logic_vector (31 downto 0) := (others => 'U');
        N2_o : out std_logic_vector (31 downto 0) := (others => 'U');
        N3_o : out std_logic_vector (31 downto 0) := (others => 'U');
        N4_o : out std_logic_vector (31 downto 0) := (others => 'U');
        N5_o : out std_logic_vector (31 downto 0) := (others => 'U');
        N6_o : out std_logic_vector (31 downto 0) := (others => 'U');
        N7_o : out std_logic_vector (31 downto 0) := (others => 'U');
        H0_o : out std_logic_vector (31 downto 0) := (others => 'U');
        H1_o : out std_logic_vector (31 downto 0) := (others => 'U');
        H2_o : out std_logic_vector (31 downto 0) := (others => 'U');
        H3_o : out std_logic_vector (31 downto 0) := (others => 'U');
        H4_o : out std_logic_vector (31 downto 0) := (others => 'U');
        H5_o : out std_logic_vector (31 downto 0) := (others => 'U');
        H6_o : out std_logic_vector (31 downto 0) := (others => 'U');
        H7_o : out std_logic_vector (31 downto 0) := (others => 'U')
    );                      
end sha256_regs;

architecture rtl of sha256_regs is
    -- output result registers 
    signal reg_H0 : unsigned (31 downto 0) := (others => '0');
    signal reg_H1 : unsigned (31 downto 0) := (others => '0');
    signal reg_H2 : unsigned (31 downto 0) := (others => '0');
    signal reg_H3 : unsigned (31 downto 0) := (others => '0');
    signal reg_H4 : unsigned (31 downto 0) := (others => '0');
    signal reg_H5 : unsigned (31 downto 0) := (others => '0');
    signal reg_H6 : unsigned (31 downto 0) := (others => '0');
    signal reg_H7 : unsigned (31 downto 0) := (others => '0');
    -- word shifter wires
    signal next_reg_H0 : unsigned (31 downto 0);
    signal next_reg_H1 : unsigned (31 downto 0);
    signal next_reg_H2 : unsigned (31 downto 0);
    signal next_reg_H3 : unsigned (31 downto 0);
    signal next_reg_H4 : unsigned (31 downto 0);
    signal next_reg_H5 : unsigned (31 downto 0);
    signal next_reg_H6 : unsigned (31 downto 0);
    signal next_reg_H7 : unsigned (31 downto 0);
    -- internal modulo adders
    signal sum0 : unsigned (31 downto 0);
    signal sum1 : unsigned (31 downto 0);
    signal sum2 : unsigned (31 downto 0);
    signal sum3 : unsigned (31 downto 0);
    signal sum4 : unsigned (31 downto 0);
    signal sum5 : unsigned (31 downto 0);
    signal sum6 : unsigned (31 downto 0);
    signal sum7 : unsigned (31 downto 0);
begin
    --=============================================================================================
    -- OUTPUT RESULT REGISTERS LOGIC
    --=============================================================================================
    -- The output result registers hold the intermediate values for the hash update blocks, and also the final 256bit hash value. 
    --
    
    -- output register transfer logic
    out_regs_proc: process (clk_i, ce_i) is
    begin
        if clk_i'event and clk_i = '1' then
            if ce_i = '1' then
                reg_H0 <= next_reg_H0;
                reg_H1 <= next_reg_H1;
                reg_H2 <= next_reg_H2;
                reg_H3 <= next_reg_H3;
                reg_H4 <= next_reg_H4;
                reg_H5 <= next_reg_H5;
                reg_H6 <= next_reg_H6;
                reg_H7 <= next_reg_H7;
            end if;
        end if;
    end process out_regs_proc;
    
    -- input muxes
    next_reg_H0_proc: next_reg_H0 <= unsigned(K0_i) when ld_i = '1' else sum0;
    next_reg_H1_proc: next_reg_H1 <= unsigned(K1_i) when ld_i = '1' else sum1;
    next_reg_H2_proc: next_reg_H2 <= unsigned(K2_i) when ld_i = '1' else sum2;
    next_reg_H3_proc: next_reg_H3 <= unsigned(K3_i) when ld_i = '1' else sum3;
    next_reg_H4_proc: next_reg_H4 <= unsigned(K4_i) when ld_i = '1' else sum4;
    next_reg_H5_proc: next_reg_H5 <= unsigned(K5_i) when ld_i = '1' else sum5;
    next_reg_H6_proc: next_reg_H6 <= unsigned(K6_i) when ld_i = '1' else sum6;
    next_reg_H7_proc: next_reg_H7 <= unsigned(K7_i) when ld_i = '1' else sum7;
    
    -- adders 
    sum0_proc: sum0 <= reg_H0 + unsigned(A_i);
    sum1_proc: sum1 <= reg_H1 + unsigned(B_i);
    sum2_proc: sum2 <= reg_H2 + unsigned(C_i);
    sum3_proc: sum3 <= reg_H3 + unsigned(D_i);
    sum4_proc: sum4 <= reg_H4 + unsigned(E_i);
    sum5_proc: sum5 <= reg_H5 + unsigned(F_i);
    sum6_proc: sum6 <= reg_H6 + unsigned(G_i);
    sum7_proc: sum7 <= reg_H7 + unsigned(H_i);
    
    --=============================================================================================
    -- OUTPUT LOGIC
    --=============================================================================================
    -- connect output ports
    H0_o_proc:      H0_o <= std_logic_vector(reg_H0);
    H1_o_proc:      H1_o <= std_logic_vector(reg_H1);
    H2_o_proc:      H2_o <= std_logic_vector(reg_H2);
    H3_o_proc:      H3_o <= std_logic_vector(reg_H3);
    H4_o_proc:      H4_o <= std_logic_vector(reg_H4);
    H5_o_proc:      H5_o <= std_logic_vector(reg_H5);
    H6_o_proc:      H6_o <= std_logic_vector(reg_H6);
    H7_o_proc:      H7_o <= std_logic_vector(reg_H7);
    
    N0_o_proc:      N0_o <= std_logic_vector(next_reg_H0);
    N1_o_proc:      N1_o <= std_logic_vector(next_reg_H1);
    N2_o_proc:      N2_o <= std_logic_vector(next_reg_H2);
    N3_o_proc:      N3_o <= std_logic_vector(next_reg_H3);
    N4_o_proc:      N4_o <= std_logic_vector(next_reg_H4);
    N5_o_proc:      N5_o <= std_logic_vector(next_reg_H5);
    N6_o_proc:      N6_o <= std_logic_vector(next_reg_H6);
    N7_o_proc:      N7_o <= std_logic_vector(next_reg_H7);
end rtl;

