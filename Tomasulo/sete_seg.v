module sete_seg (Entrada, out);
  input [3:0] Entrada;
  output reg [0:6] out;

  //Decodificador Display de 7 segmentos
  always begin
    case(Entrada)
   4'b0000: out = 7'b1000000;
	4'b0001: out = 7'b1111001;
	4'b0010: out = 7'b0100100;
	4'b0011: out = 7'b0110000;
	4'b0100: out = 7'b0011001;
	4'b0101: out = 7'b0010010;
	4'b0110: out = 7'b0000010;
	4'b0111: out = 7'b1111000;
	4'b1000: out = 7'b0000000;
	4'b1001: out = 7'b0011000;
	default: out = 7'b1000000;

    endcase
  end
endmodule