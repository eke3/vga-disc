`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:29:41 02/13/2016 
// Design Name: 
// Module Name:    debounce_and_oneshot 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
module button_debouncer #(
    parameter MINWIDTH = 5000000, //how many cycles must the btn be pressed
    parameter COUNTERWIDTH = 32
) (
    output logic btnout,
    input logic btn,
    input logic sys_clk,
    input logic rst
);


logic [COUNTERWIDTH-1:0] counter = 0;
logic shot = 0;
logic btnout_ = 0;

always_ff @(posedge sys_clk, posedge rst) begin
  if (rst) begin
    counter <= 0;
    btnout_ <= 1'b0;  
    shot <= 1'b0;  
  end else begin
	   if (~btn) begin
		    counter <= 0;
		    btnout_  <= 1'b0;
          shot <= 1'b0;  
      end else if (counter!=MINWIDTH) begin
		    counter<=counter+1;
		    btnout_  <= 1'b0;
          shot <= 1'b0;  
      end else begin //we have reached MINWIDTH
			 counter<=counter;
		    if (shot == 0) begin
			   shot <= 1'b1;
      		 btnout_ <=1'b1;
			 end else begin 
			 	shot <= shot;
      		 btnout_ <=1'b0;
			 end
		end
		
	end
end //end always

assign btnout = btnout_;

endmodule
