module Decoder (
    input                   [31 : 0]            inst,

    output reg              [ 3 : 0]            alu_op,
    output reg              [ 3 : 0]            dmem_access,
    output reg              [31 : 0]            imm,

    output reg              [ 4 : 0]            rf_ra1,
    output reg              [ 4 : 0]            rf_ra2,
    output reg              [ 4 : 0]            rf_wa,
    output reg              [ 0 : 0]            rf_we,
    output reg              [ 1 : 0]            rf_wd_sel,

    output reg              [ 0 : 0]            alu_src0_sel,//0:pc,1:reg
    output reg              [ 0 : 0]            alu_src1_sel,//0:imm,1:reg
    output reg              [ 3 : 0]            br_type
);
always @(*) begin
    case(inst[6:0])
        7'b0110011:begin//R
            alu_op={inst[30],inst[14:12]};
            dmem_access=0;
            imm=0;
            rf_ra1=inst[19:15];
            rf_ra2=inst[24:20];
            rf_wa=inst[11:7];
            rf_we=1;
            rf_wd_sel=2'b01;
            alu_src0_sel=1;
            alu_src1_sel=1;
            br_type=4'b1000;
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
            dmem_access=0;
            rf_ra1=inst[19:15];
            rf_ra2=0;
            rf_wa=inst[11:7];
            rf_we=1;
            rf_wd_sel=2'b01;
            alu_src0_sel=1;
            alu_src1_sel=0;
            br_type=4'b1000;
        end
        7'b0110111:begin//lui
            alu_op=4'b1100;
            dmem_access=0;
            imm=inst[31:12]<<12;
            rf_ra1=0;
            rf_ra2=0;
            rf_wa=inst[11:7];
            rf_we=1;
            rf_wd_sel=2'b01;
            alu_src0_sel=1;
            alu_src1_sel=0;
            br_type=4'b1000;
        end
        7'b0010111:begin//auipc
            alu_op=4'b0000;
            dmem_access=0;
            imm=inst[31:12]<<12;
            rf_ra1=0;
            rf_ra2=0;
            rf_wa=inst[11:7];
            rf_we=1;
            rf_wd_sel=2'b01;
            alu_src0_sel=0;
            alu_src1_sel=0;
            br_type=4'b1000;
        end
        7'b1101111:begin//jal
            alu_op=4'b0000;
            dmem_access=0;
            imm={{12{inst[31]}},inst[19:12],inst[20],inst[30:21],1'b0};
            rf_ra1=0;
            rf_ra2=0;
            rf_wa=inst[11:7];
            rf_we=1;
            rf_wd_sel=2'b00;
            alu_src0_sel=0;
            alu_src1_sel=0;
            br_type=4'b0010;
        end
        7'b1100111:begin//jalr
            alu_op=4'b0000;
            dmem_access=0;
            imm={{20{inst[31]}},inst[31:20]};
            rf_ra1=inst[19:15];
            rf_ra2=0;
            rf_wa=inst[11:7];
            rf_we=1;
            rf_wd_sel=2'b00;
            alu_src0_sel=1;
            alu_src1_sel=0;
            br_type=4'b0011;
        end
        7'b1100011:begin//B
            alu_op=4'b0000;
            dmem_access=0;
            imm={{20{inst[31]}},inst[7],inst[30:25],inst[11:8],1'b0};
            rf_ra1=inst[19:15];
            rf_ra2=inst[24:20];
            rf_wa=0;
            rf_we=0;
            rf_wd_sel=0;
            alu_src0_sel=0;
            alu_src1_sel=0;
            br_type={1'b0,inst[14:12]};
        end
        7'b0000011:begin//load
            alu_op=4'b0000;
            dmem_access={1'b0,inst[14:12]};
            imm={{20{inst[31]}},inst[31:20]};
            rf_ra1=inst[19:15];
            rf_ra2=0;
            rf_wa=inst[11:7];
            rf_we=1;
            rf_wd_sel=2'b10;
            alu_src0_sel=1;
            alu_src1_sel=0;
            br_type=4'b1000;
        end
        7'b0100011:begin//save
            alu_op=4'b0000;
            dmem_access={1'b1,inst[14:12]};
            imm={{20{inst[31]}},inst[31:25],inst[11:7]};
            rf_ra1=inst[19:15];
            rf_ra2=inst[24:20];
            rf_wa=0;
            rf_we=0;
            rf_wd_sel=0;
            alu_src0_sel=1;
            alu_src1_sel=0;
            br_type=4'b1000;
        end
    endcase
end
endmodule