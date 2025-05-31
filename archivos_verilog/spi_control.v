module spi_control(
	input clk_cpu,
	input rst,
	input [31:0] SPI_BITRATE,
	input [31:0] SPI_DATA_OUT,
	output wire [31:0] SPI_DATA_IN,
	input [8:0] SPI_CTRL,
	output SCK,
	output wire MOSI,
	input MISO,
	output SS,
	output reg interrpt
);

	//Parametros para los estados de la maquina
	parameter IDLE = 3'b000;
	parameter LOAD = 3'b001;
	parameter TRANSMIT = 3'b010;
	parameter DONE = 3'b011;
	parameter FRAME_STOP = 3'b100;
	
	//variables para manejar los estados
	reg [2:0] corrent_state, next_state;
	
	//Ordenar los bit del registro SPI_CTRL
	wire SPI_ON = SPI_CTRL[8];
	wire [1:0] SPI_MODE = SPI_CTRL[7:6];
	wire SPI_BIT_ORDER = SPI_CTRL[5];
	wire [1:0] SPI_DATA_LEN = SPI_CTRL[4:3];
	wire SPI_FRAME_START = SPI_CTRL[2];
	wire SPI_START = SPI_CTRL[1];
	wire SPI_I_MSK = SPI_CTRL[0];
	
	wire clk_divider; //Salida del divisor de reloj
	wire done;
	reg SCK_inter;
	reg load_data;
	reg en_SCK;
	wire [31:0] NEW_SPI_DATA_OUT;
	
	
	divider_clock_spi clock_divider(
		.clk_cpu(clk_cpu),
		.rst(rst),
		.en(en_SCK),
		.spi_bitrate(SPI_BITRATE),
		.SCK(clk_divider)
	);
	
	piso_sipo #(.DATA_WIDTH(32)) piso_sipo_spi(
		.clk(SCK_inter),
		.rst(rst),
		.load(load_data),
		.data_in(NEW_SPI_DATA_OUT),
		.SPI_DATA_LEN(SPI_DATA_LEN),
		.MISO(MISO),
		.done(done),
		.MOSI(MOSI),
		.data_out(SPI_DATA_IN)
	);
	
	spi_data_order #(.DATA_WIDTH(32)) data_order(
		.rst(rst),
		.en(load_data),
		.SPI_DATA_IN(SPI_DATA_OUT),
		.SPI_DATA_OUT(NEW_SPI_DATA_OUT),
		.SPI_BIT_ORDER(SPI_BIT_ORDER)
	);
	
	assign SS = done;
	
	
	always @(posedge clk_cpu or posedge rst)
	begin
	   if (rst) begin
	   	load_data = 0;
	   	SCK_inter <= 0;
	   	corrent_state <= IDLE;
	   	//SS <= 0;
	   end else begin 
	   	  corrent_state <= next_state;
	   	  //SS <= done;
	       end
	end
	
	
	assign SCK = (SPI_MODE[1] == 1'b0) ? clk_divider : ~clk_divider;
	
	always @(*) begin
		next_state = corrent_state;
		case(SPI_MODE)
			2'b00: SCK_inter <= clk_divider;
			2'b01: SCK_inter <= ~clk_divider;
			2'b10: SCK_inter <= clk_divider;
			2'b11: SCK_inter <= ~clk_divider;
			default: SCK_inter <= clk_divider;
		endcase


		//SS = 1;
		//interrpt = 0;
	   	 		
		case (corrent_state)
			IDLE: begin
			  if (SPI_ON && SPI_FRAME_START) begin
			  	next_state = LOAD;
			  	en_SCK <= 1;
			  end else begin 
			  	en_SCK <= 0;
			      end
			end
			
			LOAD: begin
			  if (SPI_START) begin
			  	load_data = 1;
			  	next_state = TRANSMIT;
			  end
			end
			
			TRANSMIT: begin
			  if (done) begin
			  	next_state = DONE;
			  end else begin 
			  	load_data = 0;
			      end
			end
			
			DONE: begin
			  //interrpt = 1;
			  next_state = IDLE;
			end
		endcase
	end
	
	
endmodule
