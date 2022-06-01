module decoder_tb;
 
    logic [31:0] target;
    wire [255:0] fullTarget;

    decoder dec1(.target(target), .fullTarget(fullTarget));

    initial begin
        //Dump waves
        $dumpfile("decoder_tb.vcd");
        $dumpvars;
        assign target='h1903A30C;
        $display("FINISHED decoder_tb");
    	$display("Output: %h", fullTarget);
    	$finish;

    end

endmodule