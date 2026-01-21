`timescale 1ns / 1ps

(* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
module mux2(
    input inputA,
    input inputB,
    input sel,
    output muxOut
    );
    assign muxOut = sel ? inputA : inputB;
endmodule
