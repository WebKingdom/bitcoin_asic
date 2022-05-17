/*
 *-------------------------------------------------------------
 *
 * comparator
 *
 * This is a very simple comparator that takes in a
 * 256 bit target hash and hashOut value and outputs
 * 1 if target>hashOut and the valid hash, otherwise it outputs 0 and an empty register.
 *
 *-------------------------------------------------------------
 */

module comparator (
    input [255:0] hashOut,
    input [255:0] target,
    output out,
    output [255:0] outHash
    );

    if (hashOut>target && out!=1)
        out<=0;
    else begin
        out<=1;
        outHash<=hashOut;
    end
endmodule