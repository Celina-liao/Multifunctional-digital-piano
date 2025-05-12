module LFSR ( input logic clk, reset, Enable_rand, output logic unsigned [3:0] rand_note);
	
	logic [9:0] ps, ns;
	logic unsigned [3:0] boundRand;
	assign rand_note = ps[9:6] % 12;
	
//	always_comb begin
//		if (ps[9:6] <= 12) boundRand = $unsigned(ps[9:6]);
////		else if (ps[9:6] == 12) boundRand = 2;
//		else if (ps[9:6] == 13) boundRand = 10;
//		else if (ps[9:6] == 14) boundRand = 11;
//		else boundRand = 12;
//	end
		
	
	always_comb begin
		ns <= {~(ps[6]^ps[9]),ps[9:1]};
	end
	
	always @(posedge clk) begin
		if (reset) ps <= 10'b0000000000;
		else if (Enable_rand) ps <= ns;
	
	end
	
endmodule

module tb_LFSR();
	logic CLOCK_50;
	logic reset, Enable;
	logic [3:0] random;
	
	LFSR dut (CLOCK_50, reset, Enable, random);
	// Set up a simulated clock.
	parameter CLOCK_PERIOD=100;
	initial begin
	CLOCK_50 <= 0;
	forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50; // Forever toggle the clock
	
	end
	initial begin
		Enable <= 0;
		forever #(CLOCK_PERIOD/2) Enable <= ~Enable;
	end
	
//	initial begin
//	random = 501;
//	end
	// Test the design.
	initial begin
//	repeat(1) @(posedge CLOCK_50);
	reset <= 1; repeat(1) @(posedge CLOCK_50); // Always reset FSMs at start
	reset <= 0; repeat(1) @(posedge CLOCK_50);
	repeat(100) @(posedge CLOCK_50);
//	KEY[0] <= 1; KEY[3]<= 0; repeat(3) @(posedge CLOCK_50);
//   KEY[0] <= 0; KEY[3]<= 1; repeat(3) @(posedge CLOCK_50);	
//   KEY[0] <= 1; KEY[3]<= 0; repeat(5) @(posedge CLOCK_50);	
//   KEY[0] <= 0; KEY[3]<= 1; repeat(10  ) @(posedge CLOCK_50);	

//	SW[0] <= 1; repeat(1) @(posedge CLOCK_50); // Test case 2: input 1 for 1 cycle
//	SW[0] <= 0; repeat(1) @(posedge CLOCK_50);
//	SW[0] <= 1; repeat(4) @(posedge CLOCK_50); // Test case 3: input 1 for >2 cycles
//	SW[0] <= 0; repeat(2) @(posedge CLOCK_50);
	$stop; // End the simulation.
	end
endmodule
