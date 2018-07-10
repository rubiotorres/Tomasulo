//	Esse modulo é um buffer que guarda as instruções a serem rodadas no tomasulo
module mem(source,out);
	input [7:0]source;
	output [8:0] out;
	reg [8:0]MEM[127:0];	initial
	begin
/*Hazards e dependências*/
		MEM[0] = 9'b010001000; //R2 = R2 + R1
		MEM[1] = 9'b010001001; //R2 = R2 - R1
		MEM[2] = 9'b001000000; //R1 = R1 + R0
		MEM[3] = 9'b001000000; //R1 = R1 + R0
		MEM[4] = 9'b001000001; //R1 = R1 - R0
		MEM[5] = 9'b000000000; //RO = RO + R0
		MEM[6] = 9'b000001001; //RO = RO - R1


	
/* Teste misto
		MEM[0] = 9'b000001000; //R0 = R0 + R1 (2)
		MEM[1] = 9'b000000010; //R0 = R0 * R0 (4)
		MEM[2] = 9'b001010001; //R1 = R1 - R2 (0)
		MEM[3] = 9'b010001010; //R1 = R1 * R2 (0)
		MEM[4] = 9'b011011000; //R3 = R3 + R3 (2)
		MEM[5] = 9'b000000000; //R0 = R0 + R0 (8)
		MEM[6] = 9'b000011011; //R0 = R0 / R3 (4)
*/
	end
	assign out = MEM[source];
endmodule

module modulePC(clk,clear,stop,pcNow);
  input clk,clear,stop;
  output reg [7:0]pcNow;
  initial
  begin
    pcNow <= 8'b00000000;
  end
  always @(posedge clk)
  begin
    if(clear)
	   pcNow <= 8'b00000000;
	 else if(!stop)
      pcNow <= pcNow + 1;
  end
endmodule
//Modulo de fila de instruções
/*	
	Como é de despacho unico, envia uma instrução por ciclo se a estaçã de reserva tiver lugar
	Caso n tenha espera até liberar;
*/
module iQueue(clk,clear,inst,addSubFull,mulDivFull);
	parameter ADD = 3'b000;
	parameter SUB = 3'b001;
	parameter MUL = 3'b010;
	parameter DIV = 3'b011;
	
	input [2:0]addSubFull,mulDivFull;
	input clk,clear;
	output [8:0]inst;
	wire [7:0]PC;
	reg stop;
	
	wire [2:0]I;
	assign I = inst[2:0];
	
	always @(clk) begin
		stop = 0;
		if(addSubFull == 3 && (I == ADD || I == SUB))begin
			stop = 1;
		end
		if(mulDivFull == 3 && (I == MUL || I == DIV)) begin
			stop = 1;
		end
	end
	modulePC my_pc(clk,clear,stop,PC);
	mem iMem(PC,inst);
	//lpmrom imem(PC,clk,inst);//BUG::Explicado no relatorio
endmodule