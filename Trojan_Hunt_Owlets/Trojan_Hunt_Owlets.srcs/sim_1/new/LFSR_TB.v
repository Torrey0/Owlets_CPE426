`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 06:45:42 PM
// Design Name: 
// Module Name: LFSR_TB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LSFR_TB;

 // Inputs
 reg clock;
 reg reset;

 // Outputs
 wire [5:0] rnd;

 // Instantiate the Unit Under Test (UUT)
 LFSR uut (
  .clock(clock), 
  .reset(reset), 
  .rnd(rnd)
 );
 
 initial begin
  clock = 0;
  forever
   #50 clock = ~clock;
  end
  
 initial begin
  // Initialize Inputs
  
  reset = 0;

  // Wait 100 ns for global reset to finish
  #100;
      reset = 1;
  #200;
  reset = 0;
  // Add stimulus here

 end
 
 initial begin
 $display("clock rnd");
 $monitor("%b,%b", clock, rnd);
 end      
endmodule
