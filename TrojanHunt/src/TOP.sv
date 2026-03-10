`timescale 1ns / 1ps

module TOP(
    input CLK,
    input Reset_SW, 
    input btnU, btnL, btnC, btnR, btnD,
    output [6:0] SSEG,
    output [3:0] DISP,
//    output DP,
    output [15:0] LED
    );
    
    
 // internal signals
 logic [19:0] POUT, DOUT, menuDisp, DISP_IN; //Output to Decoder
 logic PLD, DLD, DEAL = 0; //FSM
 logic [5:0] DCNT, PCNT;
 logic [1:0] POS; 
 logic [3:0] Random; //Rand_card
 logic SCLK1, SCLK2, USED, RDY;
 
 logic btnU_DEB, btnL_DEB, btnC_DEB, btnR_DEB, btnD_DEB;
 //in game buttons.
 logic RST;
 assign RST= Reset_SW; //moved RST to a switch
 
 logic STAND_DEB, HIT_DEB, SW_DEB, SW_OLD;
// assign STAND_DEB = btnU_DEB;
// assign HIT_DEB = btnC_DEB;
 assign SW_DEB = btnD_DEB;
  //
 
 //managing menu <-> game transition
 logic playerWin, dealerWin, gameEnd;
 logic gameStart;  //resets game FSM
 wire inGame = !menu_En;
assign LED[15] = DEAL && inGame;
logic handReset;
 assign handReset = menu_En || RST;
 logic shuffle;
 logic RST_deck;
 assign RST_deck = RST || shuffle;

 
 //SW control
 always_ff @(posedge CLK) begin
    if(RST) DEAL <= 0;
    else if(~SW_OLD & SW_DEB) DEAL <= ~DEAL;
    else DEAL <= DEAL;
    SW_OLD <= SW_DEB;
 end
 

    //connections for all of the modules
    DebOneShot btnC_CNTRL    (.IN(btnC), .RST(RST),.CLK(CLK), .OUT(btnC_DEB));
    DebOneShot btnL_CNTRL    (.IN(btnL), .RST(RST), .CLK(CLK), .OUT(btnL_DEB));
    DebOneShot btnR_CNTRL    (.IN(btnR), .RST(RST), .CLK(CLK), .OUT(btnR_DEB));
    DebOneShot btnU_CNTRL    (.IN(btnU), .RST(RST), .CLK(CLK), .OUT(btnU_DEB));
    DebOneShot btnD_CNTRL    (.IN(btnD), .RST(RST), .CLK(CLK), .OUT(btnD_DEB));
    // --- 1-Cycle Edge Detectors ---
    logic btnC_delay, btnU_delay;
    logic btnC_pulse, btnU_pulse;
    
    always_ff @(posedge CLK) begin
        btnC_delay <= btnC_DEB;
        btnU_delay <= btnU_DEB;
    end
    
    assign btnC_pulse = btnC_DEB & ~btnC_delay;
    assign btnU_pulse = btnU_DEB & ~btnU_delay;
    
    assign STAND_DEB = btnU_pulse;
    assign HIT_DEB = btnC_pulse;
    //

    Design_State_Ctrl ctrl  (.CLK(CLK), .RST(RST), .gameEnd(gameEnd), .btnC(btnC_pulse), .gameStart(gameStart), .menu_En(menu_En), .shuffle(shuffle));
    
    clk_div2 Slow            (.CLK(CLK), .SCLK(SCLK1));
    CLK_Div Slower            (.CLK(CLK), .SCLK(SCLK2));
    FSM  FSM (.CLK(CLK), .START(gameStart), .RDY(RDY), .RST(RST), .HIT(HIT_DEB),
            .STAND(STAND_DEB), .dcnt(DCNT), .pcnt(PCNT), .card_used(USED), 
            .pld(PLD), .dld(DLD), .playerWin(playerWin), .dealerWin(dealerWin), .gameEnd(gameEnd), .LED(), .POS(POS));
    LFSR Randn             (.CLK(CLK), .RST(RST_deck), .USED(USED), .RND(Random), .RDY(RDY));
    BJRegister P_HAND      (.CLK(CLK), .CLR(handReset), .LD(PLD), .POS(POS), .D(Random), .Q(POUT), .CNT(PCNT));  
    BJRegister D_HAND      (.CLK(CLK), .CLR(handReset), .LD(DLD), .POS(POS), .D(Random), .Q(DOUT), .CNT(DCNT)); 
    Menu menu (.CLK(CLK), .RST(RST), .menu_En(menu_En),
            .btnU(btnU_DEB),  .btnL(btnL_DEB), .btnC(btnC_DEB), .btnR(btnR_DEB), .btnD(btnD_DEB), 
            .playerWin(playerWin), .dealerWin(dealerWin), .menuDisp(menuDisp));
    SSEG_MUX sseg_sel   (.CLK(CLK), .DEAL(DEAL), .inGame(inGame), .POUT(POUT), .DOUT(DOUT), .menuDisp(menuDisp), .DISP_IN(DISP_IN));
    sseg_des Disp           (.COUNT(DISP_IN), .SCLK(SCLK1), .VALID(1'b1), .SEGMENTS(SSEG), .DISP_EN(DISP));  
    LED_Animation leds (.CLK(SCLK2), .START(gameStart), .DEAL(PLD), .HIT(HIT_DEB), .RND(Random), .LEDS(LED[14:0]));
     
    
endmodule