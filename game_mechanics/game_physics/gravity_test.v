module gravity_test (KEY, CLOCK_50, HEX0, HEX1);
	input [1:0] KEY;
	input CLOCK_50;
	output [6:0] HEX0, HEX1;
	
	// key0 is reset
	// if key1 = 0 (pressed down), hex - 1 (bird goes up)
	// if key1 = 1 (released), hex + 1 (bird goes down) 
	
	parameter n = 26;

	wire [n-1:0] Qout;
	wire en; 
	wire [7:0] digit;
	
	// instantiate everything 
	nbit_countdown counter_50hz (CLOCK_50, KEY[0], Qout, en);
	counter_4bit counter_1sec (CLOCK_50, KEY[0], en, KEY[1], digit);
	seg7 d0 (digit[3], digit[2], digit[1], digit[0], HEX0);
	seg7 d1 (digit[7], digit[6], digit[5], digit[4], HEX1);
	
	
endmodule 


module nbit_countdown (Clk_50, resetn, Q, E);
	parameter n = 26;
	input Clk_50, resetn;
	output reg [n-1:0] Q;
	output reg E;
	
	always @ (posedge Clk_50) // synchronous 
		begin 
			if (!resetn) 
				begin
					Q <= 26'd25_000_000; // reset back to 25 million
					E <= 1'b0; // reset enable
				end	
			else if (Q == 0) // comparator
				begin
					E <= 1'b1; // enable is on
					Q <= 26'd25_000_000; // when counter reaches zero, wrap around 
				end
			else 
				begin 
					Q <= Q - 1'b1; // count down from the max number 50 million
					E <= 1'b0; // make sure enable is off otherwise 
				end
		end 
endmodule 


// counter for display 
module counter_4bit (Clk_50, resetn, E, key_E, Q);
	input Clk_50, resetn, E, key_E; // E is for 1 sec timer, key_E is the player input 
	output reg [7:0] Q;
	
	reg [3:0] deltad;
	
	always @ (posedge Clk_50)
		begin 
			if (!resetn) begin
				Q <= 8'd60; // reset to digit 6 if reset 
				deltad <= 0; // reset to 0
			end
			else if (Q >= 8'd119)
				Q <= 8'd119; // stay at digit 119 (game over state)
			else if (Q <= 8'd0)
				Q <= 8'd0; // stay at digit 0 (game over state)
			else if (E == 1'b1) 
				begin
					if (key_E == 1'b0) // only happens every time nbit counter hits 0
						Q <= Q - 2'd3; // if key1 is pressed down, hex - 1
					else begin 
						deltad <= deltad + 1; // increase the "velocity" deltad
						Q <= Q + deltad; // if released, hex + deltad
					end
				end
		end
endmodule 


// 7 seg for hexadecimals
module seg7 (m3, m2, m1, m0, hex);
	input m0, m1, m2, m3;
	output [6:0] hex; 
	
	// for hexadecimals 
	assign hex[0] = (~m1 & (~m3 & ~m2 & m0 | ~m3 & m2 & ~m0 | m3 & m2 & m0)) | (m3 & ~m2 & m1 & m0); 
	assign hex[1] = (m3&m2&~m1&~m0) | (~m3&m2&~m1&m0) | (m3&m1&m0) | (m2&m1&~m0);
	assign hex[2] = (~m3&~m2&m1&~m0) | (m3&m2&~m1&~m0) | (m3&m2&m1); 
	assign hex[3] = (~m3&m2&~m1&~m0) | (~m3&~m2&~m1&m0) | (m2&m1&m0) | (m3&~m2&m1&~m0);
	assign hex[4] = (~m3&m0) | (~m3&m2&~m1) | (m3&~m2&~m1&m0);
	assign hex[5] = (~m3&~m2&m0) | (~m3&m1&m0) | (~m3&~m2&m1) | (m3&m2&~m1&m0);
	assign hex[6] = (~m3&~m2&~m1) | (~m3&m2&m1&m0) | (m3&m2&~m1&~m0);
	
endmodule 
