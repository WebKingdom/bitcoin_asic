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

	logic [3:0] sizeTens;
    logic [3:0] sizeOnes;

    sizeTens<=target[31:28];
    sizeOnes<=target[27:24];

    //IDK if this is legal
    integer spacing  = sizeTens*16+sizeOnes;

    integer leftBuffer = 32-spacing;

    //Todo figure out how to set all these values to 0
    fullTarget[255:255-leftBuffer] = 0;
    
    //Todo figure out how to set all these values to target[23:0]
    fullTarget[255-leftBuffer-1:255-leftBuffer-25] = target[23:0];

    fullTarget[255-leftBuffer-26:0]=0;


endmodule
