`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/14/2024 10:06:41 PM
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


module LFSR_TB();
    logic CLK_TB,RST_TB;
    logic [5:0] RND_TB;
    
    LFSR UUT (.CLK(CLK_TB),.RST(RST_TB),.RND(RND_TB));
    
    always begin
    #5 CLK_TB = 1;
    #5 CLK_TB = 0;
    end
    
    
    always begin
    #100 RST_TB = 1;
    #10 RST_TB = 0;
    #500;
    end

endmodule
