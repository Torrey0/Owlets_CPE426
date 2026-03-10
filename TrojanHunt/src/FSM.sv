`timescale 1ns / 1ps

module FSM(
    input CLK, START, RDY, RST, //start and RST do samething. take it up with the foreman idk.
    input HIT, STAND,
    input [5:0] dcnt, pcnt,
    output logic card_used, pld, dld,
    output logic [1:0] POS,  
    output logic playerWin, dealerWin,
    output gameEnd,
    output logic [14:0] LED
    );
    logic nextPlayerWin, nextDealerWin;
    
    logic dealer = 0, next_dealer, LD, STing, next_STing, inc_ppos, inc_dpos;
    logic [2:0] ppos_reg;
    logic [2:0] dpos_reg;
    logic [15:0] LEDs;
    
    typedef enum {START_ST, DEAL, PLAY, PEND, GEND, ST_DEAL, IDLE} STATES;
    STATES PS, NS;
    
    assign dld = (dealer) ? LD : 1'b0;
    assign pld = (dealer) ? 1'b0 : LD;
    assign POS = (dealer) ? dpos_reg : ppos_reg;
 
    assign gameEnd = (PS == GEND) || (PS == IDLE);
    
    assign LED = {LD, dealer, dpos_reg, ppos_reg, 9'h0000} | LEDs;
    
    always_comb begin
            
        inc_ppos = 0;
        inc_dpos = 0;      
        LD = 0;
        next_dealer = 0;
        card_used = 0;
        next_STing = 0;
        nextPlayerWin = 0;
        nextDealerWin = 0;
        
        case (PS)
            START_ST:
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
                end else if(RDY) begin  // wait for random num
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
                
                if(pcnt > 5'h15 || ppos_reg == 4) begin
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
                if(dcnt < 5'h11 && dpos_reg < 4) begin
                    if (RDY) begin    
                        next_dealer = 1;
                        LD = 0; 
                        NS = DEAL;
                    end else begin
                        NS = PS;
                    end
                end else begin
                    NS = GEND;
                end
            end
            
            GEND:
                begin
                LEDs = 16'h0020;
                NS = IDLE;
                LD = 0;
                if(pcnt < 22 && ( (pcnt > dcnt) || (dcnt > 21) || (ppos_reg == 4) ) ) begin    //condition for player to win
                    LEDs = 16'hFFFF;
                    nextPlayerWin = 1;
                end else begin
                    LEDs = 16'h5555;
                    nextDealerWin = 1;
                end
            end
            
            IDLE: begin //may not be warranted, adding temporarily
                LEDs = 16'h0020;
                NS = IDLE;
                LD = 0;
                if(pcnt < 22 && ( (pcnt > dcnt) || (dcnt > 21) || (ppos_reg == 4) ) )begin    //condition for player to win
                    LEDs = 16'hFFFF;
                end else begin
                    LEDs = 16'h5555;
                end
            end
            
            default: 
                begin
                NS = START_ST;
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
        if(START || RST) begin
            PS <= START_ST;
            ppos_reg <= 2'b00;
            dpos_reg <= 2'b00;
            playerWin <= 0;
            dealerWin <= 0;
        end else begin
            PS <= NS;
            ppos_reg <= ppos_reg + inc_ppos;
            dpos_reg <= dpos_reg + inc_dpos;
            playerWin <= nextPlayerWin;
            dealerWin <= nextDealerWin;
        end
        dealer <= next_dealer;
        STing <= next_STing;
//        HIT_OLD <= HIT;
//        STAND_OLD <= STAND;
//        if(~HIT_OLD & HIT) HIT_VAL <= 1;
    end
    
    
endmodule


