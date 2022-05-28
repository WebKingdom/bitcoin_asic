----------------------------------------------------------------------------------
-- Author:          Jonny Doin, jdoin@opencores.org, jonnydoin@gmail.com, jonnydoin@gridvortex.com
-- 
-- Create Date:     01:21:32 05/05/2016 
-- Design Name:     gv_sha256
-- Module Name:     GV_SHA256 toplevel
-- Project Name:    GV_SHA256 engine
-- Target Devices:  Spartan-6 LX45
-- Tool versions:   ISE 14.7
-- Description: 
--
--      This is the gv_sha256 engine top level.
--      The gv_sha256 is a stream hash engine, i.e., the data words are hashed as a stream of words read from an input bus, with
--      control inputs for BEGIN/END of the message data stream. The input bus is a 32bit word bus, with a byte lane selector to signalize
--      how many bytes are valid in the last word. 
--
--      The core is a structural integration of the logic blocks for the SHA256 engine, with the internal datapath and controlpath wires.
--
--      Written in synthesizable VHDL, the hash engine is a low resource, area-efficient implementation of the FIPS-180-4 SHA256 hash algorithm.
--      Designed around the core registers and combinational hash functions as a 768bit-wide engine, the engine takes 64+1 clocks to 
--      compute a hash block.
--
--      It is designed for stand-alone ASIC functions and 32-bit bus interfaces for generic processor integration.
--
--      The data input port is organized as a 32bit word write register, with flow control and begin/end signals.
--      The 256bit result register is organized as 8 x 32bit registers that can be read simultaneously.
--
--      This implementation is a conservative implementation of the approved FIPS-180-4 algorithm, with a fair compromise of resources, 
--      comprising of only 32 registers of 32bit words for the hash engine, with a single-cycle combinational logic for each algorithm step.
--      The combinational logic depth of the engine is 10 logic layers. For a process with 650ps of average (Tpd + Tsu), this core can
--      be synthesized to 75MHz system clock. 
--
--      The GV_SHA256 is a basic cryptographic block, used by almost all encryption and digital signature schemes. 
--
--      Applications include low-cost CyberPhysical Systems and also fast backend crypto functions for realtime hashing of packet data.
--      It is used in the GridVortex CyberSec IP, as a base for the fused HMAC-SHA256, HKDF, HMAC-SHA256-DRBG, and the SP-800 TRNG Entropy Source.
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
-- 2016/06/07   v0.01.0105  [JD]    verification against all NIST-FIPS-180-4 test vectors passed.
-- 2016/06/11   v0.01.0105  [JD]    verification against NIST-SHA2_Additional test vectors #1 to #10 passed.
-- 2016/06/11   v0.01.0110  [JD]    optimized controller states, reduced 2 clocks per block, added lookahead register feedback.
-- 2016/09/25   v0.01.0220  [JD]    changed 'di_ack_i' name to 'di_wr_i', and changed semantics to 'data write'.
--
--
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity gv_sha256 is
    port (
        -- clock and core enable
        clk_i : in std_logic := 'U';                                    -- system clock
        ce_i : in std_logic := 'U';                                     -- core clock enable
        -- input data
        di_i : in std_logic_vector (31 downto 0) := (others => 'U');    -- big endian input message words
        bytes_i : in std_logic_vector (1 downto 0) := (others => 'U');  -- valid bytes in input word
        -- start/end commands
        start_i : in std_logic := 'U';                                  -- reset the engine and start a new hash
        end_i : in std_logic := 'U';                                    -- marks end of last block data input
        -- handshake
        di_req_o : out std_logic;                                       -- requests data input for next word
        di_wr_i : in std_logic := 'U';                                  -- high for di_i valid, low for hold
        error_o : out std_logic;                                        -- signalizes error. output data is invalid
        do_valid_o : out std_logic;                                     -- when high, the output is valid
        -- 256bit output registers
        H0_o : out std_logic_vector (31 downto 0);
        H1_o : out std_logic_vector (31 downto 0);
        H2_o : out std_logic_vector (31 downto 0);
        H3_o : out std_logic_vector (31 downto 0);
        H4_o : out std_logic_vector (31 downto 0);
        H5_o : out std_logic_vector (31 downto 0);
        H6_o : out std_logic_vector (31 downto 0);
        H7_o : out std_logic_vector (31 downto 0)
    );                      
