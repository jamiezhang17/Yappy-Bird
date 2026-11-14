`timescale 1ns / 1ps

module testbench ( );

	parameter CLOCK_PERIOD = 10;

    reg CLOCK_50;
    reg resetn;
    reg audio_in_available;
    reg [31:0] audio_sample;

    wire led;
	 
	 // clock generator
    initial begin // initial 
        CLOCK_50 <= 1'b0;
    end

    always @(*) 
		begin : Clock_Generator
					#(CLOCK_PERIOD / 2) CLOCK_50 <= ~CLOCK_50;
    end 
	 
	 // reset
    initial begin
        resetn <= 1'b0;
        #10 resetn <= 1'b1;
    end  // initial 
	 
	 
	 // test cases:
	 // we put in artificial mic inputs to test our code 
    initial begin

        audio_in_available <= 1'b0;
        audio_sample <= 32'd0;

        // wait for reset to finish
        #10;

        // test 1: silence
        audio_sample <= 32'd0;
		  // here, we act as the audio controller, 
		  // so we tell our detector when to read and not read new audio inputs
        audio_in_available <= 1'b1; 
        #10 audio_in_available <= 1'b0; // wait 20 ns before changing to 0

        // test 2: below threshold
        #20;
        audio_sample <= 32'd500_000_000;
        audio_in_available <= 1'b1;
        #10 audio_in_available <= 1'b0;

        // test 3: above threshold (positive input)
        #20;
        audio_sample <= 32'd1_500_000_000;
        audio_in_available <= 1'b1;
        #10 audio_in_available <= 1'b0;

        // wait for LED hold timer to run out
        #70;

        // silence again 
        audio_sample <= 32'd0;
        audio_in_available <= 1'b1; 
        #20 audio_in_available <= 1'b0;

        // test 4: above threshold (negative input)
        #20;
        audio_sample <= -32'sd1_500_000_000;
        audio_in_available <= 1'b1;
        #20 audio_in_available <= 1'b0;
    end // initial 

    // the module we are testing
    mic_detector #(.HOLD_COUNT(5)) U1 (
        CLOCK_50,
        resetn,
        audio_in_available,
        audio_sample,
        led
    );

endmodule 
