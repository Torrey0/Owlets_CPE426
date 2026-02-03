`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Jack Bergfeld & Jack Karpinski
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
    input CLK,
    input EN,
    inout logic card_RDY,  //pull low when grabs value
    output logic [1:0] POS,  //sseg position
    output logic [2:0] Shift,
    output logic [15:0] LED
    );
    
    logic LD;
    
    
    typedef enum {START, L1, L2, L3, L4, L5, L6, L7, L8, L9, L10, L11, L12, L13, L14, L15, L16, HOLD} STATES;
    STATES PS, NS;
        
 always_ff @(posedge CLK)
    begin
        if (EN == 1)
        PS <= START;
        else
        PS <= NS;
     end     
     
           
always_comb
    begin
    case (PS)
        START:
            begin
            LD = 0; //Start has all 0 outputs
            Shift = 0;
            LED = 0;
            
                begin
                NS = L1;
                end
            end  
            
        L1:
            begin
            LD = 0; // LD is 0 except for L4,L8,L12,L16
            Shift = 0; //Shift is 0 except for L3,L7,L11,L15
            LED = 1; // LED doubles every time in order tohave one LED open that walks across the board
                begin
                NS = L2;
                end
            end  
            
        L2:
            begin
            LD = 0;
            Shift = 0;
            LED = 2;
                begin
                NS = L3;
                end
            end  
          
          L3:
            begin
            LD = 0;
            Shift = 1; // Outputs the input of shift register, multiplies BCD by 1
            LED = 4;
                begin
                NS = L4;
                end
            end  
            
          L4:
            begin
            LD = 1;
            Shift = 0;
            LED = 8;
                begin
                NS = L5;
                end
            end  
            
          L5:
            begin
            LD = 0;
            Shift = 0;
            LED = 16;
                begin
                NS = L6;
                end
            end  
            
            
           L6:
            begin
            LD = 0;
            Shift = 0;
            LED = 32;
                begin
                NS = L7;
                end
            end  
            
            
           L7:
            begin
            LD = 0;
            Shift = 2; // Shifts input left by 4 0s to multiply BCD by 10
            LED = 64;
                begin
                NS = L8;
                end
            end  
            
            
           L8:
            begin
            LD = 1;
            Shift = 0;
            LED = 128;
                begin
                NS = L9;
                end
            end  
            
            
           L9:
            begin
            LD = 0;
            Shift = 0;
            LED = 256;
                begin
                NS = L10;
                end
            end  
            
            
           L10:
            begin
            LD = 0;
            Shift = 0;
            LED = 512;
                begin
                NS = L11;
                end
            end  
            
            
           L11:
            begin
            LD = 0;
            Shift = 3; // Shifts input left by 8 0s to multiply BCD by 100
            LED = 1024;
                begin
                NS = L12;
                end
            end  
            
           L12:
            begin
            LD = 1;
            Shift = 0;
            LED = 2048;
                begin
                NS = L13;
                end
            end  
            
            
           L13:
            begin
            LD = 0;
            Shift = 0;
            LED = 4096;
                begin
                NS = L14;
                end
            end  
            
            
            
           L14:
            begin
            LD = 0;
            Shift = 0;
            LED = 8192;
                begin
                NS = L15;
                end
            end  
            
            
           L15:
            begin
            LD = 0;
            Shift = 4; // Shifts input left by 12 0s to multiply BCD by 1000
            LED = 16384;
                begin
                NS = L16;
                end
            end  
            
            
           L16:
            begin
            LD = 1;
            Shift = 0;
            LED = 32768;
                begin
                NS = HOLD;
                end
            end  
         
          HOLD:
            begin
            LD = 0; // All set to 0 to hold the final value to display
            Shift = 0;
            LED = 0;
          end 
          
        
        default:
            NS = HOLD;
                      
endcase
end 
endmodule
