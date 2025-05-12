 /* Depending on the note, note_to_video module returns the rgb values of current pixel.
	
  Inputs:
    Init_audio_video            - The control signal which initializes registers of S_3(S_note_to_audio_video).
    Do_rand/save_audio_video 	- The control signal which enables this module to start increasing the address to score_mem
	finish_len 	            	- Asserted for one cycle when finish counting for the note
	note                        - The current playing note 
	x                           - x coordinate of current pixel
	y          				    - y coordinate of current pixel
 
  Outputs:
      r                         - The red color of current pixel
      g                         - The green color of current pixel
      b                         - The blue color of current pixel
    
 */ 
 
module note_to_video #(parameter radius = 15) (clk, reset, Init_audio_video, Do_rand_audio_video, Do_save_audio_video, finish_len, note, x, y, r, g, b);

	input logic clk, reset, Init_audio_video, Do_rand_audio_video, Do_save_audio_video, finish_len;
	input logic [4:0] note;
	input logic [9:0] x;
	input logic [8:0] y;
	output  logic [7:0] r, g, b;
	
    logic [9:0] delta_x, delta_y;
	logic within_circle, not_within_frame;
	logic [8:0] circle_center_x, circle_center_y, circle_center_x_ps, circle_center_y_ps;
	logic [380:0]  q1, q2;
	logic [7:0] color_choice1, color_choice2;
	logic [7:0] address1;
	logic [6:0] address2;
	logic [3:0] alter_note;
	
	// Define whether the pixel is within the blue circle
	assign delta_x = (x > circle_center_x_ps)? x - circle_center_x_ps : circle_center_x_ps - x;
	assign delta_y = (y > circle_center_y_ps)? y - circle_center_y_ps : circle_center_y_ps - y;
	assign within_circle =  (delta_x**2 + delta_y**2) <= (radius**2);
	assign not_within_frame = (x > 380) | (y > 229);
	
	assign color_choice1 = (q1[381-x]==1)? 255 : 0;
	assign color_choice2 = (q2[250-(x-381)]==1)? 255 : 0;
	assign address1 = (y>230)? 0 : y[7:0];
	assign address2 = y;
	assign alter_note = note%12;
	
	// Define circle center of the blue dot
	always_comb begin
	   
		case (alter_note)
		0: begin
			circle_center_x <= 28;
			circle_center_y <= 176;
			end
		1: begin
			circle_center_x <= 37+18;
			circle_center_y <= 88;
			end
		2: begin
			circle_center_x <= 57+25;
			circle_center_y <= 176;
			end
		3: begin
			circle_center_x <= 73+18+18;
			circle_center_y <= 88;
			end
		4: begin
			circle_center_x <= 111+25;
			circle_center_y <= 176;
			end
		5: begin
			circle_center_x <= 165+25;
			circle_center_y <= 176;
			end
		6: begin
			circle_center_x <= 199+18;
			circle_center_y <= 88;
			end
		7: begin
			circle_center_x <= 219+25;
			circle_center_y <= 176;
			end
		8: begin
			circle_center_x <= 253+18;
			circle_center_y <= 88;
			end
		9: begin
			circle_center_x <= 273+25;
			circle_center_y <= 176;
			end
		10: begin
			circle_center_x <= 307+18;
			circle_center_y <= 88;
			end
		11: begin
			circle_center_x <= 327+25;
			circle_center_y <= 176;
			end
		default: begin
			circle_center_x <= 327+25;
			circle_center_y <= 176;
			end
		endcase
	end
	
	// Update circle center of the blue dot once after every finish_len
	always_ff @(posedge clk) begin
		if (reset | Init_audio_video) begin
			circle_center_y_ps <= 0;
			circle_center_x_ps <= 0;
		end
		else if (Do_rand_audio_video | Do_save_audio_video) begin
			circle_center_y_ps <= finish_len? circle_center_y : circle_center_y_ps;
			circle_center_x_ps <= finish_len? circle_center_x : circle_center_x_ps;
		end
	end
	
    // Define rgb value
    always_comb begin
		
		if ((x<382)&(y<231)) begin
		    r = within_circle? 0 : color_choice1;
    	    g = within_circle? 0 : color_choice1;
    	    b = within_circle? 255 : color_choice1;
		end
		else if ((x>381)) begin
		    r = color_choice2;
    	    g = color_choice2;
    	    b = color_choice2;
		end
		else begin
		    r = 0;
    	    g = 0;
    	    b = 0;
		end
		
	end
	
	keyboard kb (address1, clk, q1);
    itr it (y, clk, q2);
endmodule //note_to_video
