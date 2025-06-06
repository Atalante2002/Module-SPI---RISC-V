module spi_control_tb;
	reg clk_cpu;
	reg rst;
	reg [31:0] SPI_BITRATE;
	reg [31:0] SPI_DATA_OUT;
	wire [31:0] SPI_DATA_IN;
	reg [8:0] SPI_CTRL;
	wire SCK;
	wire MOSI;
	reg MISO;
	wire SS;
	wire interrpt;
	
	spi_control spi_logic(
		.clk_cpu(clk_cpu),
		.rst(rst),
		.SPI_BITRATE(SPI_BITRATE),
		.SPI_DATA_OUT(SPI_DATA_OUT),
		.SPI_DATA_IN(SPI_DATA_IN),
		.SPI_CTRL(SPI_CTRL),
		.SCK(SCK),
		.MOSI(MOSI),
		.MISO(MISO),
		.SS(SS),
		.interrpt(interrpt)
	);
	
		always
		begin
			#5 clk_cpu = !clk_cpu;
		end
	
	initial 
	begin
	   clk_cpu = 1'b0;
	   //SPI_DATA_LENN = 0;
		$dumpfile("spi_controll.vcd");
		$dumpvars;
		$monitor($time, "clk_cpu=%b,rst=%b, SPI_BITRATE=%b, SPI_DATA_OUT=%b, SPI_DATA_IN=%b, SPI_CTRL=%b, SCK=%b,MOSI=%b, MISO=%b, SS=%b, interrpt=%b", clk_cpu,rst,SPI_BITRATE,SPI_DATA_OUT,SPI_DATA_IN,SPI_CTRL,SCK,MOSI,MISO,SS,interrpt);
	   
	   
	   rst = 1;
	   MISO = 0;
	   SPI_BITRATE = 2;
	   SPI_CTRL = 9'b000000000;
	   SPI_DATA_OUT = 0;

	   
	   #200;
	   rst = 0;
	   #50 SPI_CTRL = 9'b010001100;
	   #100;
	   SPI_DATA_OUT = 9;
	   SPI_CTRL = 9'b110001110;
	   //#30 //SPI_CTRL = 9'b000000000;
	   MISO = 1;
	   #50 MISO=0;
	   #50 MISO=1;
	   #50 MISO=0;
	   SPI_CTRL = 9'b110101100;
	   #1000;
	   
	   /*
	   #500 SPI_CTRL = 9'b100000110;
	   SPI_DATA_OUT = 2147483649;
	   #500 SPI_CTRL = 9'b000000100;
	   #3000;
	   */
	   //SPI_DATA_OUT = 0;
	   //SPI_CTRL = 9'b000000000;
	   //SPI_CTRL = 9'b000000000;

	   //SPI_BITRATE = 10;
	   //SPI_CTRL = 9'b011000000;
	   	$finish;
	end
	
endmodule
