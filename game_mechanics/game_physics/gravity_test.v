module gravity_test (KEY, CLOCK_50, HEX0, HEX1);
	input [1:0] KEY;
	input CLOCK_50;
	output [6:0] HEX0, HEX1;
	
	// key0 is reset
	// if key1 = 0 (pressed down), hex - 1 (bird goes up)
	// if key1 = 1 (released), hex + 1 (bird goes down) 
	
	parameter n = 26;
	parameter FRAME_COUNT = 26'd12_500_000;

	wire [n-1:0] Qout;
	wire en; 
	wire [7:0] digit;
	
	// instantiate everything 
	nbit_countdown #(.n(n), .FRAME_COUNT(FRAME_COUNT)) counter_50hz (CLOCK_50, KEY[0], Qout, en);
	counter_4bit counter_1sec (CLOCK_50, KEY[0], en, KEY[1], digit);
	seg7 d0 (digit[3], digit[2], digit[1], digit[0], HEX0);
	seg7 d1 (digit[7], digit[6], digit[5], digit[4], HEX1);
	
	
endmodule 

// we want to update the physics at a frequency of 60hz (standard) so 50 million / 60 = 833 333 (20 bits)
module nbit_countdown (Clk_50, resetn, Q, E);
	parameter n = 26;
	input Clk_50, resetn;
	output reg [n-1:0] Q;
	output reg E;
	
	parameter FRAME_COUNT = 26'd12_500_000;
	
	always @ (posedge Clk_50) // synchronous 
		begin 
			if (!resetn) 
				begin
					Q <= FRAME_COUNT; // reset back to 25 million
					E <= 1'b0; // reset enable
				end	
			else if (Q == 0) // comparator
				begin
					E <= 1'b1; // enable is on
					Q <= FRAME_COUNT; // when counter reaches zero, wrap around 
				end
			else 
				begin 
					Q <= Q - 1'b1; // count down from the max number 50 million
					E <= 1'b0; // make sure enable is off otherwise 
				end
		end 
endmodule 


// counter for display 
module counter_4bit (Clk_50, resetn, E, key_E, y);
	input Clk_50, resetn, E, key_E; // E is for 1 sec timer, key_E is the player input 
	output reg [7:0] y;
	
	reg signed [4:0] velocity;
	reg signed [8:0] next_y;
	reg [3:0] gravity_en; // will control how fast velocity increases
	reg game_over; // flag
	
	always @(*) begin
        next_y = $signed({1'b0, y}) + velocity;
    end

	
	always @ (posedge Clk_50)
		begin 
			if (!resetn) begin
				y <= 8'd60; // reset to digit 6 if reset 
				velocity <= 0; // reset to 0
				gravity_en <= 0;
				game_over <= 0;
			end
			
			else 
				begin 
				
				if (!key_E) // flap
					velocity <= -5'sd2; // if key1 is pressed down, give an upward velocity 
				
				if (E && !game_over) // E will become our regular physics update enable 
					begin
						// updating y position 
						if (next_y >= 9'sd119)
							begin
							y <= 9'sd119; // stay at digit 119 (game over state)
							game_over <= 1'b1;
							end
						else if (next_y <= 9'sd0)
							begin 
							y <= 8'd0; // stay at digit 0 (game over state)
							game_over <= 1'b1;
							end
						else 
							y <= next_y[7:0];
						
						// gravity
						if (key_E) // when key1 not pressed
						begin 
							if (gravity_en == 4'd10)
								begin 
									if (velocity <= 5'sd8) // terminal velocity
										velocity <= velocity + 1; // increase the velocity
									gravity_en <= 8'd0;
								end 
								
							else 
								gravity_en <= gravity_en + 1;
						end
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
