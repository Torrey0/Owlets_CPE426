`timescale 1ns / 1ps

(* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
module inverter(
    input A,
    output notA
    );
    assign notA = ~A;
endmodule
