`timescale 1ns / 1ps

module SSEG_MUX(
    input CLK,
    input DEAL,
    input inGame,
    input [19:0] POUT,
    input [19:0] DOUT,
    input [19:0] menuDisp,
    output logic [19:0] DISP_IN
    );
    
    logic [19:0] nextDISP_IN;
              
            
    always_ff @(posedge CLK) begin
        DISP_IN <= nextDISP_IN;
    end
    always_comb begin 
    
    end
    always_comb begin
        case({DEAL, inGame})
            2'b01: begin        // Game is ON (1), Dealer Switch is OFF (0)
                nextDISP_IN = POUT;
            end
            2'b11: begin        // Game is ON (1), Dealer Switch is ON (1)
                nextDISP_IN = DOUT;
            end
            default: begin      // Game is OFF (0) -> Menu Mode
                nextDISP_IN = menuDisp;
            end
        endcase
    end
        
endmodule