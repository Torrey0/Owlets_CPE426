`timescale 1ns / 1ps

module DebOneShot(
    input IN,
    input RST,
    input CLK,
    output logic OUT
    );
    
    // 1,000,000 CC at 100MHz = 10 milliseconds
    logic [19:0] wait_cnt = 0; 
    
    always_ff @(posedge CLK) begin 
        if(RST) begin
            OUT <= 0;
            wait_cnt <= 0;
        end else begin
            if (IN == OUT) begin
                // input isnt changing, no counting
                wait_cnt <= 0;
            end else begin
                // when input changes ensure it stays changed for the full 10ms
                wait_cnt <= wait_cnt + 1;
                
                // If the input remains solidly changed for 10ms without bouncing...
                if (wait_cnt >= 20'd1000000) begin
                    OUT <= IN;      // Accept the new state
                    wait_cnt <= 0;  // Reset the timer
                end
            end
        end
    end
    
endmodule