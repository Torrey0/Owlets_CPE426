`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jack Karpinski
// 
// Create Date: 03/12/2024 12:30:36 AM
// Design Name: 
// Module Name: FSM
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


module FSM(
    input CLK, EN, RDY, RST,
    input HIT, STAND,
    input [4:0] dcnt, pcnt,
    output logic card_used, pld, dld,
    output logic [1:0] POS,  
    output logic [15:0] LED
    );
    
    logic dealer = 0, next_dealer, LD, STing;// HIT_OLD, STAND_OLD,HIT_VAL,STAND_VAL;
    logic [1:0] ppos_reg, dpos_reg,next_ppos_reg,next_dpos_reg;
    logic [15:0] LEDs;
    
    typedef enum {START, DEAL, PLAY, PEND, GEND, ST_DEAL} STATES;
    STATES PS, NS;
    
    assign dld = (dealer) ? LD : 1'b0;
    assign pld = (dealer) ? 1'b0 : LD;
    assign POS = (dealer) ? dpos_reg : ppos_reg;
 
    assign LED = {STing, LD, dealer, dpos_reg, ppos_reg, 9'h0000} | LEDs;
    
    always_comb
    begin
    if(RST) begin
        NS = START;
    end
    
    case (PS)
        START:
            begin
            LEDs = 16'h0001;
            next_ppos_reg = 2'b00;
            next_dpos_reg = 2'b00;          
            LD = 0;
            next_dealer = 0;
            card_used = 0;
            STing = 1;
            
            if(HIT) begin
                NS = ST_DEAL;
            end
            end
            
        ST_DEAL:
            begin
            LEDs = 16'h0002;
            LD = 0;
            card_used = 0;
            if(dpos_reg == 2'b10) begin
                STing = 0;
                NS = PLAY;
            end else if(RDY) begin
                NS = DEAL;
            end else begin
                NS = PS;
            end
            end
        
        DEAL:
            begin
            LEDs = 16'h0004;
            card_used = 1;
            if(dealer) begin
                if(STing) begin
                    next_dealer = 0;
                    NS = ST_DEAL;
                end else begin
                    NS = PEND;
                end
                next_dpos_reg = dpos_reg + 2'b01;
            end else begin
                if(STing) begin
                    next_dealer = 1;
                    NS = ST_DEAL;
                end else begin
                    NS = PLAY;
                end
                next_ppos_reg = ppos_reg + 2'b01;
            end
            LD = 1; 
            end
        PLAY:
            begin
            LEDs = 16'h0008;
            LD = 0;
            card_used = 0;
            if(pcnt > 5'h15) begin
                NS = GEND;
            end else if(HIT & RDY) begin
                NS = DEAL;
            end else if(STAND) begin
                next_dealer = 1;
                NS = PEND;
            end else begin
                NS = PS;
            end
            end
        PEND:
            begin
            LEDs = 16'h0010;
            card_used = 0;
            if(dcnt < 5'h11) begin
//                next_dpos_reg = dpos_reg + 2'b01;
                LD = 0; 
                card_used = 0;
                NS = DEAL;
            end else begin
                NS = GEND;
            end
            end
        GEND:
            begin
            LEDs = 16'h0020;
            NS = PS;
            LD = 0;
            if((pcnt > dcnt & pcnt < 21)| (dcnt >21 & pcnt < 22)) begin
                LEDs = 16'hFFFF;
            end else begin
                LEDs = 16'h5555;
            end
            end
        default: 
            begin
            NS = START;
            next_ppos_reg = 2'b00;
            next_dpos_reg = 2'b00;          
            LD = 0;
            next_dealer = 0;
            card_used = 0;
            STing = 0;
            LEDs = 16'h0000;
            end
    endcase 
    end
    
    always_ff @(posedge CLK) begin
        if(EN | RST) PS <= START;
        else PS <= NS;
        ppos_reg <= next_ppos_reg;
        dpos_reg <= next_dpos_reg;
        dealer <= next_dealer;
//        HIT_OLD <= HIT;
//        STAND_OLD <= STAND;
//        if(~HIT_OLD & HIT) HIT_VAL <= 1;
    end
    
    
endmodule


