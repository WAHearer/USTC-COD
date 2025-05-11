module Decoder (
    input                   [31 : 0]            inst,

    output reg              [ 3 : 0]            alu_op,
    output reg              [31 : 0]            imm,

    output reg              [ 4 : 0]            rf_ra0,
    output reg              [ 4 : 0]            rf_ra1,
    output reg              [ 4 : 0]            rf_wa,
    output reg              [ 0 : 0]            rf_we,

    output reg              [ 0 : 0]            alu_src0_sel,//0:pc,1:reg
    output reg              [ 0 : 0]            alu_src1_sel //0:imm,1:reg
);
always @(*) begin
    case(inst[6:0])
        7'b0110011:begin//R
            alu_op={inst[30],inst[14:12]};
            imm=0;
            rf_ra0=inst[19:15];
            rf_ra1=inst[24:20];
            rf_wa=inst[11:7];
            rf_we=1;
            alu_src0_sel=1;
            alu_src1_sel=1;
        end
        7'b0010011:begin//I
            case(inst[14:12])
                3'b001,3'b101:begin//slli,srli,srai
                    alu_op={inst[30],inst[14:12]};
                    imm={27'b0,inst[24:20]};//shamt[5]必须为0
                end
                default:begin
                    alu_op={1'b0,inst[14:12]};
                    imm={{20{inst[31]}},inst[31:20]};
                end
            endcase
            rf_ra0=inst[19:15];
            rf_ra1=0;
            rf_wa=inst[11:7];
            rf_we=1;
            alu_src0_sel=1;
            alu_src1_sel=0;
        end
        7'b0110111:begin//lui
            alu_op=4'b1100;//SRC1
            imm=inst[31:12]<<12;
            rf_ra0=0;
            rf_ra1=0;
            rf_wa=inst[11:7];
            rf_we=1;
            alu_src0_sel=1;
            alu_src1_sel=0;
        end
        7'b0010111:begin//auipc
            alu_op=4'b0000;//ADD
            imm=inst[31:12]<<12;
            rf_ra0=0;
            rf_ra1=0;
            rf_wa=inst[11:7];
            rf_we=1;
            alu_src0_sel=0;
            alu_src1_sel=0;
        end
    endcase
end
endmodule