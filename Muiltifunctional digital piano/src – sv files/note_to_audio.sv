/* note_to_audio module transfers notes to audio signals and modify the audio if octave_up is asserted.
	
  Inputs:
    Init_audio_video            - The control signal which initializes registers of S_3(S_note_to_audio_video).
    Do_rand/save_audio_video 	- The control signal which enables this module to start increasing the address to score_mem
	finish_len 	            	- Asserted for one cycle when finish counting for the note
	note                        - The current playing note 
	octave_up.                  - If playing rendom score, transfer the 4th octaves notes to the 5th octave
	score_noteAdr				- The address of the current note in the score memory
 
  Outputs:
      audio.                    - The audio signal 
      Done_rand_audio           - The random score is done playing
      Done_save_audio.          - The saved score is done playing
    
 */ 

module note_to_audio #(parameter audio_len = 6) (clk, reset, write, Init_audio_video, 
	Do_rand_audio_video, Do_save_audio_video, finish_len, note, octave_up, score_noteAdr, audio, Done_rand_audio, Done_save_audio);

	input logic clk, reset, write, Init_audio_video, Do_rand_audio_video, Do_save_audio_video, finish_len;
	input logic [4:0] note;
	input logic octave_up;
	output logic [audio_len-1:0] score_noteAdr;
	output logic [23:0] audio;
	output logic Done_rand_audio, Done_save_audio;
	
	logic [4:0] alter_note;
	logic [15:0] address;
	logic [23:0] q1, q2, q3, q4, q5, q6, q7, q8, q9, 
	q10, q11, q12, q13, q14, q15, q16, q17, q18, q19, q20, q21, 
	q22, q23, q24;
	
	assign alter_note = Do_save_audio_video? note%24 : octave_up? (note+12)%24 : note%12;
	assign Done_rand_audio = (score_noteAdr == 2**(audio_len)-1);
	assign Done_save_audio = (score_noteAdr >= 43);
	
	always_ff @(negedge write) begin
	    address <= (address==512)|finish_len? 0 : address+1;
	end
	
	// score_noteAdr up counter 
	always_ff @(posedge clk) begin
		if (reset | Init_audio_video) begin
			score_noteAdr <= 0;	
		end  		
		else if (Do_rand_audio_video|Do_save_audio_video) begin
			score_noteAdr <= finish_len? score_noteAdr+1 : score_noteAdr;
	    end
	end
    
    // Match notes with audio signal output
	always_comb begin
    		case (alter_note) 	
    			0: audio = q1; 
    			1: audio = q2; 
    			2: audio = q3; 
    			3: audio = q4;
    			4: audio = q5; 
    			5: audio = q6;
    			6: audio = q7;
    			7: audio = q8;
    			9: audio = q10;
    			10: audio = q11;
    			11: audio = q12;
    			12: audio = q13; 
    			13: audio = q14; 
    			14: audio = q15; 
    			15: audio = q16;
    			16: audio = q17; 
    			17: audio = q18;
    			18: audio = q19;
    			19: audio = q20;
    			20: audio = q21;
    			21: audio = q22;
    			22: audio = q23;
    			23: audio = q24;
    		    default: audio = 0;
    		endcase
	end
	

	
	C4 c4 (address%369, clk, q1);
	C4shp c4s (address%348, clk, q2);
	D4 d4 (address%329, clk, q3);
	D4shp d4s (address%309, clk, q4);
	E4 e4 (address%437, clk, q5);
	F4 f4 (address%497, clk, q6);
	F4shp f4s (address%468, clk, q7);
	G4 g4 (address%442, clk, q8);
	G4shp g4s (address%417, clk, q9);
	A4 a4 (address%395, clk, q10);
	A4shp a4s (address%352, clk, q11);
	B4 b4 (address%329, clk, q12);
	
	C5 c5 (address%331, clk, q13);
	C5shp c5s (address%313, clk, q14);
	D5 d5 (address%295, clk, q15);
	D5shp d5s (address%280, clk, q16);
	E5 e5 (address%262, clk, q17);
	F5 f5 (address%493, clk, q18);
	F5shp f5s (address%465, clk, q19);
	G5 g5 (address%443, clk, q20);
	G5shp g5s (address%413, clk, q21);
	A5 a5 (address%393, clk, q22);
	A5shp a5s (address%371, clk, q23);
	B5 b5 (address%349, clk, q24);
endmodule //note_to_audio
