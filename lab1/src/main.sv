`timescale 1ns / 1ps

module main(
    output logic [3:0] leds = 4'b1111
    );  
    
    `define counterSize 27
    `define counterTolerance 30000000 //iterations will be roughly 2^counterSize - counterTolerance
    `define maxCounter (64'd1 << `counterSize) - 1
    
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
    
    always_comb begin
        if(oscClock) begin
            leds[1] = 0;
        end
        if(counter != 0) begin
            leds[2] = 0;
        end
    end
    always_ff @(posedge oscClock) begin
//        leds[0] <= 0;
        if(counter >= (`maxCounter - `counterTolerance)) begin    //give some lee-way to not miss it
            counter <= 0;
            leds[0] <= ~leds[0];
        end else begin
            counter <= counter + 1;
        end
    end
    
endmodule
