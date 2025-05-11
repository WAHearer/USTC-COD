/* verilator lint_off WIDTHEXPAND */
module ALU (
    input                   [31 : 0]            alu_src0,
    input                   [31 : 0]            alu_src1,
    input                   [ 3 : 0]            alu_op,

    output      reg         [31 : 0]            alu_res
);
integer i;
`define ADD                 4'B0000    
`define SUB                 4'B1000   
`define SLT                 4'B0010
`define SLTU                4'B0011
`define AND                 4'B0111
`define OR                  4'B0110
`define XOR                 4'B0100
`define SLL                 4'B0001   
`define SRL                 4'B0101    
`define SRA                 4'B1101  
`define SRC0                4'B1110
`define SRC1                4'B1100
    always @(*) begin
        case(alu_op)
            `ADD:alu_res=alu_src0+alu_src1;
            `SUB:alu_res=alu_src0-alu_src1;
            `SLT:alu_res=(alu_src0[31]==1&&alu_src1[31]==0)||(alu_src0[31]==alu_src1[31]&&alu_src0<alu_src1);
            `SLTU:alu_res=(alu_src0<alu_src1);
            `AND:alu_res=alu_src0&alu_src1;
            `OR:alu_res=alu_src0|alu_src1;
            `XOR:alu_res=alu_src0^alu_src1;
            `SLL:alu_res=alu_src0<<alu_src1[4:0];
            `SRL:alu_res=alu_src0>>alu_src1[4:0];
            `SRA:
                for(i=0;i<32;i=i+1) begin
                    if(i+alu_src1[4:0]<32)
                        alu_res[i]=alu_src0[i+alu_src1[4:0]];
                    else
                        alu_res[i]=alu_src0[31];
                end
            `SRC0:alu_res=alu_src0;
            `SRC1:alu_res=alu_src1;
            default:alu_res=32'H0;
        endcase
    end
endmodule