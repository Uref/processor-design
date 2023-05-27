module mainDecoder (
  input [6:0] i_opcode,
  input [2:0] i_funct3,

  output o_memReq, o_memWrite,
  output o_regWrite,
  output o_ALUSrc,
  output [2:0] o_immSrc,
  output o_immPlusSrc,
  output o_isLoadSigned,
  output [1:0] o_resultSrc,
  output o_ecall,

  output o_branch, o_jal, o_jalr,
  output [1:0] o_ALUOp
);

  assign o_isLoadSigned = i_funct3[2];
  assign o_immPlusSrc = ~i_opcode[5];
  assign {o_ALUOp, o_ALUSrc, o_immSrc, o_resultSrc,
          o_regWrite, o_memReq, o_memWrite,
          o_branch, o_jal, o_jalr, o_ecall}
          = mainDecoder(i_opcode, i_funct3);
  
  function [14:0] mainDecoder(
    input [6:0] i_opcode,
    input [2:0] i_funct3
  );
  
    casex (i_opcode)
  //                    AOp2_ASrc_imSrc3_resSrc2_rgW_mRq_mW_br_jal_jalr_ecall
      8'b0000011:     mainDecoder = 15'b00_1_000_01_1_1_0_0_0_0_0;  // I (load+) type
      // 8'b0001111:                                             // I (fence+) type
      8'b0010011:                                                   // I (R+i) type
        case (i_funct3[1:0])
          2'b01:      mainDecoder = 15'b10_1_010_00_1_0_0_0_0_0_0;  // I (shift+i) type
          default:    mainDecoder = 15'b10_1_001_00_1_0_0_0_0_0_0;  // I (R+i, other) type
        endcase
      8'b0100011:     mainDecoder = 15'b00_1_011_00_0_1_1_0_0_0_0;  // S type
      8'b0110011:     mainDecoder = 15'b10_0_000_00_1_0_0_0_0_0_0;  // R type
      8'b0?10111:     mainDecoder = 15'b00_0_100_10_1_0_0_0_0_0_0;  // U type
      8'b1100011:     mainDecoder = 15'b01_0_101_00_0_0_0_1_0_0_0;  // B type
      8'b1100111:     mainDecoder = 15'b00_0_110_11_1_0_0_0_0_1_0;  // I (jalr) type
      8'b1101111:     mainDecoder = 15'b00_0_111_11_1_0_0_0_1_0_0;  // J type
      8'b1110011:                                                   // I (e~, csr~) type
        case (i_funct3)
          3'b000:     mainDecoder = 15'b00_0_000_00_0_0_0_0_0_0_1;  // I (ecall, ebreak)
          default:    mainDecoder = 15'b00_0_000_00_0_0_0_0_0_0_0;  // I (csr+)
        endcase
      8'b0000000:     mainDecoder = 15'b00_0_000_00_0_0_0_0_0_0_0;  // reset etc. 
      default:        mainDecoder = 15'bxx_x_xxx_xx_x_x_x_x_x_x_x;  // I(fence+, e~, csr~) , ??? 
    endcase
  endfunction
endmodule