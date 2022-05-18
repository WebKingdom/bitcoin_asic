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
    reg [255:0] datareg = 256'b0;
    reg outWire = 1'b0;

   // always @(hashOut,target) begin
        if (hashOut<=target)begin
            outWire <= 1'b1;
            datareg <= hashOut;
        end
    //end

    assign out = outWire;
    assign outHash = datareg;

endmodule