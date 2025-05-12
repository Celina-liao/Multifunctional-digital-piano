/* 
DE1_SoC is the top-level module of the music generation machine. 
CLOCK_50 is the system clock inputed from the DE1_SoC device and CLOCK2_50 
is an additional clock for the audio system.
The ports with AUD prefix are for the audio system, 
while ports with VGA prefix are for the VGA system.
 */ 
 
module DE1_SoC (CLOCK_50, CLOCK2_50, FPGA_I2C_SCLK, FPGA_I2C_SDAT,
	AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT,
	KEY, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);

	input logic CLOCK_50, CLOCK2_50;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	// VGA 
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	
	// Local wires
	logic read_ready, write_ready, read, write;
	logic signed [23:0] readdata_left, readdata_right;
	logic signed [23:0] writedata_left, writedata_right;
	logic signed [23:0] task2_left, task2_right, task3_left, task3_right;
	logic signed [23:0] noisy_left, noisy_right;
	logic reset;
	// VGA
	logic [9:0] x;
	logic [8:0] y;
	logic [7:0] r, g, b;
	// Self-defined submodules
		// control
	logic Do_new_score;
	logic Enable_rand, Done_gen_score, Done_rand_audio, Done_save_audio;  
	logic Play_rand, Play_save, Do_rand_audio_video, Do_save_audio_video, Init_audio_video, End_early;
	logic Change_score, Replay, Done, Now_S5, Now_S7;
		// LFSRs and score_mem
	logic new_score;
	logic unsigned [3:0] rand_note; 
    logic unsigned [1:0] rand_length;
	logic [4:0] note;
	logic [1:0] length;
	parameter audio_len = 6;
	logic [audio_len-1:0] score_noteAdr;
		// note_to_audio, note_to_video, and length_counter
	logic [1:0] speed;
	logic octave_up;
	logic finish_len;
	logic [23:0] audio;
	logic count;
    
    //assign write_ready = 1;
	assign reset = ~KEY[0];
	assign s = ~KEY[1];
	assign Play_rand = ~KEY[2];
	assign Play_save = ~KEY[3];
	assign speed = SW[1:0];
	assign octave_up = SW[2];
	assign Replay = SW[3];
	assign Change_score = SW[4];
	assign End_early = SW[5];
	assign LEDR[0] = Play_save;
	assign LEDR[1] = reset;
	assign LEDR[2] = s;
	assign LEDR[3] = Enable_rand;
	assign LEDR[4] = Now_S5;
	assign LEDR[5] = Play_rand;
	assign LEDR[6] = Do_rand_audio_video | Do_save_audio_video;
	assign LEDR[7] = Now_S7;
	assign LEDR[8] = ~write_ready;
	assign LEDR[9] = Done;
	assign {HEX0, HEX1, HEX2, HEX3, HEX4, HEX5} = '1;
    //assign write_ready2 = 1;
	
	// only read or write when both are possible
	assign writedata_left = Do_rand_audio_video | Do_save_audio_video? audio : 0;
	assign writedata_right = Do_rand_audio_video | Do_save_audio_video? audio : 0;
	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	
	
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		1'b0,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		1'b0,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		1'b0,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);
    
    assign write = write_ready;
    
    // always_ff @(posedge CLOCK_50) begin
    //     //count = ~count;
    //     write_ready = ~write_ready;
    // end
    
	/******************** video_driver **************************/
	
	video_driver #(.WIDTH(640), .HEIGHT(480))
		v1 (.CLOCK_50, .reset, .x, .y, .r, .g, .b,
			 .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N,
			 .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);
	

	/***************** Self-defined modules *********************/
	
	control con(.clk(CLOCK_50), .reset, .s, .Do_new_score, .Enable_rand, .Done_gen_score, .Play_rand, .Play_save, .Done_rand_audio, .Done_save_audio,  .End_early,  
	.Init_audio_video, .Do_rand_audio_video, .Do_save_audio_video, .Change_score, .Replay, .Done, .Now_S5, .Now_S7);
	

	LFSR lfsr( 
		// Inputs
	   .clk(CLOCK_50),
		.reset, 
		.Enable_rand,  
		
		// Outputs
		.rand_note
	);

	LFSR_length lfsr_len( 
		// Inputs
	   .clk(CLOCK_50),
		.reset, 
		.Enable_rand,  
		
		// Outputs
		.rand_length
	);
	
	score_mem scr_mem(.clk(CLOCK_50), .Do_new_score, .rand_note, .rand_length, .score_noteAdr, .Done_gen_score, .Do_save_audio_video, .note, .length);

	note_to_audio nta(.clk(CLOCK_50), .reset, .write, .Init_audio_video, .Do_rand_audio_video, .Do_save_audio_video, .finish_len, .note, .octave_up, .score_noteAdr, .audio, .Done_rand_audio, .Done_save_audio);
	
    note_to_video ntv(.clk(CLOCK_50), .reset, .Init_audio_video, .Do_rand_audio_video, .Do_save_audio_video, .finish_len, .note, .x, .y, .r, .g, .b);
	
	length_counter lenc(.clk(CLOCK_50), .reset, .Init_audio_video, .Do_rand_audio_video, .Do_save_audio_video, .length, .speed, .finish_len);

endmodule

	
	
