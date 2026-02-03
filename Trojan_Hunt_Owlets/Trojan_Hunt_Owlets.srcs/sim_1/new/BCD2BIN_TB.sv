`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/12/2024 04:35:10 PM
// Design Name: 
// Module Name: BCD2BIN_TB
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


module BCD2BIN_TB();
    logic [15:0] IN_TB;
    logic [13:0] OUT_TB;
    
    BCD2BIN UUT (.IN(IN_TB),.OUT(OUT_TB));
    
    always begin
    #10 IN_TB = 16'b0000000000000010;
    #10 IN_TB = 16'b0000000000100000;
    #10 IN_TB = 16'b0000001000000000;
    #10 IN_TB = 16'b0010000000000000;
    
    end
    

endmodule
