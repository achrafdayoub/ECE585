module top();
reg Reset,Clock;
reg  // sensors for approaching vehicles
	S1, // Northbound on SW 4th Avenue
	S2, // Eastbound on SW Harrison Street
	S3; // Westbound on SW Harrison Street
wire [1:0] // outputs for controlling traffic lights
	L1, // light for NB SW 4th Avenue
	L2, // light for EB SW Harrison Street
	L3; // light for WB SW Harrison Street

// Wire between real fsm and Counter
wire
	timeup,
	load, 
	decr;
wire [7:0] value;

// initializing my counter 
counter Timer(
        .clk(Clock),
        .reset(Reset),
        .load(load),
		.value(value),
        .decr(decr),
        .timeup(timeup));
		
//initializing a different counter for the traffic lights counter (tlc)		
realfsm MyFSMCounter(
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

parameter TRUE   = 1'b1;
parameter FALSE  = 1'b0;
parameter CLOCK_TIMES  = 20;
parameter CLOCK_WIDTH  = CLOCK_TIMES/2;
parameter IDLE_CLOCKS  = 2;


// Watch the values changing
initial
begin
	$display("               Time Clock Reset  S1  S2  S3  L1   L2   L3 ");
	$monitor($time, " %b    %b     %b    %b   %b    %b   %b   %b ",Clock,Reset,S1,S2,S3,L1,L2,L3);
end 

// Generate Clock signal
initial
begin
	Clock = FALSE;
	forever #CLOCK_WIDTH Clock = ~Clock;
end

// Generate RESET signal for IDLE_CLOCKS cycle
initial
begin
	Reset = TRUE;
	repeat (IDLE_CLOCKS) @(negedge Clock);
	Reset = FALSE;
end


initial
begin
{S1,S2,S3} = 3'b100;								// sensor one only is ON 		=> stay in Green-Red-Red state
repeat (75) @(negedge Clock); {S1,S2,S3} = 3'b000;	// all sensors are OFF 			=> Move to the NextState after the time is up
repeat (75) @(negedge Clock); {S1,S2,S3} = 3'b001;	// sensor three only is ON		=> Move to the NextState after the time is up
repeat (75) @(negedge Clock); {S1,S2,S3} = 3'b010; 	// sensor two only is ON 		=> Move to the NextState after the time is up
repeat (75) @(negedge Clock); {S1,S2,S3} = 3'b011;	// sensors two and three are ON => Move to the NextState after the time is up
repeat (75) @(negedge Clock); {S1,S2,S3} = 3'b101;	// sensors one and three are ON	=> Move to the NextState after the time is up
repeat (75) @(negedge Clock); {S1,S2,S3} = 3'b110; 	// sensors one and two are ON	=> Move to the NextState after the time is up
repeat (75) @(negedge Clock); {S1,S2,S3} = 3'b111; 	// all sensors are ON			=> Move to the NextState after the time is up
repeat (75) @(negedge Clock); {S1,S2,S3} = 3'bz00; 	// sensor 1 is broken			=> Move to the flashing state after the time is up
repeat (75) @(negedge Clock); {S1,S2,S3} = 3'b0z0; 	// sensor 2 is broken			=> Move to the flashing state after the time is up
repeat (75) @(negedge Clock); {S1,S2,S3} = 3'b00z; 	// sensor 3 is broken			=> Move to the flashing state after the time is up
repeat (75) @(negedge Clock);
$stop;
end
endmodule




