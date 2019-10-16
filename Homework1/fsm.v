module fsm(Clock, Reset, S1, S2, S3, L1, L2, L3);
input Clock;
input Reset;
input // sensors for approaching vehicles
	S1, // Northbound on SW 4th Avenue
	S2, // Eastbound on SW Harrison Street
	S3; // Westbound on SW Harrison Street
output reg [1:0] // outputs for controlling traffic lights
	L1, // light for NB SW 4th Avenue
	L2, // light for EB SW Harrison Street
	L3; // light for WB SW Harrison Street

// initializing my counter 
counter mytimer(
        .clk(Clock),
        .reset(Reset),
        .load(load),
		.value(value),
        .decr(decr),
        .timeup(timeup));

//initializing a different counter for the traffic lights counter (tlc)
realfsm tlc(
		.Clock(Clock),
        .Reset(Reset),
        .load(load),
		.value(value),
        .decr(decr),
        .timeup(timeup),
		.S1(S1), 
		.S2(S2), 
		.S3(S3), 
		.L1(L1), 
		.L2(L2), 
		.L3(L3));
		
endmodule

// start the real fsm module
module realfsm(load, value, timeup, decr, Clock, Reset, S1, S2, S3, L1, L2, L3);
input Clock;
input Reset;
input // sensors for approaching vehicles
	S1, // Northbound on SW 4th Avenue
	S2, // Eastbound on SW Harrison Street
	S3; // Westbound on SW Harrison Street
output reg [1:0] // outputs for controlling traffic lights
	L1, // light for NB SW 4th Avenue
	L2, // light for EB SW Harrison Street
	L3; // light for WB SW Harrison Street

// Define states using hot one
localparam
	GRR		 = 7'b0000001,
	YRR 	 = 7'b0000010,
	RRR1	 = 7'b0000100,
	RGG		 = 7'b0001000,
	RYY	 	 = 7'b0010000,
	RRR2	 = 7'b0100000,
	Flash	 = 7'b1000000;
	
// Declare value as an 8 bits output register from the realfsm to the counter
output reg [7:0]  value;			

// Declare timeup as hardware input from the counter to the realfsm
input timeup;

// Declare load & decr as an output register from the realfsm to the counter
output reg load, decr; 


localparam
	Flashing = 2'b00,				// Declare Flasing as to bit value 00
	Green = 2'b01,					// Declare Green as to bit value 01
	Yellow = 2'b10,					// Declare Yellow as to bit value 10 
	Red = 2'b11, 					// Declare Red as to bit value 11
	SET = 1'b1,						// define 1 as set 
	CLEAR = 1'b0,					// define 0 as clear
	GRR_TIMER 	 = 8'b00101100,		// 44 seconds Green-Red-Red to get 45
	RED_TIMER 	 = 8'b00000000,		// 0 second Red-Red-Red to get 1 second because the clock is 1 HZ
	RGG_TIMER 	 = 8'b00001110,		// 14 seconds Red-Green-Green to get 15 seconds
	YELLOW_TIMER = 8'b00000100;		// 4 seconds Yellow-Red-Red or Red-Yellow-Yellow to get 5 seconds

// create 6 bits registers for State and NextState
reg [6:0] State, NextState;


// Update state or reset on every + clock edge
always @(posedge Clock or posedge Reset)
begin
if (Reset)
	begin
	value = GRR_TIMER;						// 45 seconds value
	load = SET;								// load the value
	decr = CLEAR;							// Do not decrement 
	State <= GRR;							// Go to the Green-Red-Red state
	end
else
	State <= NextState;						// Go to the next state if not Reset
end
	always @(State)
		begin
			case(State)
				GRR: 	  begin L1 = Green; L2 = Red; L3 = Red; 			 end	// Green		Red			Red
				YRR:	  begin L1 = Yellow; L2 = Red; L3 = Red; 			 end	// Yellow		Red			Red
				RRR1: 	  begin L1 = Red; L2 = Red; L3 = Red; 				 end	// Red			Red			Red
				RGG:	  begin L1 = Red; L2 = Green; L3 = Green; 			 end	// Red			Green		Green
				RYY:	  begin L1 = Red; L2 = Yellow; L3 = Yellow; 		 end	// Red			Yellow		Yellow
				RRR2:	  begin L1 = Red; L2 = Red; L3 = Red; 				 end	// Red			Red			Red
				Flash: 	  begin L1 = Flashing; L2 = Flashing; L3 = Flashing; end	// Flashing		Flashing	Flashing
			default 	  begin L1 = Flashing; L2 = Flashing; L3 = Flashing; end	// Flashing		Flashing	Flashing
			endcase
		end
		
