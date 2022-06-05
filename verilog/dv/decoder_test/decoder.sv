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

	logic [7:0] shift_amount;
    logic [255:0] temp_reg;
    integer i;
    initial begin

        shift_amount=target[31:24];

        for(i = 23;i>-1;i--)
            temp_reg[232+i]=target[i];
        
        for(i = 231;i>-1;i--)
            temp_reg[i]=0;

        assign fullTarget = temp_reg >> shift_amount;
    end


endmodule
