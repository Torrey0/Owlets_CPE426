`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly
// Engineer: Jack Karpinski
// 
// Create Date: 03/14/2024 09:29:53 PM
// Design Name: 
// Module Name: LFSR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Based on LFSR random generator by SimpleFPGA blog but translated into systemverilog and heavily modified by Jack Karpinski
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module LFSR(
    input CLK,
    input RST,
    output logic [3:0] RND,
    inout logic RDY
    );
    
    //making the cards
    logic [3:0] cardlist [51:0];
    logic startdeck [63:0];
    logic indeck [63:0];
    genvar i;
    generate 
    for(i=0; i < 64; i++) begin
        if(i<52) begin
            assign cardlist[i] = 4'(i%13);
            assign startdeck[i] = 1; //all cards in deck
        end
        else begin
            assign startdeck[i] = 0; //extra space
        end
    end
    assign indeck = startdeck;
    endgenerate 
    
    logic [7:0] random = 8'hff; // sets random originally to all 1s
    logic [2:0] count = 0; // measures when it has run through all operations
    assign feedback = random[7] ^ random[5] ^ random[4] ^ random[3]; // creates a feedback that xors parts of the random outputs in order to generate pseudorandom numbers
    
    always_ff @(posedge CLK, RST)
    begin
    if(RST)begin
        indeck <= startdeck;
    end
    if ((count == 6) & ~RDY) // if count reaches 6  
        begin
        count <= 0;
        if(indeck[{random[7:4],random[0],random[3:2]}] == 1) // check if card is in deck
            begin
            indeck[{random[7:4],random[0],random[3:2]}] <= 0;
            RND <= cardlist[{random[7:4],random[0],random[3:2]}]; // set output to random card
            RDY <= 1;
            end
        end
    else 
        begin  
        count <= count + 1; // otherwise increment count
        random <= {random[6:0],feedback}; //and change random
        RND <= RND;
        end
    end
    
endmodule