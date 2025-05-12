  /*  This module is the control circuit of the circuit. 
  Inputs:
    Done_gen_score.                 - Finish generating score
    Play_rand/save                  - User input to choose between playing random score of save
    Do_rand/save_audio_video     	- The control signal which enables this module to start increasing the address to score_mem
	rand_note/ength 	           	- The random note/length values to be stored in the memories
    Done_rand_audio                 - The random score is done playing
    Done_save_audio.                - The saved score is done playing
 
  Outputs:
    Do_new_score                    - The control signal which enables this module to store notes and length in the memories
    Enable_rand                     - Enable the LFSLs to generate random values
    Init_audio_video                - The control signal which initializes registers of S_3(S_note_to_audio_video).
    Do_new_score                    - The control signal which enables this module to store notes and length in the memories
    Do_rand/save_audio_video     	- The control signal which enables this module to start increasing the address to score_mem
 */ 
     
 
module control(clk, reset, s, Do_new_score, Enable_rand, Done_gen_score, Play_rand, Play_save, Done_rand_audio, Done_save_audio, End_early, //write_ready, write, 
	Init_audio_video, Do_rand_audio_video, Do_save_audio_video, Change_score, Replay, Done, Now_S5, Now_S7);
	// signal declaration
	input logic clk, reset, s;
	// S_score_gen: score_mem
	output logic Do_new_score;
	output logic Enable_rand; 
	input logic Done_gen_score; 
	// S_rand/savenote_audio_video
	input logic Play_rand, Play_save, Done_rand_audio, Done_save_audio, End_early; //, write_ready
	output logic Init_audio_video, Do_rand_audio_video, Do_save_audio_video; //write
	// S_done
	input logic Change_score, Replay;
	output logic Done, Now_S5, Now_S7;
	
	

	
	
	enum {S1, S2, S3, S4, S5, S6} y,Y;
	
	// state update logic
	always_ff @(posedge clk) begin
		if (reset) y <= S1;
		else y <= Y;
	end
	
	// next state logic
	always_comb begin
		case (y)
			S1: Y = s? S2 : S1;									        	// S_idle
			S2: Y = Done_gen_score? S3 : S2;					        	// S_score_gen
			S3: Y = Play_rand? S4 : Play_save? S5 : S3;                     // S_ready
			S4: Y = End_early|Done_rand_audio? S6 : S4;  // S_randnote_to_audio_video
			S5: Y = End_early|Done_save_audio? S6 : S5;  // S_savenote_to_audio_video
			S6: Y = Change_score? S2 : Replay? S4 : S6;	                 	// S_done
			
		endcase
	end
	
	// output assignment
	 // S_score_gen
	 assign Do_new_score = (y==S2);
	 assign Enable_rand = (y==S2);
	 assign Init_audio_video = ((y==S2)&Done_gen_score) | ((y==S6)&Replay);
	 // S_randnote_to_audio_video
	 assign Do_rand_audio_video = (y==S4);
	 // S_savenote_to_audio_video
	 assign Do_save_audio_video = (y==S5);
	 // S_done
	 assign Done = (y==S6);
	 
	 
	 assign Now_S5 = (y==S4);
	 assign Now_S7 = (y==S5);


endmodule //control

