module spi_data_order#(
	parameter DATA_WIDTH = 32
)(
	input [1:0] SPI_DATA_LEN,
	input rst,
	input [DATA_WIDTH-1:0] SPI_DATA_IN,
	input SPI_BIT_ORDER,
	output reg [DATA_WIDTH-1:0] SPI_DATA_OUT
);
	//Se cambia el orden de los bits segun SPI_BIT_ORDER
	
	wire [31:0] data_len;
	assign data_len = (SPI_DATA_LEN == 2'b00) ? 32'd24 :
                     	  (SPI_DATA_LEN == 2'b01) ? 32'd16 :
                     	  (SPI_DATA_LEN == 2'b10) ? 32'd8  : 32'd0;  // Para 2'b11 o cualquier otro valor	
	integer i;
	always @(SPI_DATA_IN, rst) begin  // <--- Solo se activa cuando SPI_DATA_IN cambia
        if (rst) begin
            SPI_DATA_OUT <= 0;
        end else begin
            if (SPI_BIT_ORDER) begin
                for (i = 0; i < DATA_WIDTH; i = i+1) begin
                    if (i < (DATA_WIDTH - data_len)) begin
                        SPI_DATA_OUT[i] <= SPI_DATA_IN[(DATA_WIDTH - data_len) - 1 - i];
                    end else begin
                        SPI_DATA_OUT[i] <= 0;
                    end
                end
            end else begin
                SPI_DATA_OUT <= SPI_DATA_IN;
            end
        end
    end

endmodule
