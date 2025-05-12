   /* score_mem stores all scores as a pair of note and length memory. These memories stores note and length as numbers.
	
  Inputs:
    Do_new_score                    - The control signal which enables this module to store notes and length in the memories
    Do_rand/save_audio_video     	- The control signal which enables this module to start increasing the address to score_mem
	rand_note/ength 	           	- The random note/length values to be stored in the memories
    Done_gen_score.                 - Finish generating score
 
  Outputs:
	note                            - The current playing note 
	length                          - The length of the current playing note
 */ 
 
module score_mem #(parameter audio_len = 6) (clk, Do_new_score, rand_note, rand_length, score_noteAdr, Done_gen_score, Do_save_audio_video, note, length);
	
	input logic clk, Do_new_score;
	input logic [3:0] rand_note;
	input logic [1:0] rand_length;
	input logic [audio_len-1:0] score_noteAdr;
	input Do_save_audio_video;
	output logic Done_gen_score;
	output logic [4:0] note;
	output logic [1:0] length;
	
	logic [3:0] note_memory [2**(audio_len)-1:0];
	logic [1:0] length_memory [2**(audio_len)-1:0];
	logic [4:0] q_note;
	logic [1:0] q_len;
	integer i=0;
	
	assign note = Do_save_audio_video? q_note : note_memory[score_noteAdr];
	assign length = Do_save_audio_video? q_len :  length_memory[score_noteAdr];
	assign Done_gen_score = (i >= 2**(audio_len)-1);
	
	always_ff @(posedge clk) begin
		if(Do_new_score) begin // & ~Done_gen_score
			
			note_memory[i] <= rand_note;
			length_memory[i] <= rand_length;
			i <= i+1;
			
		end
		else begin
			i <= 0;
		end
	end
	
	grnslv_note gns_n (score_noteAdr, clk, q_note);
	grnslv_len gns_l (score_noteAdr, clk, q_len);
endmodule


