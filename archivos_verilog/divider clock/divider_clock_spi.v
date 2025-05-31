module divider_clock_spi(
    input clk_cpu,           // Señal de reloj principal del CPU
    input rst,               // Señal de reinicio
    input en,                // Habilitación del divisor de reloj
    input [31:0] spi_bitrate, // Valor del bitrate deseado para SPI (controla la frecuencia del reloj SCK)
    output reg SCK           // Señal de reloj SCK generada
);

    //Se realiza un contador en cada pulso de reloj_CPU que depende del bitrate, 
    //con el fin de generar una nueva señal con una frecuencia dividida comparandola con la de la CPU,
    //esto permite que el usuario tenga control de la velocidad de transmision
	
	
    // Contador para dividir la frecuencia del reloj `clk_cpu`
    integer counter = 0;
	
    // Bloque siempre activo en el flanco positivo del reloj `clk_cpu` o al activarse `rst`
    always @(posedge clk_cpu or posedge rst) 
    begin
        if (rst) begin
            // Reinicio: Inicializar contador y señal SCK
            counter <= 0;
            SCK <= 0;
        end else begin
            if (en) begin
                // Si la habilitación está activa (`en`):
                if (counter == spi_bitrate - 1) begin
                    // Si el contador alcanza el valor deseado (basado en `spi_bitrate`):
                    counter <= 0;       // Reiniciar el contador
                    SCK <= ~SCK;        // Invertir el estado de la señal SCK (generar el siguiente flanco)
                end else begin
                    // Incrementar el contador en cada ciclo
                    counter <= counter + 1;
                end
            end else begin
                // Si no está habilitado (`en`), mantener SCK en bajo
                SCK <= 0;
            end
        end
    end
endmodule

