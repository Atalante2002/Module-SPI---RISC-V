`timescale 1ns / 1ps
module divider_clock_spi_tb;

	reg clk_cpu;
	reg rst;
	reg [31:0] spi_bitrate;
	reg en;
	wire SCK;
	
	divider_clock_spi uut_divider_spi(
	    .clk_cpu(clk_cpu),
	    .rst(rst),
	    .spi_bitrate(spi_bitrate),
	    .en(en),
	    .SCK(SCK)
	);
	
	always
		begin
			#5 clk_cpu = !clk_cpu;
		end
	
	initial 
	begin
	   clk_cpu = 1'b0;
	 
		$dumpfile("divider_clock_spii.vcd");
		$dumpvars;
		$monitor($time, "clk_cpu=%b,rst=%b, spi_bitrate=%b, en=%b, SCK=%b", clk_cpu,rst,spi_bitrate,en,SCK);
	   
	   
	   rst = 1;
	   en = 0;
	   spi_bitrate = 6;
	   
	   #20;
	   en = 1;
	   rst = 0;
	   
	   #500;
	   
	   spi_bitrate = 12;
	   #500;
	   
	   	$finish;
	end
endmodule
