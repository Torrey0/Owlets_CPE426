`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Jack Karpinski
// 
// Create Date: 03/12/2024 04:08:48 PM
// Design Name: 
// Module Name: Rand_Num
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


module Rand_Num(
    input CLK,
    output logic [3:0] D
    );
    logic [3:0] random;
    
    always_ff @(posedge CLK)
    begin
        D = $urandom_range(0,9); // assigns a random number from 0 to 9 to D
    end
    
    
    
    
endmodule
