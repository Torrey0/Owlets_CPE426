`timescale 1ns / 1ps


(* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
module ROMiddleSlice(
    input sigIn,
    input sigInDelayed,
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *) input sel,
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *) input bx,
    output logic sigOut,
    output sigOutDelayed
    );
    
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic notSigIn_F;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic notSigInDelayed_F;
    
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic notSigIn_G;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic notSigInDelayed_G;
    
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic selectedValueF;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic selectedValueG;
        
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    
    //invert inputs
    inverter FInverter(.A(sigIn), .notA(notSigIn_F));
    inverter FInverterDelayed(.A(sigInDelayed), .notA(notSigInDelayed_F));
    
    inverter GInverter(.A(sigIn), .notA(notSigIn_G));
    inverter GInverterDelayed(.A(sigInDelayed), .notA(notSigInDelayed_G));
    
    mux2 FMux(.inputA(notSigIn_F), .inputB(notSigInDelayed_F), .sel(sel), .muxOut(selectedValueF));
    mux2 GMux(.inputA(notSigIn_G), .inputB(notSigInDelayed_G), .sel(sel), .muxOut(selectedValueG));
    
    mux2 BxMux(.inputA(selectedValueF), .inputB(selectedValueG), .sel(bx), .muxOut(sigOut));
    
    inverter bufferOutA(.A(sigOut), .notA(sigOutInv));
    inverter bufferOutB(.A(sigOutInv), .notA(sigOutDelayed));  
      
            
endmodule
