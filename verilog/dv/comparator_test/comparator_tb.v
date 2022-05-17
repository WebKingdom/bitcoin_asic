`timescale 1ns / 1ps
	 
	module comparator_tb ();
	  // Design Inputs and outputs
	  reg [255:0] hash;
	  reg [255:0] targetHash;
	  wire out;
	  wire [255:0] outputHash;

	  // DUT instantiation
	  comparator dut (
	    .hashOut (hash),
	    .target (targetHash),
	    .out     (out),
	    .outHash     (outputHash)
	  );

	  // generate the clock
	  // initial begin
	  // clk = 1'b0;
	  //  forever #1 clk = ~clk;
	  //end
	
	 
	  // Test stimulus
	  initial begin
	    // Use the monitor task to display the FPGA IO
	    $monitor("time=%3d, hash=%64h, targetHash=%64h, out=%b  outputHash=%64h\n",
	              $time, hash, targetHash, out, outputHash);
	 
        hash = 256'b1111;
	    targetHash = 256'b111;
        #20
	    hash = 256'b11111;
        #20
	    hash = 256'b11;
        #20
	    hash = 256'b1111;
	  end
	 
	endmodule