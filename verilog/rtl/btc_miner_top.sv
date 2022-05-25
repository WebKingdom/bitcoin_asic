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

  // Bitcoin mining variables
  wire [BITS-1:0] nonce;
  wire idle;
  wire [639:0] block_header;
  wire [255:0] target;

  // TODO use top 32-bits of LA to control muxing and other variables like starting state machine
  wire [2:0] la_sel;
  assign la_sel = la_data_in[127:125];

  // WB MI A
  assign valid = wbs_cyc_i && wbs_stb_i; 
  assign wstrb = wbs_sel_i & {4{wbs_we_i}};
  assign wbs_dat_o = rdata;
  assign wdata = wbs_dat_i;

  // IO
  assign io_out = nonce;
  assign io_oeb = {(`MPRJ_IO_PADS-1){rst}};

  // IRQ
  assign irq = 3'b000;	// Unused

  // Assuming LA probes [31:0] (aka: la_write0) are for controlling the nonce register.
  // * NOTE: These are used as a mask for the la_data_in[?:?]
  assign la_write0 = ~la_oenb[31:0] & ~{BITS{valid}};
  assign la_write1 = ~la_oenb[63:32] & ~{BITS{valid}};
  assign la_write2 = ~la_oenb[95:64] & ~{BITS{valid}};
  assign la_write3 = ~la_oenb[127:96] & ~{BITS{valid}};

  // Assuming LA probes [97:96] are for controlling the clk & reset  
  assign clk = (~la_oenb[96]) ? la_data_in[96] : wb_clk_i;
  assign rst = (~la_oenb[97]) ? la_data_in[97] : wb_rst_i;

  // TODO more LA muxing
  always @(la_data_in || la_data_out || la_oenb || la_sel || nonce || block_header || target) begin
    case (la_sel)
      2'b00 : la_data_out[95:0] <= {{(95-BITS){1'b0}}, nonce};
      2'b01 : la_data_out[95:0] <= block_header[95:0];
      2'b10 : la_data_out[95:0] <= block_header[191:96];
      2'b11 : la_data_out[95:0] <= block_header[287:192];

      default:
        // should not happen
    endcase
  end

  // TODO create state machine for reading block header and passing to miner
  miner_ctrl #(
    .BITS(BITS)
  ) miner_ctrl (
    .clk(clk),
    .rst(rst),
    .valid(valid),
    .wb_we(wbs_we_i),
    .wdata(wbs_dat_i),
    .la_write0(la_write0),
    .la_write3(la_write3),
    .la_input0(la_data_in[31:0]),
    .la_input3(la_data_in[127:96]),
    .ready(wbs_ack_o),
    .rdata(rdata),
    .block_header(block_header),
    .target(target),
    .nonce(nonce),
    .idle(o_idle)
  )

endmodule // btc_miner_top


// miner_ctrl
module miner_ctrl #(
  parameter BITS 32
)(
  input clk,
  input rst,
  input valid,
  input wb_we,
  input [BITS-1:0] wdata,
  input [BITS-1:0] la_write0,
  input [BITS-1:0] la_write3,
  input [BITS-1:0] la_input0,
  input [BITS-1:0] la_input3,
  output ready,
  output [BITS-1:0] rdata,
  output block_header,
  output target,
  output nonce,
  output idle
);

  // enum logic [1:0] {WAIT_IN=2'b00, READ_IN=2'b01, COMPUTE=2'b10, CHECK=2'b11, WRITE_OUT=} state;
  enum int unsigned {WAIT_IN=0, READ_IN=1, COMPUTE=2, INCR_NONCE=3, WRITE_OUT=4} state;

  reg ready;
  reg [BITS-1:0] rdata;
  reg [BITS-1:0] wb_data_reg;
  reg [BITS-1:0] nonce;
  reg [BITS-1:0] encoded_target;
  reg [255:0] target;
  reg miner_rst;

  logic [639:0] block_header;
  logic [255:0] o_hash_val;
  logic o_done_hash;

  wire idle;
  wire start;

  assign idle = (state == WAIT_IN) ? 1'b1 : 1'b0;
  assign start = la_write[2] ? la_input3[2] : 1'b0;

  // need to count to 640/32 = 20 (decimal). Only to 19 b/c nonce is last 32-bits
  int unsigned count;

  always @(posedge clk) begin
    if (rst) begin
      ready <= 0;
      rdata <= 0;
      wb_data_reg <= 0;
      nonce <= 0;
      encoded_target <= 0;
      target <= 0;
      count <= 0;
      miner_rst <= 1;
      block_header <= 0;

      state <= WAIT_IN;
    end else begin
      ready <= 1'b0;

      // state machine for controlling miner and I/O
      case (state)
        WAIT_IN:
          // TODO?
          miner_rst <= 1;
          if (start == 1) begin
            state <= READ_IN;
          end

        READ_IN:
          // TODO
          miner_rst <= 1;

          if (valid && !ready) begin
            ready <= 1'b1;

            if (wb_we) begin
              // TODO? read WB data into block header
              block_header[BITS*count + 31 : BITS*count] <= wdata;
              if (count == 18) begin
                // TODO pass encoded_target into decoder module
                encoded_target <= wdata;
                target <= {{(255-BITS){1'b0}}, wdata};
                count <= count + 1;
              end else if (count >= 19) begin
                block_header[639:608] <= nonce;
                count <= 0;
                nonce <= nonce + 1;
                miner_rst <= 0;
                state <= COMPUTE;
              end else begin
                count <= count + 1;
              end
            end
          end

        COMPUTE:
          // start miner
          if (o_done_hash) begin
            // TODO target
            if (o_hash_val < target) begin
              state <= WRITE_OUT
            end else begin
              miner_rst <= 1;
              block_header[639:608] <= nonce;
              state <= INCR_NONCE;
            end
          end else begin
            miner_rst <= 0;
          end

        INCR_NONCE:
          // TODO?
          miner_rst <= 0;
          nonce <= nonce + 1;
          state <= COMPUTE;
          
        WRITE_OUT:
          // TODO
          if (valid && !ready) begin
            ready <= 1'b1;

            if (wb_we) begin
              // WB should not be writing to user project
            end else begin
              // Place output hash on wishbone
              rdata <= o_hash_val[BITS*count +:BITS];
              if (count >= 7) begin
                count <= 0;
                state <= WAIT_IN;
              end else begin
                count <= count + 1;
              end
            end
          end

        default:
          // should not happen
      endcase
    end
  end

  miner double_sha256_miner(
    .block(block_header),
    .clk(clk),
    .rst(rst),
    .hashed(o_hash_val),
    .done(o_done_hash)
  );
endmodule // miner_ctrl


// miner
module miner(
  input logic [639:0] block,
  input logic clk, rst,
  output logic [255:0] hashed,
  output logic done
);

  logic [255:0] first_hash;
  logic [255:0] secnd_hash;

  logic second_run_rst;
  logic done_first_hash;
  logic done_secnd_hash;

  sha_256 #(.MSG_SIZE(640), .PADDED_SIZE(1024)) first (.message(block), .hashed(first_hash), .clk(clk), .rst(rst), .done(done_first_hash));
  sha_256 #(.MSG_SIZE(256), .PADDED_SIZE(512)) second (.message(first_hash), .hashed(secnd_hash), .clk(clk), .rst(second_run_rst), .done(done_secnd_hash));

  // always @* second_run_rst <= 1'b0;

  always @(posedge clk) begin
    if (done_first_hash === 1'bX) second_run_rst <= 1'b1;
    else if (done_first_hash == 1'b1) second_run_rst <= 1'b0;
  end

  assign done = done_secnd_hash;
  assign hashed = {secnd_hash[7:0], secnd_hash[15:8], secnd_hash[23:16], secnd_hash[31:24], secnd_hash[39:32], secnd_hash[47:40], secnd_hash[55:48], secnd_hash[63:56], secnd_hash[71:64], secnd_hash[79:72], secnd_hash[87:80], secnd_hash[95:88], secnd_hash[103:96], secnd_hash[111:104], secnd_hash[119:112], secnd_hash[127:120], secnd_hash[135:128], secnd_hash[143:136], secnd_hash[151:144], secnd_hash[159:152], secnd_hash[167:160], secnd_hash[175:168], secnd_hash[183:176], secnd_hash[191:184], secnd_hash[199:192], secnd_hash[207:200], secnd_hash[215:208], secnd_hash[223:216], secnd_hash[231:224], secnd_hash[239:232], secnd_hash[247:240], secnd_hash[255:248]};
endmodule // miner


// sha_256
module sha_256 #(
  parameter MSG_SIZE = 24,
  parameter PADDED_SIZE = 512
)(
  input logic [MSG_SIZE-1:0] message,
  input logic clk, rst,
  output logic [255:0] hashed,
  output logic done
);

  logic[PADDED_SIZE-1:0] padded;

  sha_padder #(.MSG_SIZE(MSG_SIZE), .PADDED_SIZE(PADDED_SIZE)) padder (.message(message), .padded(padded));
  sha_mainloop #(.PADDED_SIZE(PADDED_SIZE)) loop (.padded(padded), .hashed(hashed), .clk(clk), .rst(rst), .done(done));
endmodule // sha_256


// sha_padder
`define PACK_ARRAY(PK_WIDTH,PK_LEN,PK_SRC,PK_DEST)    genvar pk_idx; generate for (pk_idx=0; pk_idx<(PK_LEN); pk_idx=pk_idx+1) begin; assign PK_DEST[((PK_WIDTH)*pk_idx+((PK_WIDTH)-1)):((PK_WIDTH)*pk_idx)] = PK_SRC[pk_idx][((PK_WIDTH)-1):0]; end; endgenerate
`define UNPACK_ARRAY(PK_WIDTH,PK_LEN,PK_DEST,PK_SRC)  genvar unpk_idx; generate for (unpk_idx=0; unpk_idx<(PK_LEN); unpk_idx=unpk_idx+1) begin; assign PK_DEST[unpk_idx][((PK_WIDTH)-1):0] = PK_SRC[((PK_WIDTH)*unpk_idx+(PK_WIDTH-1)):((PK_WIDTH)*unpk_idx)]; end; endgenerate

module sha_padder	#(
  parameter MSG_SIZE = 24,		// size of full message
  parameter PADDED_SIZE = 512
)(
  input logic [MSG_SIZE-1:0] message,
  output logic [PADDED_SIZE-1:0] padded
);

  localparam zero_width = PADDED_SIZE-MSG_SIZE-1-64;
  localparam back_0_width = 64-$bits(MSG_SIZE);

  assign padded = {message, 1'b1, {zero_width{1'b0}}, {back_0_width{1'b0}}, MSG_SIZE};
endmodule //sha_padder


// sha_mainloop
module sha_mainloop	#(
  parameter PADDED_SIZE = 512
)(
  input logic [PADDED_SIZE-1:0] padded,
  input logic clk, rst,
  output logic [255:0] hashed,
  output logic done
);

  function [31:0] K;
    input [6:0] x;
    K = k[2047-x*32 -: 32];
  endfunction

  function automatic [31:0] W;
    input [6:0] x;
    input [6:0] y;
    if(^x === 1'bX) W = 32'h777;
    else W = (x<16) ? padded[((PADDED_SIZE-1-y*512)-x*32) -: 32] : rho1(W(x-2, y)) + W(x-7, y) + rho0(W(x-15, y)) + W(x-16, y);
  endfunction

  function automatic [31:0] rho0;
    input [31:0] x;
    if(^x === 1'bX) rho0 = 32'h888;
    else rho0 = {x[6:0],x[31:7]} ^ {x[17:0],x[31:18]} ^ (x >> 3);
  endfunction

  function automatic [31:0] rho1;
    input [31:0] x;
    if(^x === 1'bX) rho1 = 32'h888;
    else rho1 = {x[16:0],x[31:17]} ^ {x[18:0],x[31:19]} ^ (x >> 10);
  endfunction

  function [31:0] ch;
    input [31:0] x,y,z;
    if(^x === 1'bX) ch = 32'h888;
    else ch = (x & y) ^ (~x & z);
  endfunction

  function [31:0] maj;
    input [31:0] x,y,z;
    if(^x === 1'bX) maj = 32'h888;
    else maj = (x & y) ^ (x & z) ^ (y & z);
  endfunction

  function [31:0] sum0;
    input [31:0] x;
    if(^x === 1'bX) sum0 = 32'h888;
    else sum0 = {x[1:0],x[31:2]} ^ {x[12:0],x[31:13]} ^ {x[21:0],x[31:22]};
  endfunction

  function [31:0] sum1;
    input [31:0] x;
    if(^x === 1'bX) sum1 = 32'h888;
    else sum1 = {x[5:0],x[31:6]} ^ {x[10:0],x[31:11]} ^ {x[24:0],x[31:25]};
  endfunction

  logic [255:0] initial_hashes = {32'h6a09e667, 32'hbb67ae85, 32'h3c6ef372, 32'ha54ff53a, 32'h510e527f, 32'h9b05688c, 32'h1f83d9ab, 32'h5be0cd19};
  
  logic [2047:0] k = {32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5, 32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5, 32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3, 32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174, 32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc, 32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da, 32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7, 32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967, 32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13, 32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85, 32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3, 32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070, 32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5, 32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3, 32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208, 32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2};

  logic [31:0] a, b, c, d, e, f, g, h, t1, t2;
  logic [31:0] h1, h2, h3, h4, h5, h6, h7, h8;

  logic [6:0] j;
  logic [6:0] i;

  localparam N = PADDED_SIZE/512; // number of blocks
  
  logic [31:0] ch_efg, maj_abc, sum0_a, sum1_e, kj, wj;

  always_comb begin
    ch_efg = ch(e,f,g);
    maj_abc = maj(a,b,c);
    sum0_a = sum0(a);
    sum1_e = sum1(e);
    wj = W(j, i);
    kj = K(j);
  end

  always @(negedge clk) begin
    // t1 <= h + sum1(e) + ch(e,f,g) + K(j) + W(j);
    // t2 <= sum0(a) + maj(a,b,c);
    t1 <= (h + sum1_e + ch_efg + kj + wj)%4294967296;
    t2 <= (sum0_a + maj_abc)%4294967296;
  end

  always @(posedge clk or posedge rst) begin
    if(rst) begin
      i 	<= 1'b0;
      j 	<= 1'bX;
      h1 	<= 32'h6a09e667;
      h2 	<= 32'hbb67ae85;
      h3 	<= 32'h3c6ef372;
      h4 	<= 32'ha54ff53a;
      h5 	<= 32'h510e527f;
      h6 	<= 32'h9b05688c;
      h7 	<= 32'h1f83d9ab;
      h8 	<= 32'h5be0cd19;
    end
    else if (^j === 1'bX && ^i !== 1'bX) begin
      a <= h1;
      b <= h2;
      c <= h3;
      d <= h4;
      e <= h5;
      f <= h6;
      g <= h7;
      h <= h8;
      j <= 1'd0;
    end
    else if (j < 64) begin
      h <= g;
      g <= f;
      f <= e;
      e <= (d+t1)%4294967296;
      d <= c;
      c <= b;
      b <= a;
      a <= (t1+t2)%4294967296;
      j <= j+1;
    end
    else if (j == 64) begin
      h1 <= a + h1;
      h2 <= b + h2;
      h3 <= c + h3;
      h4 <= d + h4;
      h5 <= e + h5;
      h6 <= f + h6;
      h7 <= g + h7;
      h8 <= h + h8;
      j <= 1'bX;
      if (i<N-1) i <= i+1;
      else begin
        i <= 1'bX;
        done <= 1'b1;
      end
    end
  end

  assign hashed = {h1, h2, h3, h4, h5, h6, h7, h8};
endmodule // sha_mainloop

`default_nettype wire
