`timescale 1ns / 1ps

module spi_memory_interface_tb;

    // Señales de entrada
    reg clk;
    reg rst;
    reg [31:0] cpu_addr;
    reg [31:0] cpu_wdata;
    reg [3:0] cpu_wstrb;
    reg cpu_valid;
    reg cpu_instr;

    // Señales de salida
    wire mem_ready;
    wire [31:0] mem_rdata;

    // Registros SPI
    wire [31:0] SPI_BITRATE;
    wire [31:0] SPI_DATA_OUT;
    reg [31:0] SPI_DATA_IN;
    wire [7:0] SPI_CTRL;

    // Instancia del módulo
    spi_memory_interface uut (
        .clk(clk),
        .rst(rst),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),
        .cpu_wstrb(cpu_wstrb),
        .cpu_valid(cpu_valid),
        .cpu_instr(cpu_instr),
        .mem_ready(mem_ready),
        .mem_rdata(mem_rdata),
        .SPI_BITRATE(SPI_BITRATE),
        .SPI_DATA_OUT(SPI_DATA_OUT),
        .SPI_DATA_IN(SPI_DATA_IN),
        .SPI_CTRL(SPI_CTRL)
    );

    // Generador de reloj
    initial clk = 0;
    always #5 clk = ~clk; // Periodo de 10 ns (100 MHz)

    // Proceso de prueba
    initial begin
    
    $dumpfile("spi_memory_interfacee.vcd");
    $dumpvars;
    $monitor($time, "clk=%b,rst=%b,cpu_addr=%b, cpu_wdata=%b, cpu_wstrb=%b, cpu_valid=%b, cpu_instr=%b, mem_ready=%b, mem_rdata=%b, SPI_BITRATE=%b, SPI_DATA_OUT=%b, SPI_DATA_IN=%b, SPI_CTRL=%b",
	clk,rst,cpu_addr,cpu_wdata,cpu_wstrb,cpu_valid,cpu_instr,mem_ready,mem_rdata,SPI_BITRATE,SPI_DATA_OUT,SPI_DATA_IN,SPI_CTRL);
        // Inicialización
        rst = 1;
        cpu_addr = 0;
        cpu_wdata = 0;
        cpu_wstrb = 0;
        cpu_valid = 0;
        cpu_instr = 0;
        SPI_DATA_IN = 32'hA5A5A5A5; // Dato de prueba para lectura de SPI_DATA_IN

        #20;
        rst = 0;

        // Escritura de todos los bytes en SPI_BITRATE
        #10;
        cpu_addr = 32'h20; // Dirección de SPI_BITRATE
        cpu_wdata = 32'h12345678;
        cpu_wstrb = 4'b1111; // Escritura completa
        cpu_valid = 1;
        #10;
        cpu_valid = 0;

        // Escritura parcial (bytes altos) en SPI_BITRATE
        #10;
        cpu_addr = 32'h20;
        cpu_wdata = 32'h87654321;
        cpu_wstrb = 4'b1100; // Escribir solo bytes altos
        cpu_valid = 1;
        #10;
        cpu_valid = 0;

        // Lectura de SPI_BITRATE
        #10;
        cpu_addr = 32'h20;
        cpu_wstrb = 4'b0000; // Lectura
        cpu_valid = 1;
        #10;
        cpu_valid = 0;

        // Escritura parcial (bytes bajos) en SPI_DATA_OUT
        #10;
        cpu_addr = 32'h21; // Dirección de SPI_DATA_OUT
        cpu_wdata = 32'h87654321;
        cpu_wstrb = 4'b0011; // Escribir solo bytes bajos
        cpu_valid = 1;
        #10;
        cpu_valid = 0;

        // Lectura de SPI_DATA_OUT
        #10;
        cpu_addr = 32'h21;
        cpu_wstrb = 4'b0000; // Lectura
        cpu_valid = 1;
        #10;
        cpu_valid = 0;

        // Escritura de un byte específico en SPI_CTRL
        #10;
        cpu_addr = 32'h23; // Dirección de SPI_CTRL
        cpu_wdata = 32'h000000FF;
        cpu_wstrb = 4'b0001; // Escribir solo el byte menos significativo
        cpu_valid = 1;
        #10;
        cpu_valid = 0;

        // Lectura de SPI_CTRL
        #10;
        cpu_addr = 32'h23;
        cpu_wstrb = 4'b0000; // Lectura
        cpu_valid = 1;
        #10;
        cpu_valid = 0;

        // Finalizar simulación
        #50;
        $finish;
    end

endmodule

