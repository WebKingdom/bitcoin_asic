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

module comparator (
    input clk,
    input reset,
    input update,
    output [31:0] nonce
    );
    nonce = 32'h0;
    always @ (posedge clk) begin
        if (nonce<32'hFFFFFFFF and update)
            nonce = nonce+1;
        if (reset)
            nonce = 32'h0;
    end
endmodule