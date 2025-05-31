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
    output reg [DATA_WIDTH-1:0] data_out, // Salida paralela de datos recibidos
    output reg load_data_in     // Señal para cargar nuevos datos a `shift_reg`
);

    // Registro de desplazamiento para transmisión y recepción serial
    reg [DATA_WIDTH-1:0] shift_reg;
    reg [$clog2(DATA_WIDTH):0] couter_bit;  // Contador de bits transmitidos/recibidos
    reg [4:0] data_len;                     // Longitud de datos configurada según SPI_DATA_LEN

    // Bloque secuencial principal para manejar el envío y recepción de datos
    always @(posedge clk or posedge rst)
    begin
        if (rst) begin
            // Reset: Inicialización de registros y señales
            shift_reg <= 0;
            couter_bit <= 33;   // Inicializado fuera del rango para detener actividad
            MOSI <= 0;
            data_out <= 0;
            done <= 0;
            data_len <= 0;
            load_data_in <= 0;
        end else begin
            if (couter_bit < (DATA_WIDTH - data_len)) begin
                // Envío y recepción serial:
                MOSI <= shift_reg[(DATA_WIDTH - data_len) - 1]; // Enviar el bit más significativo
                shift_reg <= shift_reg << 1;                   // Desplazar bits a la izquierda
                shift_reg[0] <= MISO;                          // Recibir bit del MISO
                couter_bit <= couter_bit + 1;                  // Incrementar el contador de bits
                load_data_in <= 0;                             // Asegurar que no se recargue `shift_reg`
            end else begin
                // Operación terminada:
                data_out <= shift_reg; // Cargar el contenido recibido en la salida paralela
                done <= 1;             // Indicar que la operación ha finalizado
                MOSI <= 0;             // Deshabilitar la salida serial
                load_data_in <= 1;     // Señal para permitir la recarga de datos
            end
        end
    end

    // Bloque combinacional para cargar datos iniciales y configurar longitud de datos
    always @(*) begin
        if (load) begin
            // Si se activa `load`, cargar los nuevos datos y reiniciar el contador:
            shift_reg = data_in;     // Cargar datos paralelos en el registro
            couter_bit = 0;          // Reiniciar el contador
            MOSI = 0;                // Inicializar salida serial
            done = 0;                // Reiniciar señal de operación terminada
            case (SPI_DATA_LEN)       // Configuración de longitud de datos:
                2'b00: data_len = 24; // 24 bits
                2'b01: data_len = 16; // 16 bits
                2'b10: data_len = 8;  // 8 bits
                2'b11: data_len = 0;  // Completa longitud de 32 bits
                default: data_len = 0;
            endcase
        end 
    end

endmodule

