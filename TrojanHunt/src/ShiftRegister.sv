`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Bridget Benson (modified heavily by Jack Karpinski)
// Create Date: 10/26/2018 01:04:29 PM
// Description: 8 bit shift register 
// SEL: 0 - HOLD
//      1 - LOAD
//      2 - LEFT SHIFT
//      3 - RIGHT SHIFT
//////////////////////////////////////////////////////////////////////////////////


module BJRegister( //MODIFIED from original
    input CLK, LD, CLR,
    input [3:0] D,
    input [1:0] POS,
    output logic [15:0] Q,
    output logic [5:0] CNT
    );
    
    logic [4:0] D_val1, D_val2, D_val3, D_val4;
    
    always_ff @ (posedge CLK)
    begin
        if (CLR)
            Q <= 16'hFFFF; // Reset
        else if(LD) begin
            case (POS)
                0: Q[3:0] <= D; // first 4
                1: Q[7:4] <= D; // second 4
                2: Q[11:8] <= D; //third 4
                3: Q[15:12] <= D; //fourth 4             
             endcase 
        end
     end
     
     always_comb begin
        case(Q[3:0]) //first value
            0: D_val1 = 4'ha; 1: D_val1 = 4'h1; 2: D_val1 = 4'h2; 3: D_val1 = 4'h3; 4: D_val1 = 4'h4; 5: D_val1 = 4'h5; 6: D_val1 = 4'h6; 
            7: D_val1 = 4'h7; 8: D_val1 = 4'h8; 9: D_val1 = 4'h9; 10: D_val1 = 4'ha; 11: D_val1 = 4'ha; 12: D_val1 = 4'ha;
            default: D_val1 = 0;
        endcase
        case(Q[7:4]) //second value
            0: D_val2 = 4'ha; 1: D_val2 = 4'h1; 2: D_val2 = 4'h2; 3: D_val2 = 4'h3; 4: D_val2 = 4'h4; 5: D_val2 = 4'h5; 6: D_val2 = 4'h6; 
            7: D_val2 = 4'h7; 8: D_val2 = 4'h8; 9: D_val2 = 4'h9; 10: D_val2 = 4'ha; 11: D_val2 = 4'ha; 12: D_val2 = 4'ha;
        default: D_val2 = 0;
        endcase
        case(Q[11:8]) //thrid value
            0: D_val3 = 4'ha; 1: D_val3 = 4'h1; 2: D_val3 = 4'h2; 3: D_val3 = 4'h3; 4: D_val3 = 4'h4; 5: D_val3 = 4'h5; 6: D_val3 = 4'h6; 
            7: D_val3 = 4'h7; 8: D_val3 = 4'h8; 9: D_val3 = 4'h9; 10: D_val3 = 4'ha; 11: D_val3 = 4'ha; 12: D_val3 = 4'ha;
            default: D_val3 = 0;
        endcase
        case(Q[15:12]) //fourth value
            0: D_val4 = 4'ha; 1: D_val4 = 4'h1; 2: D_val4 = 4'h2; 3: D_val4 = 4'h3; 4: D_val4 = 4'h4; 5: D_val4 = 4'h5; 6: D_val4 = 4'h6; 
            7: D_val4 = 4'h7; 8: D_val4 = 4'h8; 9: D_val4 = 4'h9; 10: D_val4 = 4'ha; 11: D_val4 = 4'ha; 12: D_val4 = 4'ha;
            default: D_val4 = 0;
        endcase
        
        CNT = D_val1 + D_val2 + D_val3 + D_val4;
     end
             
       
    
endmodule
