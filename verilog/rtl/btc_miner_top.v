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
  wire o_sha_cs;
  wire o_sha_we;
  wire [7:0] o_sha_address;

  reg [127:0] la_data_out;  // TODO? ensure LA muxing does not require register

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

  // Assuming LA probes [111:110] are for controlling the reset & clock
  assign clk = (~la_oenb[110]) ? la_data_in[110] : wb_clk_i;
  assign rst = (~la_oenb[111]) ? la_data_in[111] : wb_rst_i;

  // TODO more LA muxing
  // la_data_in or la_data_out or la_oenb or la_sel or nonce or block_header or target
  always @(la_data_in || la_oenb || la_sel || rdata || o_error || o_idle) begin
    case (la_sel)
      6'b000000:
        la_data_out <= {{(127-(BITS-12)){1'b0}}, {o_idle, o_error, o_sha_we, o_sha_cs, o_sha_address, rdata}};

      default:
        begin
          la_data_out <= {{(127-(BITS-12)){1'b0}}, {o_idle, o_error, o_sha_we, o_sha_cs, o_sha_address, rdata}};
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
    .idle(o_idle),
    .reg_sha_cs(o_sha_cs),
    .reg_sha_we(o_sha_we),
    .reg_sha_address(o_sha_address)
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
  output wire idle,
  output reg reg_sha_cs,
  output reg reg_sha_we,
  output reg [7:0] reg_sha_address
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
  // localparam ADDR_BLOCK1    = 8'h11;
  // localparam ADDR_BLOCK2    = 8'h12;
  // localparam ADDR_BLOCK3    = 8'h13;
  // localparam ADDR_BLOCK4    = 8'h14;
  // localparam ADDR_BLOCK5    = 8'h15;
  // localparam ADDR_BLOCK6    = 8'h16;
  // localparam ADDR_BLOCK7    = 8'h17;
  // localparam ADDR_BLOCK8    = 8'h18;
  // localparam ADDR_BLOCK9    = 8'h19;
  // localparam ADDR_BLOCK10   = 8'h1a;
  // localparam ADDR_BLOCK11   = 8'h1b;
  // localparam ADDR_BLOCK12   = 8'h1c;
  // localparam ADDR_BLOCK13   = 8'h1d;
  // localparam ADDR_BLOCK14   = 8'h1e;
  localparam ADDR_BLOCK15   = 8'h1f;

  localparam ADDR_DIGEST0   = 8'h20;
  // localparam ADDR_DIGEST1   = 8'h21;
  // localparam ADDR_DIGEST2   = 8'h22;
  // localparam ADDR_DIGEST3   = 8'h23;
  // localparam ADDR_DIGEST4   = 8'h24;
  // localparam ADDR_DIGEST5   = 8'h25;
  // localparam ADDR_DIGEST6   = 8'h26;
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
  wire read_status_flag;

  wire [BITS-1:0] sha_write_data; // input to sha256
  wire [BITS-1:0] sha_read_data;  // output from sha256

  wire sha_in_ready;
  wire sha_digest_valid;
  wire auto_ctrl;

  assign idle = (state == WAIT_IN) ? 1'b1 : 1'b0;
  assign start_ctrl = la_input3[10] & la_write3[10];

  // automated and manual control
  assign read_status_flag = sha_cs && !sha_we && (sha_address == ADDR_STATUS);
  assign sha_in_ready = read_status_flag ? sha_read_data[STATUS_READY_BIT] : 1'b0;
  assign sha_digest_valid = read_status_flag ? sha_read_data[STATUS_VALID_BIT] : 1'b0;

  assign auto_ctrl = la_input3[11] & la_write3[11];

  assign sha_cs = auto_ctrl ? reg_sha_cs : (la_input3[8] & la_write3[8]);
  assign sha_we = auto_ctrl ? reg_sha_we : (la_input3[9] & la_write3[9]);
  assign sha_address = auto_ctrl ? reg_sha_address : (la_input3[7:0] & la_write3[7:0]);

  // need to count to 640/32 = 20 (decimal). Only to 19 b/c nonce is last 32-bits
  integer unsigned count;

  always @(posedge clk) begin
    if (rst) begin
      ready <= 0;
      rdata <= 0;
      count <= 0;
      reg_sha_cs <= 0;
      reg_sha_we <= 0;
      reg_sha_address <= 0;
      // sha_in_ready <= 0;
      // sha_digest_valid <= 0;

      state <= WAIT_IN;
    end else if (auto_ctrl) begin
      ready <= 1'b0;

      // state machine for controlling miner and I/O
      case (state)
        WAIT_IN: begin
          // TODO?
          reg_sha_cs <= 1'b1;
          reg_sha_we <= 1'b0;
          reg_sha_address <= ADDR_STATUS;
          
          if (start_ctrl && sha_in_ready) begin
            reg_sha_cs <= 1'b1;
            reg_sha_we <= 1'b1;
            state <= READ_IN;
          end
        end

        READ_IN: begin
          // TODO?
          reg_sha_cs <= 1'b1;
          reg_sha_we <= 1'b1;

          if (valid && !ready) begin
            ready <= 1'b1;
            sha_write_data <= wdata;

            if (wb_wr_mask == 4'b1111) begin
              // read up to the last address
              if (reg_sha_address == ADDR_BLOCK15) begin
                state <= WAIT_COMPUTE;
              end else begin
                // check if 1st write coming from WAIT_IN
                if (sha_address == ADDR_STATUS) begin
                  reg_sha_address <= ADDR_BLOCK0;
                end else begin
                  reg_sha_address <= reg_sha_address + 1;
                end
              end

            end
          end
        end

        WAIT_COMPUTE: begin
          // read status register to determine when done
          reg_sha_cs <= 1'b1;
          reg_sha_we <= 1'b0;
          reg_sha_address <= ADDR_STATUS;

          if (sha_digest_valid) begin
            reg_sha_address <= ADDR_DIGEST0;
            state <= WRITE_OUT;
          end
        end

        WRITE_OUT: begin
          // TODO?
          reg_sha_cs <= 1'b1;
          reg_sha_we <= 1'b0;

          if (valid && !ready) begin
            ready <= 1'b1;

            // Place output hash on wishbone
            if (wb_wr_mask == 4'b0000) begin
              rdata <= sha_read_data;
              
              if (reg_sha_address == ADDR_DIGEST7) begin
                state <= WAIT_IN;
              end else begin
                reg_sha_address <= reg_sha_address + 1;
              end
            end
          end
        end

      endcase
    end else begin
      // TODO not automated control. FW controls all wr/rd and addresses.
    end

    // set ready and valid bits for sha256 module
    // if (sha_cs && !sha_we && (sha_address == ADDR_STATUS)) begin
    //   sha_in_ready <= sha_read_data[STATUS_READY_BIT];
    //   sha_digest_valid <= sha_read_data[STATUS_VALID_BIT];
    // end else begin
    //   sha_in_ready <= 1'b0;
    //   sha_digest_valid <= 1'b0;
    // end
  end

  // TODO handle ADDR_CTRL register! 
  sha256 sha256_inst0(
    .clk(clk),
    .reset_n(~rst),
    .cs(sha_cs),
    .we(sha_we),
    .address(sha_address),
    .write_data(sha_write_data),  // 32-bit input 
    .read_data(sha_read_data),    // 32-bit output
    .error(error)                 // 1-bit output
  );

endmodule // miner_ctrl

`default_nettype wire
