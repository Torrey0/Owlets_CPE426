`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2026 10:22:07 AM
// Design Name: 
// Module Name: DebOneShot
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


module DebOneShot(
    input IN,
    input CLK,
    output logic OUT = 0
    );
    logic IN_P = 0, waiting = 0;
    logic [7:0] wait_cnt = 0;
    logic [4:0] on_cnt = 0;
    
    always_ff @(posedge CLK) begin 
        IN_P <= IN;
        if(~IN_P & IN) begin // posedge IN
            waiting <= 1;
        end
        
        if(waiting)begin  // debounce
            if(wait_cnt == 50) begin  
                OUT <= 1;
                waiting <= 0;
                wait_cnt <= 0;
            end else begin
                wait_cnt <= wait_cnt + 1;
            end
        end
        
        if(OUT) begin
            if(on_cnt == 4'hF) begin
                OUT <= 0;
                on_cnt <= 0;
            end else begin
                on_cnt <= on_cnt + 1;
            end
            
        end
    end
    
endmodule
