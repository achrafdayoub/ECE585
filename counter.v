//
// Synthesizable counter module 
//

module counter(clk, reset, load, value, decr, timeup);
input clk, reset, load, decr;
input [7:0] value;
output timeup;

reg [7:0] count;

assign timeup = (count == 0) ? 1 : 0;  // 1 if true or 0 if false

always @(posedge clk)
  begin
  if (reset)	
    count <= 0;
  else if (load)
  	begin
    count <= value;
    end
  else if (decr && (count != 0))
  	begin
    count <= count - 8'b1;
    end
  else
    count <= count;
  end  
endmodule