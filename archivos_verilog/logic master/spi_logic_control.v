module spi_logic_control(
	input clk_cpu,
	input rst,
	input [31:0] SPI_DATA_OUT,
	input [8:0] SPI_CTRL,
	output SCK,
	output SS,
	output IRQ_SPI,
	
	input clk_divider, //Salida del divisor de reloj
	input done, //para identificar cuando se termina la transmision
	output SCK_inter, //SCK interno para la logica de lectura y escritura
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
	parameter LOAD_DATA = 3'b011;
	parameter DONE = 3'b100;
	
	//variables para manejar los estados
	reg [2:0] corrent_state, next_state;
	reg load_SS;
	
	//Ordenar los bit del registro SPI_CTRL
	wire SPI_ON = SPI_CTRL[8];
	wire [1:0] SPI_MODE = SPI_CTRL[7:6];
	wire SPI_BIT_ORDER = SPI_CTRL[5];
	assign SPI_DATA_LEN = SPI_CTRL[4:3];
	wire SPI_FRAME_START = SPI_CTRL[2];
	wire SPI_START = SPI_CTRL[1];
	wire SPI_I_MSK = SPI_CTRL[0];
	
	
	//reflaxion de los bist del regisrtro de salida
	spi_data_order #(.DATA_WIDTH(32)) data_order(
		.SPI_DATA_LEN(SPI_DATA_LEN),
		.en(load_data_in),
		.rst(rst),
		.SPI_DATA_IN(SPI_DATA_IN_I),
		.SPI_DATA_OUT(NEW_SPI_DATA_IN),
		.SPI_BIT_ORDER(SPI_BIT_ORDER)
	);
	
	//reflaxion de los bist del regisrtro de entrada
	spi_data_order #(.DATA_WIDTH(32)) data_order_in(
		.SPI_DATA_LEN(SPI_DATA_LEN),
		.en(load_data),
		.rst(rst),
		.SPI_DATA_IN(SPI_DATA_OUT),
		.SPI_DATA_OUT(NEW_SPI_DATA_OUT),
		.SPI_BIT_ORDER(SPI_BIT_ORDER)
	);
	
	//logica de la maquina estados
	always @(posedge clk_cpu or posedge rst)
	begin
	   if (rst) begin
	   	corrent_state <= IDLE;
	   end else begin 
	   	  corrent_state <= next_state;
	       end
	end
	
	always @(*) begin
		case (corrent_state)
			IDLE: begin
			load_data = 0;
			load_SS = 1;
			  if (SPI_ON && SPI_FRAME_START) begin
			  	en_SCK = 1;
			  	next_state = LOAD;
			  end else begin 
			  	en_SCK = 0;
			  	next_state = IDLE;
			      end
			end
			
			LOAD: begin
			en_SCK = 1;
			  if (SPI_START) begin
			  	load_data = 1;
			  	load_SS = 0;
			  	next_state = TRANSMIT;
			  end else begin
			  	load_data = 0;
			  	load_SS = 1;
			  	next_state = LOAD;
			      end
			end
			
			TRANSMIT: begin
			load_SS = 1;
			en_SCK = 1;
			load_data = 1;
			next_state = LOAD_DATA;
			end
			
			LOAD_DATA: begin
			  en_SCK = 1;
			  load_data = 1;
			  if (done) begin
			  	load_SS = 1;
			  	next_state = DONE;
			  end else begin 
			  	load_SS = 0;
			  	next_state = LOAD_DATA;
			      end
			  
			end
			
			DONE: begin
			  en_SCK = 1;
			  load_data = 0;
			  load_SS = 1;
			  next_state = IDLE;
			end
			
			default: begin
			en_SCK = 0;
			load_data = 0;
			load_SS = 1;
			next_state = IDLE;
			end
			
		endcase
	end
	
	//logica para el SCK interno el cual maneja el modulo de salida(PISO_SIPO)
	assign SCK_inter = SPI_MODE[0] ? ~clk_divider : clk_divider;
	assign SCK = SPI_MODE[1] ? ~clk_divider : clk_divider; //logica para SCK segun el modo
	assign IRQ_SPI = SPI_I_MSK ? done : 1'b0;
	assign SS = load_SS;
	
endmodule
