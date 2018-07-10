module tomasulo(KEY,LEDR,LEDG,HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7);
	input [0:0]KEY;
	output [17:0]LEDR;
	output [8:0]LEDG;
	output [6:0]HEX0,HEX1,HEX2,HEX3,HEX4,HEX5,HEX6,HEX7;
	wire [8:0]Regs[3:0];
	wire [2:0]label_add;
	wire [2:0]label_mult;
	wire [2:0] Add_full;
	wire [20:0] Tempo;
	wire [8:0] inst;
	controle c1(KEY[0],inst,Regs[0],Regs[1],Regs[2],Regs[3],label_add,Tempo,Add_full,Mult_full);
	sete_seg add(add_full,HEX5);
	sete_seg	mult(Mult_full,HEX4);
	sete_seg reg0(Regs[0],HEX0);
	sete_seg reg1(Regs[1],HEX1);
	sete_seg reg2(Regs[2],HEX2);
	sete_seg reg3(Regs[3],HEX3);
	//assign LEDR[7:0] = label_add;
	assign LEDR[8:0] = inst;
	assign LEDG = Tempo[7:0];
endmodule
	