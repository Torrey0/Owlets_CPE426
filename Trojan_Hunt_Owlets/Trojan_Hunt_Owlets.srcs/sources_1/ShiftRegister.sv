`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Bridget Benson (modified by Jack Karpinski)
// Create Date: 10/26/2018 01:04:29 PM
// Description: 8 bit shift register 
// SEL: 0 - HOLD
//      1 - LOAD
//      2 - LEFT SHIFT
//      3 - RIGHT SHIFT
//////////////////////////////////////////////////////////////////////////////////


module ShiftRegister( //MODIFIED from original

    input clk, CLR,
    input [15:0] D,
    input [2:0] SEL,
    output logic [15:0] Q = 0
    );
     // Modified to Shift an input by 4, 8, and 12 
     // Used to multiply a BCD input by 10, 100, and 1000
    always_ff @ (posedge clk)
    begin
    
        if (CLR)
            Q <= 0; // Reset
        else  
            case (SEL)
                1: Q <= D; // No shift
                2: Q <= {D[11:0], 4'h0}; // Shift left by 4 bits
                3: Q <= {D[7:0], 8'h0}; // Shift left by 8 bits
                4: Q <= {D[3:0], 12'h0}; // Shift left by 12 bits
                //option zero means hold               
             endcase
             
     end
             
       
    
endmodule
