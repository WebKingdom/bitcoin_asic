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
 * sha1_top
 * TODO!
 *
 * A top wrapper for controlling the SHA 1 HW accelerator
 *
 *-------------------------------------------------------------
 */

module sha1_top #(
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
  wire [BITS-1:0] o_sha_read_data;

  // TODO use top 32-bits of LA to control muxing and other variables like starting state machine
  wire [5:0] la_sel;
  assign la_sel = la_data_in[127:122];
  wire [75:0] la_data_out_w;

  // WB MI A
  assign valid = wbs_cyc_i && wbs_stb_i; 
  assign wstrb = wbs_sel_i & {4{wbs_we_i}};
  assign wbs_dat_o = rdata;
  assign wdata = wbs_dat_i;

  // IO
  assign io_out = {rdata, 6'b000000};       // 38 bits
  assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

  // IRQ
  assign irq = 3'b000;	// TODO? could use it to signal when ready or done with sha

  // Assuming LA probes [31:0] (aka: la_write0) are for controlling the nonce register.
  // * NOTE: These are used as a mask for the la_data_in[?:?]
  assign la_write0 = ~la_oenb[31:0] & ~{BITS{valid}};
  assign la_write1 = ~la_oenb[63:32] & ~{BITS{valid}};
  assign la_write2 = ~la_oenb[95:64] & ~{BITS{valid}};
  assign la_write3 = ~la_oenb[127:96] & ~{BITS{valid}};

  // 76 bits
  assign la_data_out_w = {o_idle, o_error, o_sha_we, o_sha_cs, o_sha_address, o_sha_read_data, rdata};

  // Assuming LA probes [111:110] are for controlling the reset & clock
  assign clk = (~la_oenb[110]) ? la_data_in[110] : wb_clk_i;
  assign rst = (~la_oenb[111]) ? la_data_in[111] : wb_rst_i;

  // TODO more LA muxing
  assign la_data_out = (la_sel == 6'b000000) ? {{52{1'b0}}, la_data_out_w} : ((la_sel == 6'b000001) ? {{52{1'b0}}, la_data_out_w} : {{52{1'b0}}, la_data_out_w});
  // always @(clk || la_data_in || la_oenb || la_sel || la_data_out_w) begin
  //   if (rst) begin
  //     la_data_out <= 0;
  //   end else begin
  //     case (la_sel)
  //     6'b000000:
  //       la_data_out <= {{52{1'b0}}, la_data_out_w};

  //     default:
  //       begin
  //         la_data_out <= {{52{1'b0}}, la_data_out_w};
  //       end
  //   endcase
  //   end
  // end

  // module for controlling the sha module
  sha1_ctrl #(
    .BITS(BITS)
  ) sha1_ctrl_inst(
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
    .sha_address(o_sha_address),
    .sha_read_data(o_sha_read_data)
  );

endmodule // sha1_top


// sha1_ctrl
module sha1_ctrl #(
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
  output wire [7:0] sha_address,
  output wire [BITS-1:0] sha_read_data  // output from sha1
);

  // sha1 internal constants and parameters
  localparam ADDR_NAME0       = 8'h00;
  localparam ADDR_NAME1       = 8'h01;
  localparam ADDR_VERSION     = 8'h02;

  localparam ADDR_CTRL        = 8'h08;
  localparam CTRL_INIT_BIT    = 0;
  localparam CTRL_NEXT_BIT    = 1;

  localparam ADDR_STATUS      = 8'h09;
  localparam STATUS_READY_BIT = 0;
  localparam STATUS_VALID_BIT = 1;

  localparam ADDR_BLOCK0    = 8'h10;
  localparam ADDR_BLOCK14   = 8'h1e;
  localparam ADDR_BLOCK15   = 8'h1f;

  localparam ADDR_DIGEST0   = 8'h20;
  localparam ADDR_DIGEST4   = 8'h24;

  localparam CORE_NAME0     = 32'h73686131; // "sha1"
  localparam CORE_NAME1     = 32'h20202020; // "    "
  localparam CORE_VERSION   = 32'h302e3630; // "0.60"

  // enum logic [1:0] {WAIT_IN=2'b00, READ_IN=2'b01, WAIT_COMPUTE=2'b10, CHECK=2'b11, WRITE_OUT=} state;
  // enum integer unsigned {WAIT_IN=0, READ_IN=1, WAIT_COMPUTE=2, INCR_NONCE=3, WRITE_OUT=4} state;
  localparam WAIT_IN=0, READ_IN=1, WRITE_CTRL=2, WAIT_COMPUTE=3, WRITE_OUT=4;

  reg [2:0] state;

  wire start_ctrl;
  wire sha_cs;
  wire sha_we;
  reg [7:0] reg_sha_address;

  // sha_next, sha_init. Map to ADDR_CTRL register [1:0]
  wire [1:0] sha_ctrl_bits;
  wire read_status_flag;

  reg [BITS-1:0] sha_write_data; // input to sha1

  wire sha_in_ready;
  wire sha_digest_valid;
  wire auto_ctrl;

  assign idle = (state == WAIT_IN) ? 1'b1 : 1'b0;

  // * la_write is 0 when valid is 1 !!
  // assign start_ctrl = la_input3[10] & la_write3[10];
  assign start_ctrl = la_input3[10];  

  // automated and manual control
  assign read_status_flag = sha_cs && !sha_we && (sha_address == ADDR_STATUS);
  assign sha_in_ready = read_status_flag ? sha_read_data[STATUS_READY_BIT] : 1'b0;
  assign sha_digest_valid = read_status_flag ? sha_read_data[STATUS_VALID_BIT] : 1'b0;

  // assign auto_ctrl = la_input3[11] & la_write3[11];
  assign auto_ctrl = la_input3[11];

  // assign sha_cs = auto_ctrl ? reg_sha_cs : (la_input3[8] & la_write3[8]);
  // assign sha_we = auto_ctrl ? reg_sha_we : (la_input3[9] & la_write3[9]);
  // assign sha_address = auto_ctrl ? reg_sha_address : (la_input3[7:0] & la_write3[7:0]);
  // assign sha_ctrl_bits = la_input3[17:16] & la_write3[17:16];
  assign sha_cs = auto_ctrl ? reg_sha_cs : la_input3[8];
  assign sha_we = auto_ctrl ? reg_sha_we : la_input3[9];
  assign sha_address = auto_ctrl ? reg_sha_address : la_input3[7:0];
  assign sha_ctrl_bits = la_input3[17:16];


  always @(posedge clk) begin
    if (rst) begin
      rdata <= 0;
      ready <= 0;
      reg_sha_cs <= 0;
      reg_sha_we <= 0;
      reg_sha_address <= 0;
      sha_write_data <= 0;
      state <= WAIT_IN;
    end else if (auto_ctrl) begin
      ready <= 1'b0;

      // state machine for controlling SHA module and I/O
      case (state)
        WAIT_IN: begin
          // wait for LA start input and for sha module to be ready
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
          // read in 512-bit input to sha module through WB
          reg_sha_cs <= 1'b1;
          reg_sha_we <= 1'b1;

          if (valid && !ready) begin
            ready <= 1'b1;
            sha_write_data <= wdata;

            if (wb_wr_mask == 4'b1111) begin
              // read up to the last address
              if (sha_address == ADDR_BLOCK14) begin
                // new addr will be ADDR_BLOCK15
                reg_sha_address <= reg_sha_address + 1;
                state <= WRITE_CTRL;
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

        WRITE_CTRL: begin
          // write sha control register according to LA
          reg_sha_cs <= 1'b1;
          reg_sha_address <= ADDR_CTRL;
          sha_write_data <= {{(BITS-2){1'b0}}, {sha_ctrl_bits}};

          // write and read back to ensure CTRL is set
          if (reg_sha_we == 1'b0) begin
            if (sha_read_data[1:0] == sha_ctrl_bits) begin
              state <= WAIT_COMPUTE;
            end else begin
              reg_sha_we <= 1'b1;
            end
          end else begin
            reg_sha_we <= 1'b0;
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
          // write valid 256-bit digest to WB
          reg_sha_cs <= 1'b1;
          reg_sha_we <= 1'b0;

          if (valid && !ready) begin
            ready <= 1'b1;

            // Place output hash on wishbone
            if (wb_wr_mask == 4'b0000) begin
              rdata <= sha_read_data;
              
              if (sha_address == ADDR_DIGEST4) begin
                reg_sha_address <= ADDR_STATUS;
                state <= WAIT_IN;
              end else begin
                reg_sha_address <= reg_sha_address + 1;
              end
            end
          end
        end

      endcase
    end else begin
      // TODO? not automated control. FW controls all wr/rd and addresses and needs to look at LA
      if (sha_address == ADDR_CTRL) begin
        sha_write_data <= {{(BITS-2){1'b0}}, {sha_ctrl_bits}};
      end else begin
        sha_write_data <= wdata;
      end
    end

  end

  sha1 sha1_inst0(
    .clk(clk),
    .reset_n(~rst),
    .cs(sha_cs),
    .we(sha_we),
    .address(sha_address),        // 8-bit address
    .write_data(sha_write_data),  // 32-bit reg input 
    .read_data(sha_read_data),    // 32-bit output
    .error(error)                 // 1-bit output
  );

endmodule // sha1_ctrl

`default_nettype wire

