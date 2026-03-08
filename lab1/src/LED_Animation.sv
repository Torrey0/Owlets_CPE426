`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/07/2026 04:19:26 PM
// Design Name: 
// Module Name: LED_Animation
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


module LED_Animation(
    input CLK,
    input START,
    input DEAL,
    input HIT,
    input [3:0] RND,
    output logic [14:0] LEDS
    );
    
    logic direction; //0 is left, 1 is right
    logic [3:0] prev;
    
    always_ff @ (posedge CLK) begin
    if(START || (RND != prev)) begin
        LEDS <= 15'h0000;
    end else begin
            if(RND < 5) begin
                if(LEDS == 15'h0000) begin
                    LEDS <= 15'h0001;
                    direction <= 0;
                end else begin
                    if(LEDS == 15'h4000 && direction == 0) begin
                        direction <= 1;
                    end else if((LEDS == 15'h0001 || LEDS == 15'h7FFF) && direction == 1) begin
                        LEDS <= 15'h7FFF;
                    end else if(direction) begin
                        LEDS <= LEDS>>1;
                    end else if(direction == 0) begin
                        LEDS <= LEDS<<1;
                    end
                end
            end else begin
                if(LEDS == 15'h0000) begin
                    LEDS <= 15'h4000;
                    direction <= 1;
                end else begin
                    if(LEDS == 15'h0001 && direction == 1) begin
                        direction <= 0;
                    end else if((LEDS == 15'h4000 || LEDS == 15'h7FFF) && direction == 0) begin
                        LEDS <= 15'h7FFF;
                    end else if(direction) begin
                        LEDS <= LEDS>>1;
                    end else if(direction == 0) begin
                        LEDS <= LEDS<<1;
                    end
                end
            end
        end
        prev <= RND;
    end
endmodule
