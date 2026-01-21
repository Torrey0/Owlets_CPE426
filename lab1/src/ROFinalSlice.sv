`timescale 1ns / 1ps


(* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
module ROFinalSlice(
    input sigIn,
    input sigInDelayed,
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
    logic sigOutInv;
    
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic sigInInvF;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic sigInBufferedF;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic sigInDelayedInvF;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic sigInDelayedBufferedF;
    
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic sigInInvG;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic sigInBufferedG;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic sigInDelayedInvG;
    (* keep = "true", s = "true", dont_touch = "true", allow_opt_tiling = "false" *)
    logic sigInDelayedBufferedG;
     
    inverter bufferInF1(.A(sigIn), .notA(sigInInvF));
    inverter bufferInF2(.A(sigInInvF), .notA(sigInBufferedF));   
    
    inverter bufferInFDelayed1(.A(sigInDelayed), .notA(sigInDelayedInvF));
    inverter bufferInFDelayed2(.A(sigInDelayedInvF), .notA(sigInDelayedBufferedF));  
    
    inverter bufferInG1(.A(sigIn), .notA(sigInInvG));
    inverter bufferInFG(.A(sigInInvG), .notA(sigInBufferedG));   
    
    inverter bufferInGDelayed1(.A(sigInDelayed), .notA(sigInDelayedInvG));
    inverter bufferInGDelayed2(.A(sigInDelayedInvG), .notA(sigInDelayedBufferedG)); 
    
    mux2 FMux(.inputA(sigInBufferedF), .inputB(sigInDelayedBufferedF), .sel(sel), .muxOut(selectedValueF));
    mux2 GMux(.inputA(sigInBufferedG), .inputB(sigInDelayedBufferedG), .sel(sel), .muxOut(selectedValueG));
    
    mux2 BxMux(.inputA(selectedValueF), .inputB(selectedValueG), .sel(bx), .muxOut(sigOut));
    
    inverter bufferOutA(.A(sigOut), .notA(sigOutInv));
    inverter bufferOutB(.A(sigOutInv), .notA(sigOutDelayed));   
            
endmodule
