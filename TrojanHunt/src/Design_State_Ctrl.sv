`timescale 1ns / 1ps

module Design_State_Ctrl(
    input CLK,
    input gameEnd,
    input RST,
    input btnC,
    output logic shuffle,
    output logic menu_En,
    output logic gameStart
    );
    logic nextMenu_En;
    
    logic [3:0] gameCnt = 0;    
    logic [3:0] nextGameCnt;
    
    always_ff @(posedge CLK) begin
        gameStart <= menu_En && !nextMenu_En;
        if(RST) begin
            menu_En <= 1;
            gameCnt <= 0;
        end else begin
            menu_En <= nextMenu_En;
            gameCnt <= nextGameCnt;
        end
    end
    
    always_comb begin
        nextMenu_En = menu_En;
        shuffle = 0;
        nextGameCnt = gameCnt;
        if(btnC && gameEnd && !menu_En) begin   //game just ended
            nextMenu_En = 1;   //enable the menu
            if(gameCnt == 7) begin //re-shuffle after 7 games
                nextGameCnt = 0;
                shuffle = 1;
            end else begin
                nextGameCnt = gameCnt + 1;
            end
        end else if (btnC && menu_En) begin
            nextMenu_En = 0;   //leave the menu
        end
        
    end
    
endmodule
