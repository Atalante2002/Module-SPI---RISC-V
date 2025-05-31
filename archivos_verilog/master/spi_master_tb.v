module spi_master_tb;

    // Señales de entrada
    reg clk_cpu;
    reg rst;
    reg [31:0] cpu_addr;
    reg [31:0] cpu_wdata;
    reg [3:0] cpu_wstrb; // Control de escritura por byte
    reg cpu_valid;
    reg cpu_instr;
    wire mem_ready;
    wire [31:0] mem_rdata;

    //Salidas comunicacion
    wire SCK;
    wire MOSI;
    reg MISO;
    wire SS;
    wire interrpt;

    // Instancia del módulo
    spi_master uut (
        .clk_cpu(clk_cpu),
        .rst(rst),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),
        .cpu_wstrb(cpu_wstrb),
        .cpu_valid(cpu_valid),
        .cpu_instr(cpu_instr),
        .mem_ready(mem_ready),
        .mem_rdata(mem_rdata),
        .SCK(SCK),
        .MOSI(MOSI),
        .MISO(MISO),
        .SS(SS),
        .interrpt(interrpt)
    );

    // Generador de reloj
    initial clk_cpu = 0;
    always #5 clk_cpu = ~clk_cpu; // Periodo de 10 ns (100 MHz)

    // Proceso de prueba
    initial begin
    
    $dumpfile("spi_masterr.vcd");
    $dumpvars;
    $monitor($time, "clk_cpu=%b,rst=%b,cpu_addr=%b, cpu_wdata=%b, cpu_wstrb=%b, cpu_valid=%b, cpu_instr=%b, mem_ready=%b, mem_rdata=%b",
	clk_cpu,rst,cpu_addr,cpu_wdata,cpu_wstrb,cpu_valid,cpu_instr,mem_ready,mem_rdata);
        // Inicialización
        rst = 1;
        cpu_addr = 0;
        cpu_wdata = 0;
        cpu_wstrb = 0;
        cpu_valid = 0;
        cpu_instr = 0;
        MISO = 0;

        #100;
        rst = 0;

        // Escritura de todos los bytes en SPI_BITRATE
        #10;
        cpu_addr = 32'h20; // Dirección de SPI_BITRATE
        cpu_wdata = 2;
        cpu_wstrb = 4'b1111; // Escritura completa
        cpu_valid = 1;
        #10;
        cpu_valid = 0;
        
        #10;
        cpu_addr = 32'h21; // Dirección de SPI_DATA_IN
        cpu_wdata = 32'h8003;
        cpu_wstrb = 4'b1111; // Escritura completa
        cpu_valid = 1;
        #10;
        cpu_valid = 0;
        
        #10;
        cpu_addr = 32'h23; // Dirección de SPI_CTRL
        cpu_wdata = 9'b011101100;
        cpu_wstrb = 4'b1111; // Escritura completa
        cpu_valid = 1;
        #10;
        cpu_valid = 0;
        
        #100;
        cpu_addr = 32'h23; // Dirección de SPI_CTRL
        cpu_wdata = 9'b111101110;
        cpu_wstrb = 4'b1111; // Escritura completa
        cpu_valid = 1;
        #10;
        cpu_valid = 0;
        
        MISO = 1;
	#50 MISO=0;
	#50 MISO=1;
	#50 MISO=0;
        
        // Finalizar simulación
        #2000;
        $finish;
    end

endmodule

