module spi_data_order#(
	parameter DATA_WIDTH = 32
)(
	input [1:0] SPI_DATA_LEN,
	input en,
	input rst,
	input [DATA_WIDTH-1:0] SPI_DATA_IN,
	input SPI_BIT_ORDER,
	output reg [DATA_WIDTH-1:0] SPI_DATA_OUT
);
	//Se cambia el orden de los bits segun SPI_BIT_ORDER
	
	wire [4:0] data_len;
	assign data_len = (SPI_DATA_LEN == 2'b00) ? 5'd24 :
                     (SPI_DATA_LEN == 2'b01) ? 5'd16 :
                     (SPI_DATA_LEN == 2'b10) ? 5'd8  : 5'd0;  // Para 2'b11 o cualquier otro valor	
	
	integer i;
	always @(*) 
	begin
	if (rst) begin
	i = 0;
	SPI_DATA_OUT = 0;
	end else begin
	  //if (en) begin
	   if (SPI_BIT_ORDER) begin
	   	for (i = 0; i < data_len; i = i+1) begin
	   	   SPI_DATA_OUT[i] = SPI_DATA_IN[data_len - 1 - i];
	   	end
	   end else begin
	   	SPI_DATA_OUT = SPI_DATA_IN;
	       end
	  //end 
	end
	end

endmodule
