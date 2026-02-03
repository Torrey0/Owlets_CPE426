`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jack Karpinski
// 
// Create Date: 03/12/2024 10:57:05 AM
// Design Name: 
// Module Name: TOP
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


module TOP(
    input EN,
    input RST,
    input CLK,
    output [7:0] SSEG,
    output [3:0] DISP,
    output [15:0] LED
    );
    
 // internal signals
 logic [15:0] DEC_IN; //ShiftReg Output to Decoder
 logic [13:0] ACC_IN, DISP_IN; // Accumulator in and out
 logic LD1; //FSM
 logic [2:0] Shift1; 
 logic [7:0] D1; //Rand_num
 logic SCLK; // slow_clock

     //connections for all of the modules
    clk_div2 Slow            (.CLK(CLK), .SCLK(SCLK));   
    FSM  FSM                 (.CLK(CLK), .EN(EN), .LED(LED), .POS(POS), .Shift(Shift1));
    //Rand_Num Randn           (.CLK(SCLK), .D(D1));
    LFSR Randn               (.CLK(CLK),.RST(RST),.RND(D1));
    ShiftRegister Shift      (.clk(CLK), .CLR(RST), .SEL(Shift1), .D({12'b000000000000,D1[6:4],D1[0]}), .Q(DEC_IN)); 
    DEC Deco             (.IN(DEC_IN), .CLK(CLK), .POS(POS), .OUT(ACC_IN)); 
    Accumulator ACK          (.clk(CLK), .LD(LD1), .CLR(RST), .D(ACC_IN), .Q(DISP_IN));
    sseg_des Disp           (.COUNT(DISP_IN), .CLK(CLK), .VALID(1), .SEGMENTS(SSEG), .DISP_EN(DISP));  
      
     
    
endmodule
