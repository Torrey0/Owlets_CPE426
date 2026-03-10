`timescale 1ns / 1ps

module Menu(
    input CLK,
    input RST,
        input menu_En, //are we currently in menu mode? if not, dont change values on presses
    //btns Inputs
                input btnU,
    input btnL, input btnC, input btnR,
                input btnD,
    input playerWin,
    input dealerWin,
    output logic [19:0] menuDisp    //what we display to the SSEG
    );
    logic [19:0] nextMenuDisp;
    
    //the one shot makes button inputs high for 4 CC's or something wierd like that
    //convert button inputs to 1 clock cycle pulses
    logic btnUPulse, btnLPulse, btnRPulse, btnDPulse;
    logic btnUPrev, btnLPrev, btnRPrev, btnDPrev;
    always_ff @(posedge CLK) begin
        btnUPrev <= btnU;
        btnLPrev <= btnL;
//        btnCPrev <= btnC;
        btnRPrev <= btnR;
        btnDPrev <= btnD;
    end
    
    always_comb begin
        //1 cycle on rising edge
        btnUPulse = !btnUPrev && btnU;
        btnLPulse = !btnLPrev && btnL;
//        btnCPulse = !btnCPrev && btnC;
        btnRPulse = !btnRPrev && btnR;
        btnDPulse = !btnDPrev && btnD;
    end  
    //end of btn Crap
    
    
    logic [11:0] balance;   //indicate with B on SSEG
    logic [11:0] gamble;    //indicate with g on SSEG 
    logic [11:0] nextBalance;
    logic [11:0] nextGamble;    
    
    logic [1:0] gambleIndex; //3= B/G Index. 2,1,0 = index for that hex Value of gamble
    logic [1:0] nextGambleIndex;
    
    logic displayGamble;    //displayGamble or displayBalance mode
    logic nextDisplayGamble;

    //flicker current index:
    logic [27:0] Count;
    logic flicker;
    always_ff @(posedge CLK) begin
        if (RST ) begin
            Count <= 0;
            flicker <= 0;
        end else if(Count >= 67108864) begin //2^26, around .62 seconds per flickerbegin
            Count <= 0;
            flicker <= !flicker;
        end else begin
            Count <= Count + 1;
        end
    end
    //
    
    always_ff @(posedge CLK) begin
        if (RST) begin
            balance <= 100;
            gamble <= 10;
            displayGamble <= 0;
            menuDisp <= 0;
            gambleIndex <= 0;
        end else begin
            balance <= nextBalance;
            gamble <= nextGamble;
            displayGamble <= nextDisplayGamble;
            menuDisp <= nextMenuDisp;
            gambleIndex <= nextGambleIndex;            
        end
    end
    
    logic [11:0] targetNextGamble;
    logic [11:0] gambleIncrement;
    always_comb begin
        //default behav
        nextBalance = balance;
        nextGambleIndex = gambleIndex;
        gambleIncrement = 0;
        nextDisplayGamble = displayGamble;
        targetNextGamble = gamble;
        if(gamble > balance) begin
            nextGamble = balance; //ensure after a loss, that they cant end up gambling more than they have
        end else begin
            nextGamble = gamble; //default value
        end
        //
        
        if(playerWin) begin
            nextBalance = balance + gamble;
        end else if (dealerWin) begin
            nextBalance = balance - gamble;
        end else if(menu_En && ! btnC) begin //in menu, and not pressing button to start
            //allow user to slide there index
            if(btnLPulse) begin
                nextGambleIndex = gambleIndex + 1;
            end else if(btnRPulse) begin
                nextGambleIndex = gambleIndex - 1;
            end
            
            case (gambleIndex)
                2'b00: begin
                        gambleIncrement = 1;
                    end
                    2'b01: begin
                        gambleIncrement = 16;
                    end
                    2'b10: begin
                       gambleIncrement = 256;
                    end                    
                    2'b11: begin
                        if(btnUPulse || btnDPulse) begin
                            nextDisplayGamble = !displayGamble;
                        end
                    end
                    default: begin end
            endcase
            
            if(btnUPulse) begin  
                targetNextGamble = gamble + gambleIncrement;
            end else if (btnDPulse && gamble >= gambleIncrement) begin
                targetNextGamble = gamble - gambleIncrement;
            end      
            
            if(targetNextGamble <= balance) begin
                nextGamble = targetNextGamble;  //ok amount to gamble
            end        
        end

        if(displayGamble) begin
            if(flicker && gambleIndex == 3) begin
                nextMenuDisp[19 : 15] = 5'b11111; //turn off
            end else begin
                nextMenuDisp [19:15] = 9;   //drive the g for SSEG
            end
            for(int i = 0; i < 3; i++) begin
                if(flicker  && i == gambleIndex) begin
                    nextMenuDisp[i*5 +: 5] = 5'b11111; //turn off
                end else begin
                    nextMenuDisp [i*5 +: 4] = gamble[i*4 +: 4];
                    nextMenuDisp [4 + i*5] =0;
                end
            end
        end else begin
            if(flicker && gambleIndex == 3) begin
                nextMenuDisp[19 : 15] = 5'b11111; //turn off
            end else begin
                nextMenuDisp [19:15] = 4'hb;   //drive the b for SSEG
            end
            
            for(int i = 0; i < 3; i++) begin
                if(flicker  && i == gambleIndex) begin
                    nextMenuDisp[i*5 +: 5] = 5'b11111; //turn off
                end else begin
                    nextMenuDisp [i*5 +: 4] = balance[i*4 +: 4];
                    nextMenuDisp [4 + i*5] = 0;
                end
            end
        end        
    end
    
endmodule
