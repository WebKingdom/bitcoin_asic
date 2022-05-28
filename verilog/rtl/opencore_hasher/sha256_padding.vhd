-----------------------------------------------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com, jonnydoin@gridvortex.com
-- 
-- Create Date:     09:56:30 05/04/2016
-- Module Name:     sha256_padding - RTL
-- Project Name:    sha256 processor
-- Target Devices:  Spartan-6
-- Tool versions:   ISE 14.7
-- Description: 
--
--      This is the byte padding datapath logic for the sha256 processor. 
--      The padding of the last block is controlled by the byte lane selectors and the last words selectors.
--      These control signals are generated at the Control Logic block of the SHA256 processor. 
--      A consistency check error signal is generated, to flag illegal control conditions.
--      This block is a fully combinational circuit, with 2 layers of logic. 
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


entity sha256_padding is
    port (
        words_sel_i : in std_logic_vector (1 downto 0) := (others => 'U');      -- selector for bitcnt insertion at the last block
        one_insert_i : in std_logic;                                            -- insert a leading one in the padding
        bytes_ena_i : in std_logic_vector (3 downto 0) := (others => 'U');      -- byte lane selector lines
        bitlen_i : in std_logic_vector (63 downto 0) := (others => 'U');        -- 64bit message bit length
        di_i : in std_logic_vector (31 downto 0) := (others => 'U');            -- big endian input message words
        do_o : out std_logic_vector (31 downto 0);                              -- padded output words
        error_o : out std_logic                                                 -- '1' if error in the byte_ena selectors
    );
end sha256_padding;

architecture rtl of sha256_padding is
    -- byte lane wires 
    signal BL0 : std_logic_vector (7 downto 0);                                 -- byte lane 0 (MSB)
    signal BL1 : std_logic_vector (7 downto 0);                                 -- byte lane 1 (1SB)
    signal BL2 : std_logic_vector (7 downto 0);                                 -- byte lane 2 (2SB)
    signal BL3 : std_logic_vector (7 downto 0);                                 -- byte lane 3 (LSB)
    -- selectors
    signal one_insert : std_logic;                                              -- leading one padding
    signal B_ena : std_logic_vector (3 downto 0);                               -- byte lane selectors
    signal W_sel : std_logic_vector (1 downto 0);                               -- last words selector
    -- padded words
    signal W_pad : std_logic_vector (31 downto 0);                              -- padding mux output
    signal W_out : std_logic_vector (31 downto 0);                              -- output word
    -- ones insertion muxes
    signal BL0_top_bit : std_logic;
    signal BL1_top_bit : std_logic;
    signal BL2_top_bit : std_logic;
    signal BL3_top_bit : std_logic;
    -- bit length words
    signal bitlen_hi : std_logic_vector (31 downto 0);
    signal bitlen_lo : std_logic_vector (31 downto 0);
    -- error indication
    signal bsel_error : std_logic;
    signal wsel_error : std_logic;
    signal err : std_logic;
begin
    --=============================================================================================
    -- INPUT LOGIC
    --=============================================================================================
    -- copy the input ports into the internal wires
    
    -- byte lanes are internally spliced from the 32bit input word
    BL0 <= di_i(31 downto 24);
    BL1 <= di_i(23 downto 16);
    BL2 <= di_i(15 downto 8);
    BL3 <= di_i(7 downto 0);
    
    -- bitlen words spliced from the 64bit bitlen input word
    bitlen_hi <= bitlen_i(63 downto 32);
    bitlen_lo <= bitlen_i(31 downto 0);
    
    -- byte lane selectors
    one_insert <= one_insert_i;
    B_ena <= bytes_ena_i;
    W_sel <= words_sel_i;
    
    --=============================================================================================
    -- PADDING LOGIC
    --=============================================================================================
    -- The last block padding logic is implemented as a stream insertion into the input words datapath.
    
    -- top bit for the padding bytes. one_insert controls whether a leading one will be inserted on the leading pad byte.
    BL0_top_bit <= one_insert and (not B_ena(0));
    BL1_top_bit <= one_insert and (B_ena(0) and not B_ena(1));
    BL2_top_bit <= one_insert and (B_ena(1) and not B_ena(2));
    BL3_top_bit <= one_insert and (B_ena(2) and not B_ena(3));
    
    -- byte lane padding muxes
    W_pad(31 downto 24) <= BL0 when B_ena(0) = '1' else (BL0_top_bit & b"0000000");
    W_pad(23 downto 16) <= BL1 when B_ena(1) = '1' else (BL1_top_bit & b"0000000");
    W_pad(15 downto 8)  <= BL2 when B_ena(2) = '1' else (BL2_top_bit & b"0000000");
    W_pad(7 downto 0)   <= BL3 when B_ena(3) = '1' else (BL3_top_bit & b"0000000");
    
    --=============================================================================================
    -- BIT COUNTER INSERTION LOGIC
    --=============================================================================================
    -- At the end of the last block, the 64bit message length is inserted as the last 2 words.
    
    W_out <=    bitlen_hi   when W_sel = b"01" else
                bitlen_lo   when W_sel = b"10" else
                W_pad;
    
    --=============================================================================================
    -- ERROR INDICATION LOGIC
    --=============================================================================================
    -- Invalid selectors conditions are flagged as errors
    
    -- byte lane selectors error: priority encoder
    bsel_error <=   '1' when (B_ena(3) = '1') and ((B_ena(2) = '0') or (B_ena(1) = '0') or (B_ena(0) = '0')) else
                    '1' when (B_ena(2) = '1') and ((B_ena(1) = '0') or (B_ena(0) = '0')) else
                    '1' when (B_ena(1) = '1') and  (B_ena(0) = '0') else
                    '0';
                    
    -- word selector error: invalid code B"11"
    wsel_error <=   '1' when W_sel = b"11" else '0';
    
    err <= bsel_error or wsel_error;
    
    --=============================================================================================
    -- OUTPUT LOGIC
    --=============================================================================================
    -- connect output ports
    do_o_proc:      do_o <= W_out;
    error_o_proc:   error_o <= err;
end rtl;

