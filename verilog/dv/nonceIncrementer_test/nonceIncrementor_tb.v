`timescale 1ns / 1ps
	 
	module nonceIncrementer_tb ();
	  // Design Inputs and outputs
	  reg clk;
	  reg reset;
	  reg update;
	  wire [31:0] nonce;


	  // DUT instantiation
	  nonceIncrementer dut (
	    .clk (clk),
	    .reset (reset),
	    .update     (update),
	    .nonce     (nonce)
	  );

	  always #10 clk = ~clk;
	
	  // Generate the reset  
	  initial begin
	   reset = 1'b1;
	    #10
	   reset = 1'b0;
	  end
	
	 
	  // Test stimulus
	  initial begin
	    // Use the monitor task to display the FPGA IO
	    $monitor("clock=%1b, reset=%1b, update=%1b, nonce=%32b\n",
	              $time, clk, reset, update, nonce);
	 
        clk = 1'b0;
		update =1'b0;
        #20
		#20
		update =1'b1;
		#20
		#20
		update =1'b0;
        #20
		#20
		update =1'b1;
		#20
		#20
		reset=1'b1;
		update =1'b0;
        #20
		update =1'b1;
		#20
		$finish;
	  end
	 
	endmodule