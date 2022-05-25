`default_nettype none
`timescale 1 ns / 10 ps
/*
 *-------------------------------------------------------------
 *
 * decoder
 *
 * Used to transform a 32 bit target into a 256 bit target using math magic.
 *
 *
 *-------------------------------------------------------------
 */

module decoder #(input logic [31:0] target,
                    output logic [255:0] fullTarget);

	logic [7:0] size;
    size<=target[31:24];
    

endmodule
