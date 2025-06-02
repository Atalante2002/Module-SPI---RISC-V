module spi_logic_master(
	input clk_cpu,
	input rst,
	input [31:0] SPI_BITRATE,
	input [31:0] SPI_DATA_OUT,
	output [31:0] SPI_DATA_IN,
	input [8:0] SPI_CTRL,
	output SCK,
	output MOSI,
	input MISO,
	output SS,
	output IRQ_SPI
);

	//este modulo es para unir toda la parte de logica de la comunicacion SPI

	wire [31:0] NEW_SPI_DATA_OUT;
	wire clk_divider; //Salida del divisor de reloj
	wire done;
	wire SCK_inter;
	wire load_data;
	wire en_SCK;
	wire [1:0] SPI_DATA_LEN;
	
	wire [31:0] SPI_DATA_IN_I;
	
	
	divider_clock_spi clock_divider(
		.clk_cpu(clk_cpu),
		.rst(rst),
		.en(en_SCK),
		.spi_bitrate(SPI_BITRATE),
		.SCK(clk_divider)
	);
	
	piso_sipo #(.DATA_WIDTH(32)) piso_sipo_spi(
		.clk(SCK_inter),
		.rst(rst),
		.load(load_data),
		.data_in(NEW_SPI_DATA_OUT),
		.SPI_DATA_LEN(SPI_DATA_LEN),
		.MISO(MISO),
		.done(done),
		.MOSI(MOSI),
		.data_out(SPI_DATA_IN_I)
	);
	
	spi_logic_control spi_control(
		.clk_cpu(clk_cpu),
		.rst(rst),
		.load_data(load_data),
		.SPI_DATA_OUT(SPI_DATA_OUT),
		.SPI_CTRL(SPI_CTRL),
		.SCK(SCK),
		.SS(SS),
		.IRQ_SPI(IRQ_SPI),
		.SCK_inter(SCK_inter),
		.en_SCK(en_SCK),
		.done(done),
		.SPI_DATA_LEN(SPI_DATA_LEN),
		.NEW_SPI_DATA_OUT(NEW_SPI_DATA_OUT),
		.clk_divider(clk_divider),
		.SPI_DATA_IN_I(SPI_DATA_IN_I),
		.NEW_SPI_DATA_IN(SPI_DATA_IN)
	);
	
endmodule
