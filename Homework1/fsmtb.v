module top;
reg Reset,Clock;
reg  // sensors for approaching vehicles
	S1, // Northbound on SW 4th Avenue
	S2, // Eastbound on SW Harrison Street
	S3; // Westbound on SW Harrison Street
wire [1:0] // outputs for controlling traffic lights
	L1, // light for NB SW 4th Avenue
	L2, // light for EB SW Harrison Street
	L3; // light for WB SW Harrison Street



wire  
	timeup_GRR,
    timeup_RGG,
    timeup_YELLOW,
    timeup_RED,
	load, 
	decr;
	
	
parameter TRUE   = 1'b1;
parameter FALSE  = 1'b0;
parameter CLOCK_TIMES  = 20;
parameter CLOCK_WIDTH  = CLOCK_TIMES/2;
parameter IDLE_CLOCKS  = 2;

//////////CarState ts(timeup_GRR,timeup_RGG,timeup_YELLOW,timeup_RED,reset,load,decr,S1,S2,S3,Reset,Clock,L1,L2,L3);

initial
begin
	$display("               Time Clock Reset  S1  S2  S3  L1   L2   L3 ");
	$monitor($time, "  %b     %b     %b      %b     %b    %b    %b        %b ",Clock,Reset,S1,S2,S3,L1,L2,L3);
end 

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
{Reset} = 1'b1;repeat (2) @(negedge Clock); // RESET
{Reset} = 1'b0;repeat (2) @(negedge Clock); // RESET
repeat (2) @(negedge Clock); {S1,S2,S3} = 3'b000;	
repeat (2) @(negedge Clock); {S1,S2,S3} = 3'b001;	
repeat (2) @(negedge Clock); {S1,S2,S3} = 3'b010; 	
repeat (2) @(negedge Clock); {S1,S2,S3} = 3'b011;	
repeat (2) @(negedge Clock); {S1,S2,S3} = 3'b100;	
repeat (2) @(negedge Clock); {S1,S2,S3} = 3'b101;	
repeat (2) @(negedge Clock); {S1,S2,S3} = 3'b110; 
repeat (2) @(negedge Clock); {S1,S2,S3} = 3'b111; 
repeat (2) @(negedge Clock);
$stop;
end
endmodule




