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

//for mapping face cards onto custom symbols for SSEG
`define AceDisplay 20
`define faceCardDisplayOffset 8

module BJRegister( //MODIFIED from original
    input CLK, LD, CLR,
    input [3:0] D,
    input [1:0] POS,
    output logic [19:0] Q,  //5 bit per entry. output to SSEG
    output logic [5:0] CNT
    );
    
    logic [3: 0] D_reg [3:0];   //store incoming data
    //cards interpreted as: 0 -> 2, ..., 12 -> A
    
    logic [4:0] Data_val [3:0];  //to determine CNT.
    
    logic [2:0] aceCount;
    
    logic [19:0] nextQ; //next display for SSEG.
    
    //this is indexing, not shifting. but whatever.
    //the shift reg
    always_ff @ (posedge CLK) begin
        Q <= nextQ;
        if (CLR)
            D_reg <= '{default: 4'b1111}; // Reset
        else if(LD) begin
            case (POS)
                0: D_reg[0] <= D;
                1: D_reg[1] <= D;
                2: D_reg[2] <= D;
                3: D_reg[3] <= D;     
             endcase 
        end
     end
     
     
     //why is this logic here?
      //cards interpreted as: 0 -> 2, ..., 12 -> A
     //drive Q for display
     always_comb begin
        for(int i = 0; i < 4; i++) begin
            if(D_reg[i] == 4'b1111) begin
                nextQ[i*5 +: 5] = 5'b11111; //blank
            end else if(D_reg[i] <=7 ) begin
                nextQ[i*5 +: 5] = D_reg[i] + 2;  //map 0+ -> 2+
            end else begin
                nextQ[i*5 +: 5] = D_reg[i] + `faceCardDisplayOffset; //map 8+ -> 10+ -> 16+ for face cards
            end

        end
     end
     
    //drive D_val for computation
    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : gen_Values
            always_comb begin
                if(D_reg[i] <= 8) begin
                Data_val[i] = D_reg[i] + 2; //normal cards
                end else if (D_reg[i] <= 11) begin
                    Data_val[i] = 10;   //face cards
                end else if (D_reg[i] == 12) begin
                    Data_val[i] = 11;   //ace
                end else begin
                    Data_val[i] = 0;
                end
            end
        end
    endgenerate
    
    always_comb begin        
        CNT = Data_val[0] + Data_val[1] + Data_val[2] + Data_val[3];
        
        //account for aces needing to be value 1 if CNT > 21
        aceCount = (Data_val[0] == 11) + (Data_val[1] == 11) + (Data_val[2] == 11) + (Data_val[3] == 11);
        
        for(int i = 0; i < 4; i++) begin
            if(CNT > 21 && aceCount !=0) begin
                CNT = CNT - 10; //ace value goes from 11 -> 1 (-10 for total CNT)
                aceCount = aceCount - 1;
            end
        end
        
     end
             
       
    
endmodule
