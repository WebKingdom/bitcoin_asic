-----------------------------------------------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com, jonnydoin@gridvortex.com
-- 
-- Create Date:     09:56:30 05/06/2016  
-- Module Name:     sha256_kt_rom - RTL
-- Project Name:    sha256 processor
-- Target Devices:  Spartan-6
-- Tool versions:   ISE 14.7
-- Description: 
--
--      This is the 64 words coefficients rom for the block hash core.
--      It is modelled as an asynchronous addressable ROM memory.
--      Depending on the fabrication process and technology, this memory can be implemented
--      as a OTP, a MUX, a fixed LUT or a combinational function.
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
--
-----------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sha256_kt_rom is
    port (  
        addr_i : in std_logic_vector(5 downto 0) := (others => '0');    -- address of the Kt constant
        dout_o : out std_logic_vector(31 downto 0)                      -- output delayed one clock
    );                      
end sha256_kt_rom;

architecture behavioral of sha256_kt_rom is
    signal addr : integer range 0 to 63;
    signal next_rout : std_logic_vector (31 downto 0);
begin
    --=============================================================================================
    -- COEFFICIENTS ROM
    --=============================================================================================
    -- The coefficients for the block hash are synthesized as an unregistered 64x32bit ROM.
    
    addr <= to_integer(unsigned(addr_i));
    
    -- The ROM is a 5-bit select MUX
    next_rout <=    x"428a2f98" when addr =  0 else 
                    x"71374491" when addr =  1 else
                    x"b5c0fbcf" when addr =  2 else
                    x"e9b5dba5" when addr =  3 else
                    x"3956c25b" when addr =  4 else
                    x"59f111f1" when addr =  5 else
                    x"923f82a4" when addr =  6 else
                    x"ab1c5ed5" when addr =  7 else
                    x"d807aa98" when addr =  8 else
                    x"12835b01" when addr =  9 else
                    x"243185be" when addr = 10 else
                    x"550c7dc3" when addr = 11 else
                    x"72be5d74" when addr = 12 else
                    x"80deb1fe" when addr = 13 else
                    x"9bdc06a7" when addr = 14 else
                    x"c19bf174" when addr = 15 else
                    x"e49b69c1" when addr = 16 else
                    x"efbe4786" when addr = 17 else
                    x"0fc19dc6" when addr = 18 else
                    x"240ca1cc" when addr = 19 else
                    x"2de92c6f" when addr = 20 else
                    x"4a7484aa" when addr = 21 else
                    x"5cb0a9dc" when addr = 22 else
                    x"76f988da" when addr = 23 else
                    x"983e5152" when addr = 24 else
                    x"a831c66d" when addr = 25 else
                    x"b00327c8" when addr = 26 else
                    x"bf597fc7" when addr = 27 else
                    x"c6e00bf3" when addr = 28 else
                    x"d5a79147" when addr = 29 else
                    x"06ca6351" when addr = 30 else
                    x"14292967" when addr = 31 else
                    x"27b70a85" when addr = 32 else
                    x"2e1b2138" when addr = 33 else
                    x"4d2c6dfc" when addr = 34 else
                    x"53380d13" when addr = 35 else
                    x"650a7354" when addr = 36 else
                    x"766a0abb" when addr = 37 else
                    x"81c2c92e" when addr = 38 else
                    x"92722c85" when addr = 39 else
                    x"a2bfe8a1" when addr = 40 else
                    x"a81a664b" when addr = 41 else
                    x"c24b8b70" when addr = 42 else
                    x"c76c51a3" when addr = 43 else
                    x"d192e819" when addr = 44 else
                    x"d6990624" when addr = 45 else
                    x"f40e3585" when addr = 46 else
                    x"106aa070" when addr = 47 else
                    x"19a4c116" when addr = 48 else
                    x"1e376c08" when addr = 49 else
                    x"2748774c" when addr = 50 else
                    x"34b0bcb5" when addr = 51 else
                    x"391c0cb3" when addr = 52 else
                    x"4ed8aa4a" when addr = 53 else
                    x"5b9cca4f" when addr = 54 else
                    x"682e6ff3" when addr = 55 else
                    x"748f82ee" when addr = 56 else
                    x"78a5636f" when addr = 57 else
                    x"84c87814" when addr = 58 else
                    x"8cc70208" when addr = 59 else
                    x"90befffa" when addr = 60 else
                    x"a4506ceb" when addr = 61 else
                    x"bef9a3f7" when addr = 62 else
                    x"c67178f2";            
                                            
    --=============================================================================================
    -- OUTPUT LOGIC                         
    --=============================================================================================
    -- connect output port                  
                                            
    dout_o_proc:    dout_o <= next_rout;
    
end behavioral;