end gv_sha256;

architecture rtl of gv_sha256 is
    -- internal register data values
    signal R0_data : std_logic_vector (31 downto 0);
    signal R1_data : std_logic_vector (31 downto 0);
    signal R2_data : std_logic_vector (31 downto 0);
    signal R3_data : std_logic_vector (31 downto 0);
    signal R4_data : std_logic_vector (31 downto 0);
    signal R5_data : std_logic_vector (31 downto 0);
    signal R6_data : std_logic_vector (31 downto 0);
    signal R7_data : std_logic_vector (31 downto 0);
    -- initial hash data values
    signal K0_data : std_logic_vector (31 downto 0);
    signal K1_data : std_logic_vector (31 downto 0);
    signal K2_data : std_logic_vector (31 downto 0);
    signal K3_data : std_logic_vector (31 downto 0);
    signal K4_data : std_logic_vector (31 downto 0);
    signal K5_data : std_logic_vector (31 downto 0);
    signal K6_data : std_logic_vector (31 downto 0);
    signal K7_data : std_logic_vector (31 downto 0);
    -- hash result lookahead port
    signal N0_data : std_logic_vector (31 downto 0);
    signal N1_data : std_logic_vector (31 downto 0);
    signal N2_data : std_logic_vector (31 downto 0);
    signal N3_data : std_logic_vector (31 downto 0);
    signal N4_data : std_logic_vector (31 downto 0);
    signal N5_data : std_logic_vector (31 downto 0);
    signal N6_data : std_logic_vector (31 downto 0);
    signal N7_data : std_logic_vector (31 downto 0);
    -- hash result data
    signal H0_data : std_logic_vector (31 downto 0);
    signal H1_data : std_logic_vector (31 downto 0);
    signal H2_data : std_logic_vector (31 downto 0);
    signal H3_data : std_logic_vector (31 downto 0);
    signal H4_data : std_logic_vector (31 downto 0);
    signal H5_data : std_logic_vector (31 downto 0);
    signal H6_data : std_logic_vector (31 downto 0);
    signal H7_data : std_logic_vector (31 downto 0);
    -- message schedule word datapath
    signal Mi_data : std_logic_vector (31 downto 0);
    signal Wt_data : std_logic_vector (31 downto 0);
    -- coefficients ROMs
    signal Kt_data : std_logic_vector (31 downto 0);
    signal Kt_addr : std_logic_vector (5 downto 0);
    -- padding control
    signal words_sel : std_logic_vector (1 downto 0);
    signal bytes_ena : std_logic_vector (3 downto 0);
    signal one_insert : std_logic;
    signal msg_bitlen : std_logic_vector (63 downto 0);
    signal pad_data : std_logic_vector (31 downto 0);
    -- block mux selectors
    signal sch_ld : std_logic;
    signal core_ld : std_logic;
    signal oregs_ld : std_logic;
    -- block clock enables
    signal sch_ce : std_logic;
    signal core_ce : std_logic;
    signal oregs_ce : std_logic;
    -- output data valid / error
    signal data_valid : std_logic;
    signal error_pad : std_logic;
    signal error_ctrl : std_logic;
