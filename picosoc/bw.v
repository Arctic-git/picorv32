/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Claire Xenia Wolf <claire@yosyshq.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

module bw (
	input clk_100m,

	output ser_tx,
	input ser_rx,

	output [3:0] leds,

	output flash_csb,
	output flash_clk,
	inout  flash_io0,
	inout  flash_io1,
	// inout  flash_io2,
	// inout  flash_io3,

	// output debug_ser_tx,
	// output debug_ser_rx,


);
	reg [7:0] reset_cnt = 0;
	
	wire clk;
	wire pll_lock;

	SB_PLL40_CORE #(
					.FEEDBACK_PATH("SIMPLE"),
					.PLLOUT_SELECT("GENCLK"),
					.DIVR(4),
					.DIVF(31),
					.DIVQ(5),
					.FILTER_RANGE(2)
				) pll_20MHz (
					.RESETB(1'b1),
					.BYPASS(1'b0),
					.REFERENCECLK(clk_100m),
					.PLLOUTGLOBAL(clk),
					.LOCK(pll_lock)
				);

	always @(posedge clk) begin
		if(pll_lock)
			reset_cnt <= reset_cnt + !resetn;
	end
	wire resetn = &reset_cnt;

	wire flash_io0_oe, flash_io0_do, flash_io0_di;
	wire flash_io1_oe, flash_io1_do, flash_io1_di;

	SB_IO #(
		.PIN_TYPE(6'b 1010_01),
		.PULLUP(1'b 0)
	) flash_io_buf [1:0] (
		.PACKAGE_PIN({flash_io1, flash_io0}),
		.OUTPUT_ENABLE({flash_io1_oe, flash_io0_oe}),
		.D_OUT_0({flash_io1_do, flash_io0_do}),
		.D_IN_0({flash_io1_di, flash_io0_di})
	);

	wire        iomem_valid;
	reg         iomem_ready;
	wire [3:0]  iomem_wstrb;
	wire [31:0] iomem_addr;
	wire [31:0] iomem_wdata;
	reg  [31:0] iomem_rdata;

	reg [31:0] gpio;
	assign leds[3:0] = gpio;

	always @(posedge clk) begin
		if (!resetn) begin
			gpio <= 0;
		end else begin
			iomem_ready <= 0;
			if (iomem_valid && !iomem_ready && iomem_addr[31:24] == 8'h 03) begin
				iomem_ready <= 1;
				iomem_rdata <= gpio;
				if (iomem_wstrb[0]) gpio[ 7: 0] <= iomem_wdata[ 7: 0];
				if (iomem_wstrb[1]) gpio[15: 8] <= iomem_wdata[15: 8];
				if (iomem_wstrb[2]) gpio[23:16] <= iomem_wdata[23:16];
				if (iomem_wstrb[3]) gpio[31:24] <= iomem_wdata[31:24];
			end
		end
	end

	picosoc #(
		.MEM_WORDS(8192/4)
	)soc (
		.clk          (clk         ),
		.resetn       (resetn      ),

		.ser_tx       (ser_tx      ),
		.ser_rx       (ser_rx      ),

		.flash_csb    (flash_csb   ),
		.flash_clk    (flash_clk   ),

		.flash_io0_oe (flash_io0_oe),
		.flash_io1_oe (flash_io1_oe),
		// .flash_io2_oe (flash_io2_oe),
		// .flash_io3_oe (flash_io3_oe),

		.flash_io0_do (flash_io0_do),
		.flash_io1_do (flash_io1_do),
		// .flash_io2_do (flash_io2_do),
		// .flash_io3_do (flash_io3_do),

		.flash_io0_di (flash_io0_di),
		.flash_io1_di (flash_io1_di),
		.flash_io2_di (1'b0),
		.flash_io3_di (1'b0),

		.irq_5        (1'b0        ),
		.irq_6        (1'b0        ),
		.irq_7        (1'b0        ),

		.iomem_valid  (iomem_valid ),
		.iomem_ready  (iomem_ready ),
		.iomem_wstrb  (iomem_wstrb ),
		.iomem_addr   (iomem_addr  ),
		.iomem_wdata  (iomem_wdata ),
		.iomem_rdata  (iomem_rdata )
	);

	// assign debug_ser_tx = ser_tx;
	// assign debug_ser_rx = ser_rx;

	// assign debug_flash_csb = flash_csb;
	// assign debug_flash_clk = flash_clk;
	// assign debug_flash_io0 = flash_io0_di;
	// assign debug_flash_io1 = flash_io1_di;
	// assign debug_flash_io2 = flash_io2_di;
	// assign debug_flash_io3 = flash_io3_di;
endmodule
