`timescale 1ns / 1ps

module blinkLED#(
    parameter LEDIntervalMS = 1000
)(
    output logic [0:0] leds = 1'b1
    );  
    `define loopsPerMs 180000    //observed to be roughly accurate with RO Size = 4

    
    `define targetLoops (`loopsPerMs * LEDIntervalMS)
    
    `define counterSize ($clog2(`targetLoops + 100) + 1)    //ensure at least 100 value lee-way      
    
    logic [`counterSize - 1:0] counter = 0;
    logic oscEnable;
    logic oscClock;
    logic prevOscClock;
    
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic oscSEL [3:0];
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic oscBx [3:0];

    initial begin 
        oscEnable = 1;
        oscSEL = '{1'b1, 1'b0, 1'b1, 1'b0}; 
        oscBx = '{1'b0, 1'b1, 1'b1, 1'b1};
    end

    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    RingOscilator RO(.enable(oscEnable), .sel(oscSEL), .bx(oscBx), .generatedClock(oscClock));
    
    always_ff @(posedge oscClock) begin
        if(counter >= `targetLoops) begin    
            counter <= 0;
            leds[0] <= ~leds[0];
        end else begin
            counter <= counter + 1;
        end
    end
    
endmodule
