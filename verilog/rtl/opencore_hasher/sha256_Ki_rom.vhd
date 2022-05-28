-----------------------------------------------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com, jonnydoin@gridvortex.com
-- 
-- Create Date:     09:56:30 05/06/2016  
-- Module Name:     sha256_Ki_rom
-- Project Name:    sha256 processor
-- Target Devices:  Spartan-6
-- Tool versions:   ISE 14.7
-- Description: 
--
--      Initial values for the hash result registers.
--      This module is modelled as a fixed value function.
--      It can be implemented as a local constant fixed value.
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

entity sha256_ki_rom is
    port (  
        K0_o : out std_logic_vector (31 downto 0) := (others => 'U');
        K1_o : out std_logic_vector (31 downto 0) := (others => 'U');
        K2_o : out std_logic_vector (31 downto 0) := (others => 'U');
        K3_o : out std_logic_vector (31 downto 0) := (others => 'U');
        K4_o : out std_logic_vector (31 downto 0) := (others => 'U');
        K5_o : out std_logic_vector (31 downto 0) := (others => 'U');
        K6_o : out std_logic_vector (31 downto 0) := (others => 'U');
        K7_o : out std_logic_vector (31 downto 0) := (others => 'U')
    );                      
end sha256_ki_rom;

architecture behavioral of sha256_ki_rom is
begin
    --=============================================================================================
    -- CONSTANTS FOR Ki VALUES
    --=============================================================================================
    K0_o_proc:      K0_o <= x"6A09E667";
    K1_o_proc:      K1_o <= x"BB67AE85";
    K2_o_proc:      K2_o <= x"3C6EF372";
    K3_o_proc:      K3_o <= x"A54FF53A";
    K4_o_proc:      K4_o <= x"510E527F";
    K5_o_proc:      K5_o <= x"9B05688C";
    K6_o_proc:      K6_o <= x"1F83D9AB";
    K7_o_proc:      K7_o <= x"5BE0CD19";

end behavioral;

