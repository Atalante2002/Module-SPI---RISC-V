module spi_logic_control(
	input clk_cpu,
	input rst,
	input [31:0] SPI_DATA_OUT,
	input [8:0] SPI_CTRL,
	output SCK,
	output SS,
	output reg interrpt,
	
	input clk_divider, //Salida del divisor de reloj
	input done, //para identificar cuando se termina la transmision
	output reg SCK_inter, //SCK interno para la logica de lectura y escritura
	output reg en_SCK, //para habilitar el reloj SCK
	output reg load_data,  //para iniciar la transmision de datos
	
	output [31:0] NEW_SPI_DATA_OUT, //nuevo dato de salida modifcado segun el registro de control
	output [1:0] SPI_DATA_LEN,
	input load_data_in, //para saber cuando hacer el cambio del orden de los bits
	input [31:0] SPI_DATA_IN_I,
	output [31:0] NEW_SPI_DATA_IN //nuevo dato de entrada modifcado segun el registro de control
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
	assign SPI_DATA_LEN = SPI_CTRL[4:3];
	wire SPI_FRAME_START = SPI_CTRL[2];
	wire SPI_START = SPI_CTRL[1];
	wire SPI_I_MSK = SPI_CTRL[0];
	
	
	//se ordena los bist del regisrtro de salida
	spi_data_order #(.DATA_WIDTH(32)) data_order(
		.rst(rst),
		.en(load_data_in),
		.SPI_DATA_IN(SPI_DATA_IN_I),
		.SPI_DATA_OUT(NEW_SPI_DATA_IN),
		.SPI_BIT_ORDER(SPI_BIT_ORDER)
	);
	
	//se ordena los bist del regisrtro de entrada
	spi_data_order #(.DATA_WIDTH(32)) data_order_in(
		.rst(rst),
		.en(load_data),
		.SPI_DATA_IN(SPI_DATA_OUT),
		.SPI_DATA_OUT(NEW_SPI_DATA_OUT),
		.SPI_BIT_ORDER(SPI_BIT_ORDER)
	);
	
	//logica de la maquina estados
	always @(posedge clk_cpu or posedge rst)
	begin
	   if (rst) begin
	   	load_data = 0;
	   	SCK_inter <= 0;
	   	corrent_state <= IDLE;
	   end else begin 
	   	  corrent_state <= next_state;
	       end
	end
	
	assign SS = done;
	assign SCK = (SPI_MODE[1] == 1'b0) ? clk_divider : ~clk_divider; //logica para SCK segun el modo
	
	always @(*) begin
		next_state = corrent_state;
		//logica para el SCK interno el cual maneja el modulo de salida(PISO_SIPO)
		case(SPI_MODE)
			2'b00: SCK_inter <= clk_divider;
			2'b01: SCK_inter <= ~clk_divider;
			2'b10: SCK_inter <= clk_divider;
			2'b11: SCK_inter <= ~clk_divider;
			default: SCK_inter <= clk_divider;
		endcase

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
