`define HIGH   1'b1
`define LOW    1'b0

module hazard (
  // input clk, reset_x,
  // from datapath
  input [4:0] Di_rs1, Di_rs2,
  input [4:0] Ei_rs1, Ei_rs2,
  input [4:0] Ei_rd,
  input [4:0] Mi_rd,
  input [4:0] Wi_rd,
  // from controller
  input       Di_jal,
  input [1:0] Ei_prePCSrc,
  input [1:0] Ei_resultSrc,
  input [1:0] Mi_resultSrc,
  input Mi_regWrite,
  input Wi_regWrite,

  // to datapath
  output [1:0] Eo_forwardIn1Src, Eo_forwardIn2Src,
  // to both (datapath, controller)
  output Fo_stall,
  output Do_stall,
  output Do_flush,
  output Eo_flush
);
  wire w_lwStall;
  wire w_takeBranchOrJalrOrEcall;


  assign Eo_forwardIn1Src = forwarding(
                              Ei_rs1,
                              Ei_rd, Mi_rd, Wi_rd,
                              Ei_resultSrc, Mi_resultSrc,
                              Mi_regWrite, Wi_regWrite
                            ); 
  assign Eo_forwardIn2Src = forwarding(
                              Ei_rs2,
                              Ei_rd, Mi_rd, Wi_rd,
                              Ei_resultSrc, Mi_resultSrc,
                              Mi_regWrite, Wi_regWrite
                            ); 

  assign w_lwStall = (Ei_resultSrc == 2'b01) // isLoad?
                    & ((Di_rs1 == Ei_rd)
                      | (Di_rs2 == Ei_rd));

  assign w_takeBranchOrJalrOrEcall = (Ei_prePCSrc != 2'b00);  // (takeBranch or jalr or ecall)

  assign  Fo_stall = w_lwStall;                    
  assign  Do_stall = w_lwStall;                    
  assign  Do_flush = w_takeBranchOrJalrOrEcall | Di_jal;
  assign  Eo_flush = w_takeBranchOrJalrOrEcall | w_lwStall;


  function [3:0] forwarding(
    input [4:0] Ei_rs,
    input [4:0] Ei_rd, Mi_rd, Wi_rd,
    // from controller
    input [1:0] Ei_resultSrc, Mi_resultSrc,
    input Mi_regWrite, Wi_regWrite
  );
    if (Ei_rs != 5'b0)
      if (Ei_rs == Mi_rd)
        if (Mi_regWrite)
          if (Mi_resultSrc == 2'b00)
                        forwarding = 2'b11;  // Mo_ALUOut
          else if (Mi_resultSrc == 2'b10)       
                        forwarding = 2'b10;  // Mw_immPlus
          else          forwarding = 2'b00;  // Ew_RD1
        else            forwarding = 2'b00;  // Ew_RD1
          
      else if ((Ei_rs == Wi_rd) & Wi_regWrite) 
                        forwarding = 2'b01;  // Ww_result
      else              forwarding = 2'b00;  // Ew_RD1
    else                forwarding = 2'b00;  // Ew_RD1
  endfunction
endmodule