begin
    --=============================================================================================
    -- INTERNAL COMPONENT INSTANTIATIONS AND CONNECTIONS
    --=============================================================================================

    -- control path core logic
    Inst_sha256_control: entity work.sha256_control(rtl)
        port map(
            -- inputs
            clk_i           => clk_i,
            ce_i            => ce_i,
            bytes_i         => bytes_i,
            wr_i            => di_wr_i,
            start_i         => start_i,
            end_i           => end_i,
            error_i         => error_pad,
            -- output control signals
            bitlen_o        => msg_bitlen,
            words_sel_o     => words_sel,
            Kt_addr_o       => Kt_addr,
            sch_ld_o        => sch_ld,
            core_ld_o       => core_ld,
            oregs_ld_o      => oregs_ld,
            sch_ce_o        => sch_ce,
            core_ce_o       => core_ce,
            oregs_ce_o      => oregs_ce,
            one_insert_o    => one_insert,
            bytes_ena_o     => bytes_ena,
            di_req_o        => di_req_o,
            data_valid_o    => data_valid,
            error_o         => error_ctrl
        );
    
    -- datapath: sha256 byte padding
    Inst_sha256_padding: entity work.sha256_padding(rtl) 
        port map(
            words_sel_i     => words_sel,
            one_insert_i    => one_insert,
            bytes_ena_i     => bytes_ena,
            bitlen_i        => msg_bitlen,
            di_i            => di_i,
            do_o            => Mi_data,
            error_o         => error_pad
        );

    -- datapath: sha256 message schedule
    Inst_sha256_msg_sch: entity work.sha256_msg_sch(rtl) 
        port map(
            clk_i => clk_i,
            ce_i  => sch_ce,
            ld_i  => sch_ld,
            M_i   => Mi_data,
            Wt_o  => Wt_data
        );

    -- datapath: sha256 core logic
    Inst_sha256_hash_core: entity work.sha256_hash_core(rtl) 
        port map( 
            clk_i => clk_i,
            ce_i  => core_ce,
            ld_i  => core_ld,
            -- initial hash data values 
            A_i => N0_data,
            B_i => N1_data,
            C_i => N2_data,
            D_i => N3_data,
            E_i => N4_data,
            F_i => N5_data,
            G_i => N6_data,
            H_i => N7_data,
            -- block hash values
            A_o => R0_data, 
            B_o => R1_data,
            C_o => R2_data,
            D_o => R3_data,
            E_o => R4_data,
            F_o => R5_data,
            G_o => R6_data,
            H_o => R7_data,
            -- key coefficients 
            Kt_i => Kt_data,
            -- message schedule word input
            Wt_i => Wt_data
        );                      

    -- datapath: sha256 output registers
    Inst_sha256_regs: entity work.sha256_regs(rtl)
        port map(  
            clk_i => clk_i,
            ce_i  => oregs_ce,
            ld_i =>  oregs_ld,
            -- register data from the core logic
            A_i => R0_data,
            B_i => R1_data,
            C_i => R2_data,
            D_i => R3_data,
            E_i => R4_data,
            F_i => R5_data,
            G_i => R6_data,
            H_i => R7_data,
            -- initial hash values
            K0_i => K0_data,
            K1_i => K1_data,
            K2_i => K2_data,
            K3_i => K3_data,
            K4_i => K4_data,
            K5_i => K5_data,
            K6_i => K6_data,
            K7_i => K7_data,
            -- lookahead output hash values, one pipeline advanced
            N0_o => N0_data,
            N1_o => N1_data,
            N2_o => N2_data,
            N3_o => N3_data,
            N4_o => N4_data,
            N5_o => N5_data,
            N6_o => N6_data,
            N7_o => N7_data,
            -- output hash values
            H0_o => H0_data,
            H1_o => H1_data,
            H2_o => H2_data,
            H3_o => H3_data,
            H4_o => H4_data,
            H5_o => H5_data,
            H6_o => H6_data,
            H7_o => H7_data 
        );

    -- coefficients ROM: modelled as an asynchronously addressable ROM
    Inst_sha256_kt_rom: entity work.sha256_kt_rom(behavioral)
        port map(  
            addr_i => Kt_addr,
            dout_o => Kt_data
        );

    -- init output data ROM: modelled as a statically defined constant
    Inst_sha256_ki_rom: entity work.sha256_ki_rom(behavioral)
        port map(
            K0_o => K0_data,
            K1_o => K1_data, 
            K2_o => K2_data, 
            K3_o => K3_data, 
            K4_o => K4_data, 
            K5_o => K5_data, 
            K6_o => K6_data, 
            K7_o => K7_data 
        );
    
    --=============================================================================================
    --  OUTPUTS LOGIC
    --=============================================================================================

    error_o_proc:       error_o <= error_ctrl;
    do_valid_o_proc:    do_valid_o <= data_valid;
    H0_o_proc:          H0_o <= H0_data;
    H1_o_proc:          H1_o <= H1_data;
    H2_o_proc:          H2_o <= H2_data;
    H3_o_proc:          H3_o <= H3_data;
    H4_o_proc:          H4_o <= H4_data;
    H5_o_proc:          H5_o <= H5_data;
    H6_o_proc:          H6_o <= H6_data;
    H7_o_proc:          H7_o <= H7_data;
    
end rtl;

