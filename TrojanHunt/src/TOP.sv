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
    input HIT,STAND,SW,
    output [6:0] SSEG,
    output [3:0] DISP,
    output [15:0] LED
    );
    
 // internal signals
 logic [15:0] POUT, DOUT, DISP_IN; //ShiftReg Output to Decoder
 logic PLD, DLD, DEAL = 0; //FSM
 logic [4:0] DCNT, PCNT;
 logic [1:0] POS; 
 logic [3:0] D1; //Rand_card
 logic SCLK, USED, RDY;
 logic HIT_DEB, SW_DEB, STAND_DEB, SW_OLD;
 
 //SW control
 assign DISP_IN = (DEAL) ? DOUT : POUT;
 always_ff @(posedge CLK) begin
    if(RST) DEAL <= 0;
    else if(~SW_OLD & SW_DEB) DEAL <= ~DEAL;
    else DEAL <= DEAL;
    SW_OLD <= SW_DEB;
 end

    //connections for all of the modules
    DebOneShot HIT_CNTRL    (.IN(HIT), .RST(RST),.CLK(CLK), .OUT(HIT_DEB));
    DebOneShot SW_CNTRL    (.IN(SW), .RST(RST), .CLK(CLK), .OUT(SW_DEB));
    DebOneShot STAND_CNTRL    (.IN(STAND), .RST(RST), .CLK(CLK), .OUT(STAND_DEB));
    clk_div2 Slow            (.CLK(CLK), .SCLK(SCLK));
    FSM  FSM (.CLK(CLK), .EN(EN), .RDY(RDY), .RST(RST), .HIT(HIT_DEB),
            .STAND(STAND_DEB), .dcnt(DCNT), .pcnt(PCNT), .card_used(USED), 
            .pld(PLD), .dld(DLD), .LED(LED), .POS(POS));
    LFSR Randn             (.CLK(CLK), .RST(RST), .USED(USED), .RND(D1), .RDY(RDY));
    BJRegister P_HAND      (.CLK(CLK), .CLR(RST), .LD(PLD), .POS(POS), .D(D1), .Q(POUT), .CNT(PCNT));  
    BJRegister D_HAND      (.CLK(CLK), .CLR(RST), .LD(DLD), .POS(POS), .D(D1), .Q(DOUT), .CNT(DCNT));  
    sseg_des Disp           (.COUNT(DISP_IN), .SCLK(SCLK), .VALID(1'b1), .SEGMENTS(SSEG), .DISP_EN(DISP));  
      
     
    
endmodule
