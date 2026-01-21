`timescale 1ns / 1ps


(* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
module ROStartSlice(
    input sigIn,
    input sigInDelayed,
    input enable,
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *) input sel,
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *) input bx,
    output logic sigOut,
    output sigOutDelayed
    );
    
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic selectedValueF;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic selectedValueG;
    
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic enabledValueF;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic enabledValueG;
    
        //invert inputs
    inverter FInverter(.A(sigIn), .notA(notSigIn_F));
    inverter FInverterDelayed(.A(sigInDelayed), .notA(notSigInDelayed_F));
    
    inverter GInverter(.A(sigIn), .notA(notSigIn_G));
    inverter GInverterDelayed(.A(sigInDelayed), .notA(notSigInDelayed_G));
    
    mux2 FMux(.inputA(notSigIn_F), .inputB(notSigInDelayed_F), .sel(sel), .muxOut(selectedValueF));
    mux2 GMux(.inputA(notSigIn_G), .inputB(notSigInDelayed_G), .sel(sel), .muxOut(selectedValueG));
    
    mux2 FEnable(.inputA(selectedValueF), .inputB(0), .sel(enable), .muxOut(enabledValueF));
    mux2 GEnable(.inputA(selectedValueG), .inputB(0), .sel(enable), .muxOut(enabledValueG));
    
    mux2 BxMux(.inputA(enabledValueF), .inputB(enabledValueG), .sel(bx), .muxOut(sigOut));
    
    inverter bufferOutA(.A(sigOut), .notA(sigOutInv));
    inverter bufferOutB(.A(sigOutInv), .notA(sigOutDelayed));  
                
endmodule
