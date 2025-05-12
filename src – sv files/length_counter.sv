/* This module count and define the time span of each note.
	Utilizing the 50MHz clock, this counter increase the count
	every clock cycle until the reach the specified max value.
	Then it asserted finish_len and reset count to 0.
	
  Inputs:
    Init_audio_video - The control signal which initializes registers of S_3(S_note_to_audio_video).
    Do_audio_video 	- The control signal which enables this module to increase count
	 length           - Length of the current note. 0 = eighth note,.., 3 = whole note 
	 speed				- Define the Beat Per Minute(BPM). 
 
  Outputs:
    finish_len 		- Asserted for one cycle when finish counting for the note
 */ 
 
module length_counter (clk, reset, Init_audio_video, Do_rand_audio_video, Do_save_audio_video, length, speed, finish_len);

	input logic clk, reset, Init_audio_video, Do_rand_audio_video, Do_save_audio_video;
	input logic [1:0] length, speed;
	output logic finish_len;
	
	
	logic [26:0] count, max;
	assign finish_len = (count>=max);
	
	// Define max value
	always_comb begin
		case (speed)
			2'b00: max = (length+1)*10**(8); 
			2'b01: max = (length+1)*10**(7);   
			2'b10: max = (length+1)*5*10**(6);  
			2'b11: max = (length+1)*5*10**(5);  
		endcase
	end
	
	// Logic for count
	always_ff @(posedge clk) begin
		if (reset | Init_audio_video) begin
			count <= 0;
		end
		else if (Do_rand_audio_video | Do_save_audio_video) begin
			count <= (count>=max)? 0 : count+1;
	   end
	
	end

endmodule // length_counter