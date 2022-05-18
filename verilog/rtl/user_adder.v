// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_adder
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_adder #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire clk;
    wire rst;

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire [31:0] rdata; 
    wire [31:0] wdata;
    wire [BITS-1:0] prev_result;

    wire valid;
    wire [3:0] wstrb;
    wire [31:0] la_write;

    // WB MI A
    assign valid = wbs_cyc_i && wbs_stb_i; 
    assign wstrb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = rdata;
    assign wdata = wbs_dat_i;

    // IO
    assign io_out = prev_result;
    assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

    // IRQ
    assign irq = 3'b000;	// Unused

    // LA
    // place 'prev_result' data on last 32-bits of LA
    assign la_data_out = {{(127-BITS){1'b0}}, prev_result};
    // Assuming LA probes [63:32] are for controlling the prev_result register  
    assign la_write = ~la_oenb[63:32] & ~{BITS{valid}};
    // Assuming LA probes [65:64] are for controlling the prev_result clk & reset  
    assign clk = (~la_oenb[64]) ? la_data_in[64]: wb_clk_i;
    assign rst = (~la_oenb[65]) ? la_data_in[65]: wb_rst_i;

    add_sub_accum #(
        .BITS(BITS)
    ) add_sub_accum(
        .clk(clk), 
        .reset(rst),
        .ready(wbs_ack_o),
        .valid(valid), 
        .wb_we(wbs_we_i),
        .use_prev_result(la_data_in[94]),
        .nAdd_Sub(la_data_in[95]),
        .rdata(rdata),
        .wdata(wbs_dat_i), 
        .la_write(la_write), 
        .la_input(la_data_in[63:32]),
        .prev_result(prev_result)
    );

endmodule

module add_sub_accum #(
    parameter BITS = 32
)(
    input clk,
    input reset,
    input valid,
    input wb_we,                // WB write enable (use together with valid to determine read/write)
    input use_prev_result,      // Boolean for using previous result in computation
    input nAdd_Sub,             // LA probe 95 controls nAdd_Sub
    input [BITS-1:0] wdata,     // Packed data stream (upper 16-bits i_X; lower 16-bits i_Y) 
    input [BITS-1:0] la_write,  // Used for masking la_input of previous result of adder
    input [BITS-1:0] la_input,  // Used as the previous result of the adder
    output ready,               // Acknowledge of WB slave (output)
    output [BITS-1:0] rdata,    // Sum/Difference of Adder/Sub
    output [BITS-1:0] prev_result // previous result of add/sub
);
    reg ready;
    reg [BITS-1:0] rdata;
    reg [BITS-1:0] wb_data_reg;
    reg [BITS-1:0] prev_result;

    wire [BITS-1:0] res_added;
    wire [BITS-1:0] res_subtracted;

    assign res_added = use_prev_result ? (prev_result + wb_data_reg) : (wb_data_reg[31:16] + wb_data_reg[15:0]);
    assign res_subtracted = use_prev_result ? (prev_result - wb_data_reg) : (wb_data_reg[31:16] - wb_data_reg[15:0]);

    always @(posedge clk) begin
      // Reset outputs
      if (reset) begin
        ready <= 0;
        rdata <= 0;
        wb_data_reg <= 0;
        prev_result <= 0;
      end else begin
        ready <= 1'b0;

        // valid read/write to WB and ready (user defined)
        if (valid && !ready) begin
          ready <= 1'b1;

          if (wb_we) begin
            // Read Wb input into register
            wb_data_reg <= wdata;
          end else begin
            // Write output to WB. Add/Sub operation with previous result if desired
            if (nAdd_Sub) begin
              rdata <= res_subtracted;
            end else begin
              rdata <= res_added;
            end
          end

        end else if (|la_write) begin
          // FW control previous result. Can store result from WB and can write prev_result
          prev_result <= la_write & la_input;
        end
      end
    end

endmodule
`default_nettype wire
