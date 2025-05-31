module spi_memory_interface(
    input          clk_cpu,
    input          rst,
    input [31:0]   cpu_addr,
    input [31:0]   cpu_wdata,
    input [3:0]    cpu_wstrb, // Control de escritura por byte
    input          cpu_valid,
    input          cpu_instr,
    output reg          mem_ready,
    output reg [31:0]   mem_rdata,
    
    // Registros SPI
    output reg [31:0]   SPI_BITRATE,  // 0x20
    output reg [31:0]   SPI_DATA_OUT, // 0x21
    input [31:0]   SPI_DATA_IN,  // 0x22
    output reg [8:0]    SPI_CTRL      // 0x23
);

    //Este modulo se encarga de transimitir los registro segun la necesidd del usuario la modulo SPI
    //por tanto, se separa la parte de la memoria con la logica de comunicacion

    // Direcciones de los registros
    localparam ADDR_SPI_BITRATE  = 32'h20;
    localparam ADDR_SPI_DATA_OUT = 32'h21;
    localparam ADDR_SPI_DATA_IN  = 32'h22;
    localparam ADDR_SPI_CTRL     = 32'h23;

    // Proceso de transferencia de memoria
    always @(*) begin
        if (rst) begin
            mem_ready   <= 0;
            mem_rdata   <= 0;
            SPI_BITRATE <= 0;
            SPI_DATA_OUT <= 0;
            SPI_CTRL    <= 0;
        end else begin
            if (cpu_valid) begin
                // Escritura
                if (cpu_wstrb != 0) begin
                //dependiendo del registro cpu_wstrb se escribe una cantidad de byte
                    case (cpu_addr)
                        ADDR_SPI_BITRATE: begin
                            SPI_BITRATE <= {
                                cpu_wstrb[3] ? cpu_wdata[31:24] : SPI_BITRATE[31:24],
                                cpu_wstrb[2] ? cpu_wdata[23:16] : SPI_BITRATE[23:16],
                                cpu_wstrb[1] ? cpu_wdata[15:8]  : SPI_BITRATE[15:8],
                                cpu_wstrb[0] ? cpu_wdata[8:0]   : SPI_BITRATE[8:0]
                            };
                        end
                        ADDR_SPI_DATA_OUT: begin
                            SPI_DATA_OUT <= {
                                cpu_wstrb[3] ? cpu_wdata[31:24] : SPI_DATA_OUT[31:24],
                                cpu_wstrb[2] ? cpu_wdata[23:16] : SPI_DATA_OUT[23:16],
                                cpu_wstrb[1] ? cpu_wdata[15:8]  : SPI_DATA_OUT[15:8],
                                cpu_wstrb[0] ? cpu_wdata[8:0]   : SPI_DATA_OUT[8:0]
                            };
                        end
                        ADDR_SPI_CTRL: begin
                            //el registro de control es de 9 bits, por tanto, se escribe en todos siempre
                            SPI_CTRL <= {
                                cpu_wstrb[0] ? cpu_wdata[8:0] : SPI_CTRL[8:0]
                            };
                        end
                        default: ;
                    endcase
                end
                // Lectura
                else begin
                    //Segun la direccion se devuelve el registro correspodiente
                    case (cpu_addr)
                        ADDR_SPI_BITRATE:  mem_rdata <= SPI_BITRATE;
                        ADDR_SPI_DATA_OUT: mem_rdata <= SPI_DATA_OUT;
                        ADDR_SPI_DATA_IN:  mem_rdata <= SPI_DATA_IN;
                        ADDR_SPI_CTRL:     mem_rdata <= {24'b0, SPI_CTRL};
                        default:           mem_rdata <= 32'h0;
                    endcase
                end
                mem_ready <= 1; // Confirmar transferencia
            end else begin
                mem_ready <= 0; // Sin transferencia activa
            end
        end
    end
endmodule