// Next state generation logic
always @*
begin
case (State)
	GRR: begin											// Green-Red-Red state
		if ((S2 || S3) && timeup)						// sensor 2 or sensor 3 asserted => change lights after 45
			begin	
			value = YELLOW_TIMER;						// 5 seconds value before moving to Yellow-Red-Red State
			load = SET;									// load the Yellow timer
			decr = CLEAR;								// Do not decrement 					
			NextState = YRR;							// Move to the Yellow-Red-Red state
			end
		else if (!S1 && !S2 && !S3 && timeup)			// no sensors asserted => change lights after 45
			begin
			value = YELLOW_TIMER;						// load 5 seconds value before moving to Yellow-Red-Red State
			load = SET;									// load the Yellow timer
			decr = CLEAR;								// Do not decrement
			NextState = YRR;							
			end
		else if((S1 !== 1'b1) && (S1 !== 1'b0))			// protect the system from broken Sensor 1
			NextState = Flash;
		else if((S2 !== 1'b1) && (S2 !== 1'b0))			// protect the system from broken Sensor 2
			NextState = Flash;
		else if((S3 !== 1'b1) && (S3 !== 1'b0))			// protect the system from broken Sensor 3
			NextState = Flash;
		else
			begin
			load = CLEAR;								// Clear the load bit to make sure we are not loading while decrementing
			decr = SET;									// decrement Green-Red-Red counter 
			NextState = GRR;							// come back to the same state until timeup is set
			end
		end
	YRR: begin											// Yellow-Red-Red
		if (timeup)
			begin
			value = RED_TIMER;							// 1 second value
			load = SET;									// load Red-Red-Red counter 
			decr = CLEAR;								// Do not decrement 									
			NextState = RRR1;							// Move to the first Red-Red-Red state
			end
		else
			begin	
			load = CLEAR;								// Clear the load bit to make sure we are not loading while decrementing
			decr = SET;									// decrement Yellow-Red-Red counter 
			NextState = YRR;							// come back to the same state until timeup is set
			end
		end	
	RRR1: begin											// First Red-Red-Red state
		if (timeup)
			begin
			value = RGG_TIMER;							// 15 seconds value
			load = SET;									// load Red-Green-Green counter 
			decr = CLEAR;								// Do not decrement 
			NextState = RGG;							// move to Red-Green-Green state
			end
		else
			begin	
			load = CLEAR;								// Clear the load bit to make sure we are not loading while decrementing
			decr = SET;									// decrement Red-Red-Red counter 
			NextState = RRR1;							// come back to the same state until timeup is set
			end
		end		
	RGG:begin											// Red-Green-Green state
		if (timeup)
			begin
			value = YELLOW_TIMER;						// load 5 seconds value before moving to Yellow-Red-Red State		
			load = SET;									// load Red-Yellow-Yellow counter 
			decr = CLEAR;								// Do not decrement 
			NextState = RYY;							// Move to Red-Yellow-Yellow state
			end
		else
			begin	
			load = CLEAR;								// Clear the load bit to make sure we are not loading while decrementing
			decr = SET;									// decrement Red-Green-Green counter 
			NextState = RGG;							// come back to the same state until timeup is set
			end
		end
	RYY:begin											// Red-Yellow-Yellow
		if (timeup)
			begin
			value = RED_TIMER;							// 1 second value
			load = SET;									// load Red-Red-Red counter 
			decr = CLEAR;								// Do not decrement 
			NextState = RRR2;							// Move to the second Red-Red-Red state
			end
		else
			begin	
			load = CLEAR;								// Clear the load bit to make sure we are not loading while decrementing
			decr = SET;									// decrement Red-Yellow-Yellow counter 
			NextState = RYY;
			end
		end
	RRR2:begin											// Second Red-Red-Red state
		if (timeup)
			begin
			value = GRR_TIMER;							// 45 seconds value
			load = SET;									// load Green-Red-Red counter 
			decr = CLEAR;								// Do not decrement 			
			NextState = GRR;							// Move to the Green-Red-Red state
			end
		else
			begin	
			load = CLEAR;								// Clear the load bit to make sure we are not loading while decrementing
			decr = SET;									// decrement Red-Red-Red counter 
			NextState = RRR2;							// come back to the same state until timeup is set
			end
		end	
	Flash:begin											// protect the system from broken Sensor 1
		if((S1 !== 1'b1) && (S1 !== 1'b0))
			NextState = Flash;
		else if((S2 !== 1'b1) && (S2 !== 1'b0))			// protect the system from broken Sensor 2
			NextState = Flash;
		else if((S3 !== 1'b1) && (S3 !== 1'b0))			// protect the system from broken Sensor 3
			NextState = Flash;
		else
			NextState = GRR;
		end
	default begin NextState = Flash; end				// Flashing-Flashing-Flashing (fail safe mode)
endcase
end
endmodule
