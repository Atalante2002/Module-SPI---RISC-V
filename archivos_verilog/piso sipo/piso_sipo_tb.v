module piso_sipo_tb;
	reg clk;
	reg rst;
	reg load;
	reg [15:0] data_in;
	reg [1:0] SPI_DATA_LEN;
	reg MISO;
	wire done;
	wire MOSI;
	wire [15:0]data_out;
	wire load_data_in;
	
	piso_sipo #(.DATA_WIDTH(16)) uut_piso_spi(
		.clk(clk),
		.rst(rst),
		.load(load),
		.data_in(data_in),
		.SPI_DATA_LEN(SPI_DATA_LEN),
		.MISO(MISO),
		.done(done),
		.MOSI(MOSI),
		.data_out(data_out),
		.load_data_in(load_data_in)
	);
	
	always
		begin
			#5 clk = !clk;
		end
	
	initial 
	begin
	   clk=0;
		$dumpfile("piso_sipoo.vcd");
		$dumpvars;
		$monitor($time, "clk=%b,rst=%b,load=%b, data_in=%b, SPI_DATA_LEN=%b, MISO=%b, done=%b, MOSI=%b, data_out=%b, load_data_in=%b",
			clk,rst,load,data_in,SPI_DATA_LEN,MISO,done,MOSI,data_out,load_data_in);
	   rst=1;
	   load=0;
	   data_in=16'b0;
	   MISO=0;
	   SPI_DATA_LEN = 2'b00;
	   
	   #20 rst=0;
	   SPI_DATA_LEN = 2'b01;
	   //load=1; 
	   data_in=16'b0010010011111111;
	   #20 MISO = 1;
	   #20 MISO=0;
	   #20 MISO=1;
	   #20 MISO=0;
	   
	   #200 load=1;
	   #10 load=0;
	   //wait(done);
	   
	   data_in=16'b1010101010101010;
	   #200 load=1;
	   #10 load=0;
	   #100;
	   
	   $finish;
	   
	end
	
	
endmodule
