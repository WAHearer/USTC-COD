module SegReg (
    input      [ 0:0] clk,
    input      [ 0:0] rst,
    input      [ 0:0] en,
    input      [ 0:0] stall,
    input      [ 0:0] flush,
    input      [ 0:0] commit_in,
    input      [31:0] inst_in,
    input      [31:0] pc_in,
    input      [31:0] pc_add4_in,
    input      [ 3:0] alu_op_in,
    input      [ 3:0] dmem_access_in,
    input      [31:0] imm_in,
    input      [ 4:0] rf_ra1_in,
    input      [ 4:0] rf_ra2_in,
    input      [31:0] rf_wa_in,
    input      [ 0:0] rf_we_in,
    input      [ 1:0] rf_wd_sel_in,
    input      [ 0:0] alu_src0_sel_in,
    input      [ 0:0] alu_src1_sel_in,
    input      [ 3:0] br_type_in,
    input      [31:0] rf_rd1_in,
    input      [31:0] rf_rd2_in,
    input      [31:0] alu_res_in,
    input      [31:0] rd_out_in,
    input      [31:0] wd_out_in,

    output reg [ 0:0] commit_out,
    output reg [31:0] inst_out,
    output reg [31:0] pc_out,
    output reg [31:0] pc_add4_out,
    output reg [ 3:0] alu_op_out,
    output reg [ 3:0] dmem_access_out,
    output reg [31:0] imm_out,
    output reg [ 4:0] rf_ra1_out,
    output reg [ 4:0] rf_ra2_out,
    output reg [31:0] rf_wa_out,
    output reg [ 0:0] rf_we_out,
    output reg [ 1:0] rf_wd_sel_out,
    output reg [ 0:0] alu_src0_sel_out,
    output reg [ 0:0] alu_src1_sel_out,
    output reg [ 3:0] br_type_out,
    output reg [31:0] rf_rd1_out,
    output reg [31:0] rf_rd2_out,
    output reg [31:0] alu_res_out,
    output reg [31:0] rd_out_out,
    output reg [31:0] wd_out_out
);
initial begin
    commit_out=0;
    inst_out=32'h00000013;//nop
    pc_out=0;
    pc_add4_out=0;
    alu_op_out=0;
    dmem_access_out=0;
    imm_out=0;
    rf_ra1_out=0;
    rf_ra2_out=0;
    rf_wa_out=0;
    rf_we_out=0;
    rf_wd_sel_out=0;
    alu_src0_sel_out=0;
    alu_src1_sel_out=0;
    br_type_out=4'b1000;
    rf_rd1_out=0;
    rf_rd2_out=0;
    alu_res_out=0;
    rd_out_out=0;
    wd_out_out=0;
end
always @(posedge clk) begin
    if(rst) begin
        commit_out<=0;
        inst_out<=32'h00000013;//nop
        alu_op_out<=0;
        dmem_access_out<=0;
        imm_out<=0;
        rf_ra1_out<=0;
        rf_ra2_out<=0;
        rf_wa_out<=0;
        rf_we_out<=0;
        rf_wd_sel_out<=0;
        alu_src0_sel_out<=0;
        alu_src1_sel_out<=0;
        br_type_out<=4'b1000;
        rf_rd1_out<=0;
        rf_rd2_out<=0;
        alu_res_out<=0;
        rd_out_out<=0;
        wd_out_out<=0;
    end
    else if(en) begin
        if(flush) begin
            commit_out<=0;
            inst_out<=32'h00000013;//nop
            alu_op_out<=0;
            dmem_access_out<=0;
            imm_out<=0;
            rf_ra1_out<=0;
            rf_ra2_out<=0;
            rf_wa_out<=0;
            rf_we_out<=0;
            rf_wd_sel_out<=0;
            alu_src0_sel_out<=0;
            alu_src1_sel_out<=0;
            br_type_out<=4'b1000;
            rf_rd1_out<=0;
            rf_rd2_out<=0;
            alu_res_out<=0;
            rd_out_out<=0;
            wd_out_out<=0;
        end
        else if(~stall) begin
            commit_out<=commit_in;
            inst_out<=inst_in;
            pc_out<=pc_in;
            pc_add4_out<=pc_add4_in;
            alu_op_out<=alu_op_in;
            dmem_access_out<=dmem_access_in;
            imm_out<=imm_in;
            rf_ra1_out<=rf_ra1_in;
            rf_ra2_out<=rf_ra2_in;
            rf_wa_out<=rf_wa_in;
            rf_we_out<=rf_we_in;
            rf_wd_sel_out<=rf_wd_sel_in;
            alu_src0_sel_out<=alu_src0_sel_in;
            alu_src1_sel_out<=alu_src1_sel_in;
            br_type_out<=br_type_in;
            rf_rd1_out<=rf_rd1_in;
            rf_rd2_out<=rf_rd2_in;
            alu_res_out<=alu_res_in;
            rd_out_out<=rd_out_in;
            wd_out_out<=wd_out_in;
        end
    end
end
endmodule