/*
 *-------------------------------------------------------------
 *
 * nonceIncrementer
 *
 * A 32 bit incrementer initialized at zero.
 * increases by 1 each positive edge cycle until it reaches 32'hFFFFFFFF.
 *
 *-------------------------------------------------------------
 */

module nonceIncrementer (
    input clk,
    input reset,
    input update,
    output [31:0] nonce
    );

    reg [31:0] tempNonce = 32'b0;

    always @ (posedge clk) begin
        if (nonce<32'hFFFFFFFF && update==1'b1)
            tempNonce <= nonce+1;
    end
    
    always @ (reset) begin
        if (reset) 
            tempNonce <= 32'b0;
    end

    assign nonce=tempNonce;

endmodule