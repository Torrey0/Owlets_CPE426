`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Jack Karpinski
// 
// Create Date: 03/12/2024 04:23:36 PM
// Design Name: 
// Module Name: BCD2BIN
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


module DEC(
    input [3:0] IN,
    input [1:0] POS,
    input CLK,
    output logic [15:0] OUT
    );
    always_ff @(posedge CLK) begin
        case(POS)
            2'b00: OUT[3:0] <= IN;
            2'b01: OUT[7:4] <= IN;
            2'b10: OUT[11:8] <= IN;
            2'b11: OUT[15:12] <= IN;
        endcase
    end
    
endmodule
