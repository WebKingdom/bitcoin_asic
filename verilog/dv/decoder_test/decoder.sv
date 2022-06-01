`default_nettype none
`timescale 1 ns / 10 ps
/*
 *-------------------------------------------------------------
 *
 * decoder
 *
 * Used to transform a 32 bit target into a 256 bit target using math magic.
 *
 *-------------------------------------------------------------
 */

module decoder (input logic [31:0] target,
                    output logic [255:0] fullTarget);

	logic [3:0] sizeTens;
    logic [3:0] sizeOnes;
    logic [255:0] decoded;
    integer spacing;
    integer leftBuffer;
    integer i;
    initial begin
        sizeTens=target[31:28];
        sizeOnes=target[27:24];

        //IDK if this is legal
        spacing  = sizeTens*16+sizeOnes;

        leftBuffer = 32-spacing;

        //Pad left side based on first 2 bytes
        for(i=255;i>254-leftBuffer;i--)
            decoded[i] = 0;
        
        //Set value within middle of target
        i=0;
        while(i<24) begin
            decoded[255-leftBuffer-25+i] = target[i];
            i++;
        end
        //Pad the rest
        for(i=255-leftBuffer-26;i>-1;i--)
            decoded[i]=0;

        fullTarget = decoded;
    end


endmodule
