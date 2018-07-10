/*
	Essa classe contém a estação de reserva nesse projeto foi colocado:
		* 3 estações para ADD_SUB
		* 3 estações para MUL_Div
		Na primeira parte do codigo temos a implementação da estação para add_sub;
		Na segunda parte tempos a implentação da estação para mult_div;
		Na terceira temos a resolução para os hazards
		
		Foi escolhido 9 bits para instruções:
			insttrução -> 0-2
				000 - add
				001 - sub
				010 - mul
				011 - div
			regy -> 3-5
			regx -> 6-8
*/
module controle(clk,inst_saida,regs_s0,regs_s1,regs_s2,regs_s3,label_add_saida,Tempo,Add_full_saida,Mult_full_saida);
		input clk;
	/* ____4 instruções____*/
		parameter SOM = 3'b000;
		parameter SUB = 3'b001;
		parameter MUL = 3'b010;
		parameter DIV = 3'b011;
	/*_____________________*/
		integer i,j;	
		wire [20:0]Time;
		reg breakLoop;
		reg [20:0]minInputTime;
		reg firstInst,firstInstMulDiv;
		output reg [8:0]inst_saida;
		output reg [8:0]regs_s0,regs_s1,regs_s2,regs_s3;
		output reg [2:0]label_add_saida;
		output reg [20:0]Tempo;
		output reg [2:0] Add_full_saida;
		output reg [2:0] Mult_full_saida;
		
	//Variaveis para instruções novas
		wire [8:0]InInst;
		wire [3:0]InputX,InputY,InputI;
		assign InputX = InInst[8:6];
		assign InputY = InInst[5:3];
		assign InputI = InInst[2:0];
	
	//Controle da estação
		reg [2:0]AddSubFull,MulDivFull;
	
	//Done de cada FU
		wire DoneMulDiv,DoneAddSub;
	//Variaveis para FU de soma e subtração
		reg Runaddsum;
		reg [2:0]AddSubOp,InputX_AddSub,InLabelAddSub;
		wire [2:0]AddressAddSubX,LabelAddSub;
		reg [8:0]RegAddSubX,RegAddSubY;
		wire [8:0]ResultAddSub;
	//Variaveis para a FU de Multiplicação e Divisão
		reg RUNMulDiv;
		reg [2:0]OpMulDiv,InMulDivX,InLabelMulDiv;
		wire [2:0]AddressMulDivX,LabelMulDiv;
		reg [8:0]RegMulDivX,RegMulDivY;
		wire [8:0]ResultMulDiv;
	
	
	//Variaveis para controle do registrador
		wire [8:0]Tags[6:0];
		wire [8:0]Regs[6:0];
		reg updateData[6:0];
		reg updateLabel[6:0];
		reg [8:0]newData, newLabel; 
	
	//Variaveis da estação de reserva
		reg [0:0]Busy[5:0];
		reg [8:0]ValueI[5:0];
		reg [8:0]ValueJ[5:0];
		reg [8:0]TagI[5:0];
		reg [8:0]TagJ[5:0];	
		reg [8:0]Insts[5:0];
		reg Exec[5:0];
		reg [20:0]InputTime[5:0];
	/*Variaveis para intruções
		I - Inst
		X - Regx
		Y - RegY
	*/
		wire [3:0]I,X,Y; 
	
	initial begin
		InputTime[LabelAddSub]=11111111111111111111;
		AddSubFull = 0;
		MulDivFull = 0;
		firstInst = 1;
		Runaddsum = 0;
		RUNMulDiv = 0;
		firstInstMulDiv = 1;
		for(i = 0; i <= 6; i = i + 1) begin
			updateLabel[i] = 0;
			updateData[i] = 0;
		end
		for(i = 0; i <= 5; i = i + 1) begin
			Busy[i] = 0;
			Exec[i] = 0;
		end
	end
	
	always @(clk) begin
		breakLoop = 0;
		for(i = 0; i <= 6; i = i + 1) begin
			updateLabel[i] = 0;
			updateData[i] = 0;
		end
		@(posedge clk) begin
		
		regs_s0=Regs[0];
		regs_s1=Regs[1];
		regs_s2=Regs[2];
		regs_s3=Regs[3];
		label_add_saida=LabelAddSub;
		Tempo=Time;
		Add_full_saida=AddSubFull;
		Mult_full_saida=MulDivFull;
		inst_saida=InInst;
		/*
			Temos duas estações,cada estação verifica se a estação estiver cheia, se não tiver adiciona uma instrução;
			Após isso ele verifica se o registrador está pronto, se ele estiver passa o valor, se não atualiza a tag;		
		*/
	// Estação de reserva ADD_SUB
		if(AddSubFull != 3 && (InputI == SOM || InputI == SUB)) begin
		//Passa  por toda a estação 0-3
			for(i = 0; i <= 2 && breakLoop != 1; i = i + 1) begin 
				if(Busy[i] == 0) 
					begin
							Busy[i] = 1;
							Exec[i] = 0;
							Insts[i] = InInst;
							InputTime[i] = Time;
						if(Tags[InputX] == 9'b111111111) 
							begin
								ValueI[i] = Regs[InputX];
								TagI[i] = 9'b111111111;
							end
						else 
							begin
								TagI[i] = Tags[InputX]; 
								ValueI[i] = 9'b111111111;
							end
						if(Tags[InputY] == 9'b111111111) 
							begin
								ValueJ[i] = Regs[InputY];
								TagJ[i] = 9'b111111111;
							end
						else 
							begin
								TagJ[i] = Tags[InputY]; 
								ValueJ[i] = 9'b111111111;
							end
					newLabel = i;
					updateLabel[InputX] = 1;
					AddSubFull = AddSubFull + 1;
					breakLoop = 1; // Variavel para parar de percorrer
				end
			end
		end
		breakLoop = 0;
		//Estação de reverva mul_Div
		if(MulDivFull != 3 && (InputI == MUL || InputI == DIV)) 
			begin
				for(i = 3; i <= 5 && breakLoop != 1; i = i + 1) 
					begin
						if(Busy[i] == 0) 
							begin
								Busy[i] = 1;
								Exec[i] = 0;
								Insts[i] = InInst;
								InputTime[i] = Time;
								if(Tags[InputX] == 9'b111111111) 
									begin
										ValueI[i] = Regs[InputX];
										TagI[i] = 9'b111111111;
									end
								else 
									begin
										TagI[i] = Tags[InputX]; 
										ValueI[i] = 9'b111111111;
									end
								if(Tags[InputY] == 9'b111111111) 
									begin
										ValueJ[i] = Regs[InputY];
										TagJ[i] = 9'b111111111;
									end
								else 	
									begin
										TagJ[i] = Tags[InputY]; 
										ValueJ[i] = 9'b111111111;
									end

					newLabel = i;
					updateLabel[InputX] = 1;
					MulDivFull = MulDivFull + 1;
					breakLoop = 1;
				end
			end
		end
		end
		
		//Observar essa parte::BUG
		//Controle de hazard
		// Esse primeiro controle de hazard é para resolver a escrita do cdb quando duas FU acabam no msm tempo;
		// Se enquadrar nesse caso verifica-se õ tempo que a instrução está sendo rodada;
		if(DoneAddSub && DoneMulDiv) 
			begin
				if(InputTime[LabelAddSub] < InputTime[LabelMulDiv])
					begin
						Runaddsum = 0;
						newData = ResultAddSub;
						updateData[AddressAddSubX] = 1;
						Busy[LabelAddSub] = 0;
						if(!(AddressAddSubX == InputX) && (Tags[AddressAddSubX] == LabelAddSub))
							begin
								wait(updateLabel[0] || updateLabel[1]||updateLabel[2]||updateLabel[3]||updateLabel[4]|| updateLabel[5]||updateLabel[6] == 0) #1  updateLabel[AddressAddSubX] = 1;
								newLabel = 9'b111111111;
							end

							if(AddSubFull != 0 && DoneAddSub)
								AddSubFull = AddSubFull - 1;
							minInputTime = 9'b111111111;
							
							for(i = 0; i <= 5; i = i + 1) 
							begin	
								if(TagI[i] == LabelAddSub) begin
									TagI[i] = 9'b111111111;
									ValueI[i] = ResultAddSub; 
								end
							if(TagJ[i] == LabelAddSub) begin
								TagJ[i] = 9'b111111111;
								ValueJ[i] = ResultAddSub; 
							end
				end

				for(i = 0; i <= 2; i = i + 1) begin
					if(Exec[i] == 0 && ((ValueI[i] != 9'b111111111) && (ValueJ[i] != 9'b111111111))) begin
						if(minInputTime == 9'b111111111) minInputTime = i;
						else if(InputTime[minInputTime] > InputTime[i]) 
							minInputTime = i; 
						end
				end
				if(minInputTime != 9'b111111111) begin
					Exec[minInputTime] = 1;
					AddSubOp = Insts[minInputTime][2:0];
						RegAddSubY = ValueJ[minInputTime];
						RegAddSubX = ValueI[minInputTime];
					
					InputX_AddSub = Insts[minInputTime][8:6];
					InLabelAddSub = minInputTime;
					Runaddsum = 1;
				end
			end
			else begin
				RUNMulDiv = 0;
				newData = ResultMulDiv;
				updateData[AddressMulDivX] = 1;
				Busy[LabelMulDiv] = 0;
				if(!(AddressMulDivX == InputX) && (Tags[AddressMulDivX] == LabelMulDiv))begin
					wait( updateLabel[0] || updateLabel[1]||updateLabel[2]||updateLabel[3]||updateLabel[4]|| updateLabel[5]||updateLabel[6] == 0) #1 updateLabel[AddressMulDivX] = 1;
					newLabel = 9'b111111111;
				end

				if(MulDivFull != 0 && DoneMulDiv)
					MulDivFull = MulDivFull - 1;
				minInputTime = 9'b111111111;
				
				for(i = 0; i <= 5; i = i + 1) begin	
					if(TagI[i] == LabelMulDiv) begin
						TagI[i] = 9'b111111111;
						ValueI[i] = ResultMulDiv;  
					end
					if(TagJ[i] == LabelMulDiv) begin
						TagJ[i] = 9'b111111111;
						ValueJ[i] = ResultMulDiv;
					end
				end

				for(i = 2 + 1; i <= 5; i = i + 1) begin
					if(Exec[i] == 0 && ((ValueI[i] != 9'b111111111 ) && (ValueJ[i] != 9'b111111111 ))) begin
						if(minInputTime == 9'b111111111) minInputTime = i;
						else if(InputTime[minInputTime] > InputTime[i]) minInputTime = i; 
					end
				end
				if(minInputTime != 9'b111111111) begin
					Exec[minInputTime] = 1;
					OpMulDiv = Insts[minInputTime][2:0];
						RegMulDivY = ValueJ[minInputTime];
						RegMulDivX = ValueI[minInputTime];
					
					InMulDivX = Insts[minInputTime][8:6];
					InLabelMulDiv = minInputTime;
					RUNMulDiv = 1;
				end
			end
		end
		else begin
			if(DoneAddSub || (firstInst) || !Runaddsum)begin
				minInputTime = 9'b111111111;
				if(DoneAddSub) begin
					Runaddsum = 0;
					newData = ResultAddSub;
					updateData[AddressAddSubX] = 1;
					Busy[LabelAddSub] = 0;
					if(!(AddressAddSubX == InputX) && (Tags[AddressAddSubX] == LabelAddSub))begin
						wait( updateLabel[0] || updateLabel[1]||updateLabel[2]||updateLabel[3]||updateLabel[4]|| updateLabel[5]||updateLabel[6] == 0) #1  updateLabel[AddressAddSubX] = 1;
						newLabel = 9'b111111111;
					end

					if(AddSubFull != 0 && DoneAddSub)
						AddSubFull = AddSubFull - 1;
					
					
					for(i = 0; i <= 5; i = i + 1) begin	
						if(TagI[i] == LabelAddSub) begin
							TagI[i] = 9'b111111111;
							ValueI[i] = ResultAddSub;  
						end
						if(TagJ[i] == LabelAddSub) begin
							TagJ[i] = 9'b111111111;
							ValueJ[i] = ResultAddSub; 
						end
					end
				end

				for(i = 0; i <= 2; i = i + 1) begin
					if(Exec[i] == 0 && ((ValueI[i] != 9'b111111111) && (ValueJ[i] != 9'b111111111))) begin
						if(minInputTime == 9'b111111111) minInputTime = i;
						else if(InputTime[minInputTime] > InputTime[i]) minInputTime = i; 
					end
				end
				if(minInputTime != 9'b111111111) begin
					firstInst = 0;
					Exec[minInputTime] = 1;
					AddSubOp = Insts[minInputTime][2:0];
						RegAddSubY = ValueJ[minInputTime];
						RegAddSubX = ValueI[minInputTime];
					
					InputX_AddSub = Insts[minInputTime][8:6];
					InLabelAddSub = minInputTime;
					Runaddsum = 1;
				end
			end
			if(DoneMulDiv || (firstInstMulDiv) || !RUNMulDiv)begin
				minInputTime = 9'b111111111;
				if(DoneMulDiv) begin
					RUNMulDiv = 0;
					
					newData = ResultMulDiv;
					updateData[AddressMulDivX] = 1;
					Busy[LabelMulDiv] = 0;
					if(!(AddressMulDivX == InputX) && (Tags[AddressMulDivX] == LabelMulDiv))begin
						wait( updateLabel[0] || updateLabel[1]||updateLabel[2]||updateLabel[3]||updateLabel[4]|| updateLabel[5]||updateLabel[6] == 0) #1 updateLabel[AddressMulDivX] = 1;
						newLabel = 9'b111111111;
					end

					if(MulDivFull != 0 && DoneMulDiv)
						MulDivFull = MulDivFull - 1;
					minInputTime = 9'b111111111;
					
					for(j = 0; j <= 5; j = j + 1) begin	
						if(TagI[j] == LabelMulDiv) begin
							TagI[j] = 9'b111111111;
							ValueI[j] = ResultMulDiv;  
						end
						if(TagJ[j] == LabelMulDiv) begin
							TagJ[j] = 9'b111111111;
							ValueJ[j] = ResultMulDiv; 
						end
					end
				end
				for(j = 2 + 1; j <= 5; j = j + 1) begin
					if(Exec[j] == 0 && ((ValueI[j] != 9'b111111111 ) && (ValueJ[j] != 9'b111111111 ))) begin
						if(minInputTime == 9'b111111111)
							begin 
								minInputTime = j; 
							end
						else if(InputTime[minInputTime] > InputTime[j]) 
							minInputTime = j; 
					end
				end
				if(minInputTime != 9'b111111111) begin
					firstInstMulDiv = 0;
					Exec[minInputTime] = 1;
					OpMulDiv = Insts[minInputTime][2:0];
						RegMulDivY = ValueJ[minInputTime];
						RegMulDivX = ValueI[minInputTime];
					
					InMulDivX = Insts[minInputTime][8:6];
					InLabelMulDiv = minInputTime;
					RUNMulDiv = 1;
				end
			end
		end
	end
	// Instancia a galera;
	registradorD r0(clk,newData,updateData[0],newLabel,updateLabel[0],Tags[0],Regs[0]);
	registradorD r1(clk,newData,updateData[1],newLabel,updateLabel[1],Tags[1],Regs[1]);
	registradorD r2(clk,newData,updateData[2],newLabel,updateLabel[2],Tags[2],Regs[2]);
	registradorD r3(clk,newData,updateData[3],newLabel,updateLabel[3],Tags[3],Regs[3]);
	Count_tomasulo my_time(clk,Time);
	FU_add_sub FU_add(clk,Runaddsum,RegAddSubX,RegAddSubY,AddSubOp,ResultAddSub,DoneAddSub,InputX_AddSub,InLabelAddSub,AddressAddSubX,LabelAddSub);
	FU_mul_div FU_mul(clk,RUNMulDiv,RegMulDivX,RegMulDivY,OpMulDiv,ResultMulDiv,DoneMulDiv,InMulDivX,InLabelMulDiv,AddressMulDivX,LabelMulDiv);
	iQueue instrucoes(clk,0,InInst,AddSubFull,MulDivFull);
	
endmodule