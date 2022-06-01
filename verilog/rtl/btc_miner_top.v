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
 * btc_miner_top
 * TODO!
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

module btc_miner_top #(
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

  // WB wires
  wire [31:0] rdata; 
  wire [31:0] wdata;

  wire valid;
  wire [3:0] wstrb;

  // LA wires
  wire [31:0] la_write0;
  wire [31:0] la_write1;
  wire [31:0] la_write2;
  wire [31:0] la_write3;

  // SHA module variables
  wire o_error;
  wire o_idle;
  reg [127:0] la_data_out;  // TODO ensure LA muxing does not require register

  // TODO use top 32-bits of LA to control muxing and other variables like starting state machine
  wire [5:0] la_sel;
  assign la_sel = la_data_in[127:122];

  // WB MI A
  assign valid = wbs_cyc_i && wbs_stb_i; 
  assign wstrb = wbs_sel_i & {4{wbs_we_i}};
  assign wbs_dat_o = rdata;
  assign wdata = wbs_dat_i;

  // IO
  assign io_out = rdata;
  assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

  // IRQ
  assign irq = 3'b000;	// Unused

  // Assuming LA probes [31:0] (aka: la_write0) are for controlling the nonce register.
  // * NOTE: These are used as a mask for the la_data_in[?:?]
  assign la_write0 = ~la_oenb[31:0] & ~{BITS{valid}};
  assign la_write1 = ~la_oenb[63:32] & ~{BITS{valid}};
  assign la_write2 = ~la_oenb[95:64] & ~{BITS{valid}};
  assign la_write3 = ~la_oenb[127:96] & ~{BITS{valid}};

  // Assuming LA probes [107:106] are for controlling the clk & reset  
  assign clk = (~la_oenb[106]) ? la_data_in[106] : wb_clk_i;
  assign rst = (~la_oenb[107]) ? la_data_in[107] : wb_rst_i;

  // TODO more LA muxing
  // la_data_in or la_data_out or la_oenb or la_sel or nonce or block_header or target
  always @(la_data_in || la_oenb || la_sel || rdata || o_error || o_idle) begin
    case (la_sel)
      6'b000000:
        la_data_out[95:0] <= {{(95-(BITS-2)){1'b0}}, {o_idle, o_error, rdata}};

      default:
        begin
          // nothing
        end
    endcase
  end

  // TODO create state machine for reading block header and passing to miner
  miner_ctrl #(
    .BITS(BITS)
  ) miner_ctrl(
    .clk(clk),
    .rst(rst),
    .valid(valid),
    .wb_wr_mask(wstrb),
    .wdata(wbs_dat_i),
    .la_write3(la_write3),
    .la_input3(la_data_in[127:96]),
    .rdata(rdata),
    .ready(wbs_ack_o),
    .error(o_error),
    .idle(o_idle)
  );

endmodule // btc_miner_top


// miner_ctrl
module miner_ctrl #(
  parameter BITS = 32
)(
  input wire clk,
  input wire rst,
  input wire valid,
  input wire [3:0] wb_wr_mask,
  input wire [BITS-1:0] wdata,
  input wire [BITS-1:0] la_write3,
  input wire [BITS-1:0] la_input3,
  output reg [BITS-1:0] rdata,
  output reg ready,
  output wire error,
  output wire idle
);

  // sha256 internal constants and parameters
  localparam ADDR_NAME0       = 8'h00;
  localparam ADDR_NAME1       = 8'h01;
  localparam ADDR_VERSION     = 8'h02;

  localparam ADDR_CTRL        = 8'h08;
  localparam CTRL_INIT_BIT    = 0;
  localparam CTRL_NEXT_BIT    = 1;
  localparam CTRL_MODE_BIT    = 2;

  localparam ADDR_STATUS      = 8'h09;
  localparam STATUS_READY_BIT = 0;
  localparam STATUS_VALID_BIT = 1;

  localparam ADDR_BLOCK0    = 8'h10;
  localparam ADDR_BLOCK15   = 8'h1f;

  localparam ADDR_DIGEST0   = 8'h20;
  localparam ADDR_DIGEST7   = 8'h27;

  localparam MODE_SHA_224   = 1'h0;
  localparam MODE_SHA_256   = 1'h1;

  // enum logic [1:0] {WAIT_IN=2'b00, READ_IN=2'b01, WAIT_COMPUTE=2'b10, CHECK=2'b11, WRITE_OUT=} state;
  // enum integer unsigned {WAIT_IN=0, READ_IN=1, WAIT_COMPUTE=2, INCR_NONCE=3, WRITE_OUT=4} state;
  localparam WAIT_IN=0, READ_IN=1, WAIT_COMPUTE=2, WRITE_OUT=3;

  reg [2:0] state;

  wire start_ctrl;
  wire sha_cs;
  wire sha_we;
  wire [7:0] sha_address;
  wire [BITS-1:0] sha_write_data;
  wire [BITS-1:0] sha_read_data;

  wire sha_in_ready;
  wire sha_digest_valid;
  wire auto_ctrl;

  assign idle = (state == WAIT_IN) ? 1'b1 : 1'b0;
  assign start_ctrl = la_input3[12] & la_write3[12];

  assign sha_cs = la_input3[8] & la_write3[8];
  assign sha_we = la_input3[9] & la_write3[9];
  assign sha_address = la_input3[7:0] & la_write3[7:0];

  assign auto_ctrl = la_input3[13] & la_write3[13];

  // need to count to 640/32 = 20 (decimal). Only to 19 b/c nonce is last 32-bits
  integer unsigned count;

  always @(posedge clk) begin
    if (rst) begin
      ready <= 0;
      rdata <= 0;
      count <= 0;

      state <= WAIT_IN;
    end else if (auto_ctrl) begin
      ready <= 1'b0;

      // state machine for controlling miner and I/O
      case (state)
        WAIT_IN: begin
          // TODO?
          if (start_ctrl) begin
            state <= READ_IN;
          end
        end

        READ_IN: begin
          // TODO?
          if (valid && !ready) begin
            ready <= 1'b1;

            if (wb_wr_mask == 4'b1111) begin
              // if read up to the last address
              if ((sha_address == ADDR_BLOCK15) && sha_cs && !sha_we) begin
                state <= WAIT_COMPUTE;
              end
            end
          end
        end

        WAIT_COMPUTE: begin
          // read status register to determine when done
          if (sha_cs && !sha_we) begin
            // TODO read status register and move to WRITE_OUT state

          end
        end
          
        WRITE_OUT: begin
          // TODO
          if (valid && !ready) begin
            ready <= 1'b1;

            if (wb_wr_mask == 4'b1111) begin
              // WB should not be writing to user project
            end else begin
              // Place output hash on wishbone
            end
          end
        end

      endcase
    end else begin
      // TODO not automated control. FW controls all wr/rd and addresses.
    end
  end

  // TODO
  sha256 sha256_inst0(
    .clk(clk),
    .reset_n(~rst),
    .cs(sha_cs),
    .we(sha_we),
    .address(sha_address),
    .write_data(sha_write_data),
    .read_data(sha_read_data),
    .error(error)
  );

endmodule // miner_ctrl

`default_nettype wire
