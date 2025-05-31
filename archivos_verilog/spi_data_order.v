module spi_data_order#(
	parameter DATA_WIDTH = 32
)(
	input rst,
	input en,
	input [DATA_WIDTH-1:0] SPI_DATA_IN,
	input SPI_BIT_ORDER,
	output reg [DATA_WIDTH-1:0] SPI_DATA_OUT
);
	//Se cambia el orden de los bits segun SPI_BIT_ORDER

	integer i;
	always @(*) 
	begin
	if (rst) begin
	    SPI_DATA_OUT <= 0;
	end else begin
	  if (en) begin
	   if (SPI_BIT_ORDER) begin
	   	for (i = 0; i < DATA_WIDTH; i = i+1) begin
	   	   SPI_DATA_OUT[i] <= SPI_DATA_IN[DATA_WIDTH - 1 - i];
	   	end
	   end else begin
	   	SPI_DATA_OUT <= SPI_DATA_IN;
	       end
	  end 
	end
	end

endmodule
