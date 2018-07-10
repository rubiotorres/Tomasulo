/*
	Unidade funcional para div/mult
	Levando em conta as latências
 */


module CountDiv(clk,RUN,reset,q);
	input clk,reset,RUN;
	output reg [4:0]q;
	initial
		q = 0;
		
	always@(posedge clk) begin
		if(q == 5 || reset)
			q = 0;
		else if(RUN)
			q = q + 1;
	end
endmodule


module CountMul(clk,RUN,reset,q);
	input clk,reset,RUN;
	output reg [4:0]q;
	initial
		q = 0;
		
	always@(posedge clk) begin
		if(q == 4 || reset)
			q = 0;
		else if(RUN)
			q = q + 1;
	end
endmodule


module FU_mul_div(clk,RUN,RegX,RegY,OpCode,Result,Done,InputX_MulDiv,InputLabel_MulDiv,AddressX,Label);
	input [8:0]RegX,RegY;
	input [2:0]OpCode;
	input clk,RUN;
	output reg Done;
	input [2:0]InputX_MulDiv,InputLabel_MulDiv;
	output [2:0]AddressX,Label;
	output reg [8:0]Result;
	wire [4:0]countDiv;
	wire [4:0]countMul;
	

	assign AddressX = InputX_MulDiv;
	assign Label = InputLabel_MulDiv;
	always@(clk,RegX,RegY,OpCode,RUN) begin
		Done = 0;
		if(countMul == 3 && OpCode == 3'b010) begin
			Result = RegX * RegY; //MUL
			Done = 1;
		end
		else if(countDiv == 4 && OpCode == 3'b011) begin
			Result = RegX / RegY; //DIV 
			Done = 1;
		end

	end
	
	CountMul cm(clk,RUN,Done,countMul);
	CountDiv cd(clk,RUN,Done,countDiv);
endmodule