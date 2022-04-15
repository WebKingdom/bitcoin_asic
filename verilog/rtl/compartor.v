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
 * comparator
 *
 * This is a very simple comparator that takes in a
 * 256 bit target hash and hashOut value and output
 * 1 if target>hashOut otherwise it outputs 0.
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

    addsub_16 #(
        .BITS(BITS)
    ) addsub_16(
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


module comparator (
    input wire [255:0] hashOut,
    input wire [255:0] target,
    output reg out
    );
      reg ready;
    reg [BITS-1:0] rdata;
    reg [BITS-1:0] wb_data_reg;
    reg [BITS-1:0] prev_result;

    always @(posedge clk) begin
      // Reset outputs
      if (reset) begin
        ready <= 0;
        rdata <= 0;
        wb_data_reg <= 32'h00000000;
        prev_result <= 32'h00000000;
      end else begin
        ready <= 1'b0;

      if (hashOut<target) begin
        out=1;
      end
      else begin
        out=0;
      end
    end
endmodule
`default_nettype wire