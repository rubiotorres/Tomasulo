module Count_tomasulo(clk,q);
	input clk;
	output reg [20:0]q;
	initial
		q = 0;
		
	always@(posedge clk) begin
			q = q + 1;
	end
endmodule