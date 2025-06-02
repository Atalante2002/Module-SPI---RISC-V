module piso_sipo#(
    parameter DATA_WIDTH = 32  // Ancho de los datos, configurable por el usuario
)(
    input clk,                  // Reloj del sistema
    input rst,                  // Señal de reinicio
    input load,                 // Señal para cargar nuevos datos
    input [DATA_WIDTH-1:0] data_in, // Entrada paralela de datos
    input MISO,                 // Entrada serial para recibir datos
    input [1:0] SPI_DATA_LEN,   // Configuración del ancho de datos SPI
    output reg done,            // Señal que indica cuando la operación ha terminado
    output reg MOSI,            // Salida serial para enviar datos
    output reg [DATA_WIDTH-1:0] data_out // Salida paralela de datos recibidos
);
   
    // Registro de desplazamiento para transmisión y recepción serial
    reg [DATA_WIDTH-1:0] shift_reg;
    reg [$clog2(DATA_WIDTH):0] couter_bit;   // Contador de bits transmitidos/recibidos
    wire [4:0] data_len;                     // Longitud de datos configurada según SPI_DATA_LEN
    
    // Bloque combinacional para cargar datos iniciales y configurar longitud de datos
    assign data_len = (SPI_DATA_LEN == 2'b00) ? 5'd24 :
                      (SPI_DATA_LEN == 2'b01) ? 5'd16 :
                      (SPI_DATA_LEN == 2'b10) ? 5'd8  : 5'd0;  // Para 2'b11 o cualquier otro valor

    // Bloque secuencial principal para manejar el envío y recepción de datos
    always @(posedge clk or posedge rst)
    begin
        if (rst) begin
            // Reset: Inicialización de registros y señales
            shift_reg <= 0;
            couter_bit <= 0;   // Inicializado fuera del rango para detener actividad
            MOSI <= 0;
            data_out <= 0;
            done <= 0;
        end else begin
        if (load) begin
            if (couter_bit == 6'b0) begin
                // Primer ciclo: carga atómica
                MOSI <= data_in[0];
                shift_reg <= data_in >> 1;
                shift_reg[(DATA_WIDTH - data_len)-1] <= MISO;
                couter_bit <= couter_bit + 1;
            end else begin
            if (couter_bit < (DATA_WIDTH - data_len)) begin
                // Ciclos normales
                MOSI <= shift_reg[0];
                shift_reg <= shift_reg >> 1;
                shift_reg[(DATA_WIDTH - data_len)-1] <= MISO;
                couter_bit <= couter_bit + 1;
            end else begin
                // Final de transmisión
                //data_out <= shift_reg >> (DATA_WIDTH - data_len);
                data_out <= shift_reg;
                done <= 1;
                MOSI <= 0;
            end
            end
        end else begin
            // Estado idle
            couter_bit <= 0;
            shift_reg <= 0;
            MOSI <= 0;
            done <= 0;
        end
        end
    end
	
endmodule

