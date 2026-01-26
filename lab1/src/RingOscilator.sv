`timescale 1ns / 1ps

(* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
module RingOscilator#(
    parameter OscSize = 4
)(
//    input CLK, 
    input enable,
    input sel [OscSize-1:0],
    input bx [OscSize-1:0],
    output logic generatedClock
);
    
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *) logic [OscSize-1:0] osc;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *) logic [OscSize-1:0] oscDelayed;
    
    ROStartSlice ROSS(.sigIn(osc[0]), .sigInDelayed(oscDelayed[0]), .enable(enable), .sel(sel[0]), .bx(bx[0]), .sigOut(osc[1]), .sigOutDelayed(oscDelayed[1]));

    genvar i;
    generate
        for(i=1; i < OscSize-1; i++) begin: loop
            ROMiddleSlice slice (.sigIn(osc[i]), .sigInDelayed(oscDelayed[i]), .sel(sel[i]), .bx(bx[i]), .sigOut(osc[i+1]), .sigOutDelayed(oscDelayed[i+1]));
        end        
    endgenerate
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    ROFinalSlice ROFS (.sigIn(osc[OscSize-1]), .sigInDelayed(oscDelayed[OscSize-1]), .sel(sel[OscSize-1]), .bx(bx[OscSize-1]), .sigOut(osc[0]), .sigOutDelayed(oscDelayed[0]));

    assign generatedClock =  osc[OscSize-1];
endmodule
