GHDL=ghdl


build:

	$(GHDL)	 -a sha256_hash_core.vhd
	$(GHDL)	 -a sha256_Ki_rom.vhd
	$(GHDL)	 -a sha256_Kt_rom.vhd
	$(GHDL)	 -a sha256_msg_sch.vhd
	$(GHDL)	 -a sha256_padding.vhd
	$(GHDL)	 -a sha256_regs.vhd
	$(GHDL)  -a gv_sha256.vhd
	$(GDHL)  -a sha256_test.vh

sim:

	$(GHDL)   -e testbench
	$(GHDL)	  -r testbench --wave=wave.ghw --stop-time=50us --ieee-asserts=disable	
