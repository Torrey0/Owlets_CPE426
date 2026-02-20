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
    
    logic dealer = 0, next_dealer, LD, STing, next_STing, inc_ppos, inc_dpos;
    logic [1:0] ppos_reg, dpos_reg;
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
    end else begin
        NS = PS;
    end
    
    inc_ppos = 0;
    inc_dpos = 0;      
    LD = 0;
    next_dealer = 0;
    card_used = 0;
    next_STing = 0;
    
    case (PS)
        START:
            begin
            LEDs = 16'h0001;
            inc_ppos = 0;
            inc_dpos = 0;
            next_STing = 1;
            
            if(HIT) begin
                NS = ST_DEAL;
            end else begin
                NS = PS;
            end
        end
            
        ST_DEAL:
            begin
            LEDs = 16'h0002;
            next_STing = 1;
            if(dpos_reg == 2'b10) begin
                next_STing = 0;
                NS = PLAY;
            end else if(RDY) begin
                if(dpos_reg < ppos_reg) next_dealer = 1;
                else next_dealer = 0;
                NS = DEAL;
            end else begin
                NS = PS;
            end
        end
        
        DEAL:
            begin
            LEDs = 16'h0004;
            card_used = 1;
            LD = 1; 
            if(dealer) begin
                if(STing) begin
                    next_STing = 1;
                    NS = ST_DEAL;
                end else begin
                    next_STing = 0;
                    NS = PEND;
                end
                inc_dpos = 1;
            end else begin
                if(STing) begin
                    NS = ST_DEAL;
                    next_STing = 1;
                end else begin
                    next_STing = 0;
                    NS = PLAY;
                end
                inc_ppos = 1;
            end
        end
        
        PLAY:
            begin
            LEDs = 16'h0008;
            
            if(pcnt > 5'h15) begin
                NS = GEND;
            end else if(HIT & RDY) begin
                next_dealer = 0;
                NS = DEAL;
            end else if(STAND) begin
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
                next_dealer = 1;
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
            if((pcnt > dcnt & pcnt < 22)| (dcnt > 21 & pcnt < 22)) begin
                LEDs = 16'hFFFF;
            end else begin
                LEDs = 16'h5555;
            end
        end
        
        default: 
            begin
            NS = START;
            inc_ppos = 0;
            inc_dpos = 0;         
            LD = 0;
            next_dealer = 0;
            card_used = 0;
            next_STing = 0;
            LEDs = 16'h0000;
            end
    endcase 
    end
    
    always_ff @(posedge CLK) begin
        if(EN | RST) begin
            PS <= START;
            ppos_reg <= 2'b00;
            dpos_reg <= 2'b00;
        end else begin
            PS <= NS;
            ppos_reg <= ppos_reg + inc_ppos;
            dpos_reg <= dpos_reg + inc_dpos;
        end
        dealer <= next_dealer;
        STing <= next_STing;
//        HIT_OLD <= HIT;
//        STAND_OLD <= STAND;
//        if(~HIT_OLD & HIT) HIT_VAL <= 1;
    end
    
    
endmodule


