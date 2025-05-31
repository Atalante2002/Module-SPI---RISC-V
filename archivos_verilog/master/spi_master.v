module spi_master(
    input clk_cpu,
    input rst,
    input [31:0] cpu_addr,
    input [31:0] cpu_wdata,
    input [3:0] cpu_wstrb, // Control de escritura por byte
    input cpu_valid,
    input cpu_instr,
    output mem_ready,
    output [31:0] mem_rdata,

    //Salidas comunicacion
    output SCK,
    output MOSI,
    input MISO,
    output  SS,
    output  interrpt
    
);

    //Este modulo es el top, contiene la union del modulo de la mememoria nativa con el modulo de la logica de la comunicacion
	
    wire [31:0]   SPI_BITRATE; // 0x20
    wire [31:0]   SPI_DATA_OUT; // 0x21
    wire [31:0]   SPI_DATA_IN;
    wire [8:0]    SPI_CTRL;  // 0x23
    

	spi_memory_interface spi_memory(
		.clk_cpu(clk_cpu),
		.rst(rst),
		.cpu_addr(cpu_addr),
		.cpu_wdata(cpu_wdata),
		.cpu_wstrb(cpu_wstrb),
		.cpu_valid(cpu_valid),
		.cpu_instr(cpu_instr),
		.SPI_BITRATE(SPI_BITRATE),
		.SPI_DATA_OUT(SPI_DATA_OUT),
		.SPI_DATA_IN(SPI_DATA_IN),
		.SPI_CTRL(SPI_CTRL)
	);
	
	spi_logic_master spi_master(
		.clk_cpu(clk_cpu),
		.rst(rst),
		.SPI_BITRATE(SPI_BITRATE),
		.SPI_DATA_OUT(SPI_DATA_OUT),
		.SPI_DATA_IN(SPI_DATA_IN),
		.SPI_CTRL(SPI_CTRL),
		.MOSI(MOSI),
		.MISO(MISO),
		.SCK(SCK),
		.SS(SS),
		.interrpt(interrpt)
	);
	
endmodule
	

	
