`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2024 04:47:37 PM
// Design Name: 
// Module Name: Rand_Num_TB
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


module Rand_Num_TB();
    logic EN_TB,CLK_TB;
    logic [3:0] D_TB;
    
    Rand_Num UUT (.EN(EN_TB),.CLK(CLK_TB),.D(D_TB));
    
    always begin
    #5 CLK_TB = 1;
    #5 CLK_TB = 0;
    end
    
    always begin
    #10 EN_TB = 1;
    
    #10 EN_TB = 0;
    end

endmodule
