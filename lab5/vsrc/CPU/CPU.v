/* verilator lint_off PINMISSING */
/* verilator lint_off WIDTHEXPAND */
module CPU (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            global_en,

/* ------------------------------ Memory (inst) ----------------------------- */
    output                  [31 : 0]            imem_raddr,
    input                   [31 : 0]            imem_rdata,

/* ------------------------------ Memory (data) ----------------------------- */
    input                   [31 : 0]            dmem_rdata,
    output                  [ 0 : 0]            dmem_we,
    output                  [31 : 0]            dmem_addr,
    output                  [31 : 0]            dmem_wdata,

/* ---------------------------------- Debug --------------------------------- */
    output                  [ 0 : 0]            commit,
    output                  [31 : 0]            commit_pc,
    output                  [31 : 0]            commit_instr,
    output                  [ 0 : 0]            commit_halt,
    output                  [ 0 : 0]            commit_reg_we,
    output                  [ 4 : 0]            commit_reg_wa,
    output                  [31 : 0]            commit_reg_wd,
    output                  [ 0 : 0]            commit_dmem_we,
    output                  [31 : 0]            commit_dmem_wa,
    output                  [31 : 0]            commit_dmem_wd,

    input                   [ 4 : 0]            debug_reg_ra,   // TODO
    output                  [31 : 0]            debug_reg_rd    // TODO
);

//PC
wire [31:0] pc_if;
PC pc(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .npc(npc_ex),
    .pc(pc_if)
);
wire [31:0] pc_add4_if=pc_if+4;

//IM
assign imem_raddr=pc_if;
wire [31:0] inst_if=imem_rdata;

//IF-ID
wire stall_if=0;
wire flush_if=(npc_sel_ex!=2'b00);
wire commit_id;
wire [31:0] inst_id,pc_id,pc_add4_id;
SegReg if_id(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall(stall_if),
    .flush(flush_if),
    .commit_in(1),
    .inst_in(inst_if),
    .pc_in(pc_if),
    .pc_add4_in(pc_add4_if),
    .alu_op_in(0),
    .dmem_access_in(0),
    .imm_in(0),
    .rf_ra1_in(0),
    .rf_ra2_in(0),
    .rf_wa_in(0),
    .rf_we_in(0),
    .rf_wd_sel_in(0),
    .alu_src0_sel_in(0),
    .alu_src1_sel_in(0),
    .br_type_in(0),
    .rf_rd1_in(0),
    .rf_rd2_in(0),
    .alu_res_in(0),
    .rd_out_in(0),
    .wd_out_in(0),
    .commit_out(commit_id),
    .inst_out(inst_id),
    .pc_out(pc_id),
    .pc_add4_out(pc_add4_id)
);

//Decoder
wire [3:0] alu_op_id,dmem_access_id;
wire [31:0] imm_id;
wire [4:0] rf_ra1_id,rf_ra2_id,rf_wa_id;
wire rf_we_id;
wire [1:0] rf_wd_sel_id;
wire alu_src0_sel_id,alu_src1_sel_id;
wire [3:0] br_type_id;
Decoder decoder(
    .inst(inst_id),
    .alu_op(alu_op_id),
    .dmem_access(dmem_access_id),
    .imm(imm_id),
    .rf_ra1(rf_ra1_id),
    .rf_ra2(rf_ra2_id),
    .rf_wa(rf_wa_id),
    .rf_we(rf_we_id),
    .rf_wd_sel(rf_wd_sel_id),
    .alu_src0_sel(alu_src0_sel_id),
    .alu_src1_sel(alu_src1_sel_id),
    .br_type(br_type_id)
);

//RegFile
wire [31:0] rf_rd1_id,rf_rd2_id;
RegFile regFile(
    .clk(clk),
    .rf_ra1(rf_ra1_id),
    .rf_ra2(rf_ra2_id),
    .rf_wa(rf_wa_wb),
    .rf_we(rf_we_wb),
    .rf_wd(rf_wd_wb),
    .debug_reg_ra(debug_reg_ra),
    .rf_rd1(rf_rd1_id),
    .rf_rd2(rf_rd2_id),
    .debug_reg_rd(debug_reg_rd)
);

//ID-EX
wire stall_id=0;
wire flush_id=(npc_sel_ex!=2'b00);
wire commit_ex;
wire [31:0] inst_ex,pc_ex,pc_add4_ex;
wire [3:0] alu_op_ex,dmem_access_ex;
wire [31:0] imm_ex;
wire [4:0] rf_ra1_ex,rf_ra2_ex,rf_wa_ex;
wire rf_we_ex;
wire [1:0] rf_wd_sel_ex;
wire alu_src0_sel_ex,alu_src1_sel_ex;
wire [3:0] br_type_ex;
wire [31:0] rf_rd1_ex,rf_rd2_ex;
SegReg id_ex(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall(stall_id),
    .flush(flush_id),
    .commit_in(commit_id),
    .inst_in(inst_id),
    .pc_in(pc_id),
    .pc_add4_in(pc_add4_id),
    .alu_op_in(alu_op_id),
    .dmem_access_in(dmem_access_id),
    .imm_in(imm_id),
    .rf_ra1_in(rf_ra1_id),
    .rf_ra2_in(rf_ra2_id),
    .rf_wa_in(rf_wa_id),
    .rf_we_in(rf_we_id),
    .rf_wd_sel_in(rf_wd_sel_id),
    .alu_src0_sel_in(alu_src0_sel_id),
    .alu_src1_sel_in(alu_src1_sel_id),
    .br_type_in(br_type_id),
    .rf_rd1_in(rf_rd1_id),
    .rf_rd2_in(rf_rd2_id),
    .alu_res_in(0),
    .rd_out_in(0),
    .wd_out_in(0),
    .commit_out(commit_ex),
    .inst_out(inst_ex),
    .pc_out(pc_ex),
    .pc_add4_out(pc_add4_ex),
    .alu_op_out(alu_op_ex),
    .dmem_access_out(dmem_access_ex),
    .imm_out(imm_ex),
    .rf_ra1_out(rf_ra1_ex),
    .rf_ra2_out(rf_ra2_ex),
    .rf_wa_out(rf_wa_ex),
    .rf_we_out(rf_we_ex),
    .rf_wd_sel_out(rf_wd_sel_ex),
    .alu_src0_sel_out(alu_src0_sel_ex),
    .alu_src1_sel_out(alu_src1_sel_ex),
    .br_type_out(br_type_ex),
    .rf_rd1_out(rf_rd1_ex),
    .rf_rd2_out(rf_rd2_ex)
);

//ALUMUX
wire [31:0] alu_src0_ex,alu_src1_ex;
ALUMUX alumux0(
    .src0(pc_ex),
    .src1(rf_rd1_ex),
    .sel(alu_src0_sel_ex),
    .res(alu_src0_ex)
);
ALUMUX alumux1(
    .src0(imm_ex),
    .src1(rf_rd2_ex),
    .sel(alu_src1_sel_ex),
    .res(alu_src1_ex)
);

//ALU
wire [31:0] alu_res_ex;
ALU alu(
    .alu_src0(alu_src0_ex),
    .alu_src1(alu_src1_ex),
    .alu_op(alu_op_ex),
    .alu_res(alu_res_ex)
);

//BRANCH
wire [1:0] npc_sel_ex;
BRANCH branch(
    .br_type(br_type_ex),
    .br_src0(rf_rd1_ex),
    .br_src1(rf_rd2_ex),
    .npc_sel(npc_sel_ex)
);

//NPCMUX
wire [31:0] pc_offset_ex=alu_res_ex,pc_j_ex=alu_res_ex&32'hfffffffe;
wire [31:0] npc_ex;
NPCMUX npcmux(
    .pc_add4(pc_add4_if),
    .pc_offset(pc_offset_ex),
    .pc_j(pc_j_ex),
    .npc_sel(npc_sel_ex),
    .npc(npc_ex)
);

//EX-MEM
wire stall_ex=0;
wire flush_ex=0;
wire commit_mem;
wire [31:0] inst_mem,pc_mem,pc_add4_mem;
wire [3:0] alu_op_mem,dmem_access_mem;
wire [31:0] imm_mem;
wire [4:0] rf_ra1_mem,rf_ra2_mem,rf_wa_mem;
wire rf_we_mem;
wire [1:0] rf_wd_sel_mem;
wire alu_src0_sel_mem,alu_src1_sel_mem;
wire [3:0] br_type_mem;
wire [31:0] rf_rd1_mem,rf_rd2_mem;
wire [31:0] alu_res_mem;
SegReg ex_mem(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall(stall_ex),
    .flush(flush_ex),
    .commit_in(commit_ex),
    .inst_in(inst_ex),
    .pc_in(pc_ex),
    .pc_add4_in(pc_add4_ex),
    .alu_op_in(alu_op_ex),
    .dmem_access_in(dmem_access_ex),
    .imm_in(imm_ex),
    .rf_ra1_in(rf_ra1_ex),
    .rf_ra2_in(rf_ra2_ex),
    .rf_wa_in(rf_wa_ex),
    .rf_we_in(rf_we_ex),
    .rf_wd_sel_in(rf_wd_sel_ex),
    .alu_src0_sel_in(alu_src0_sel_ex),
    .alu_src1_sel_in(alu_src1_sel_ex),
    .br_type_in(br_type_ex),
    .rf_rd1_in(rf_rd1_ex),
    .rf_rd2_in(rf_rd2_ex),
    .alu_res_in(alu_res_ex),
    .rd_out_in(0),
    .wd_out_in(0),
    .commit_out(commit_mem),
    .inst_out(inst_mem),
    .pc_out(pc_mem),
    .pc_add4_out(pc_add4_mem),
    .alu_op_out(alu_op_mem),
    .dmem_access_out(dmem_access_mem),
    .imm_out(imm_mem),
    .rf_ra1_out(rf_ra1_mem),
    .rf_ra2_out(rf_ra2_mem),
    .rf_wa_out(rf_wa_mem),
    .rf_we_out(rf_we_mem),
    .rf_wd_sel_out(rf_wd_sel_mem),
    .alu_src0_sel_out(alu_src0_sel_mem),
    .alu_src1_sel_out(alu_src1_sel_mem),
    .br_type_out(br_type_mem),
    .rf_rd1_out(rf_rd1_mem),
    .rf_rd2_out(rf_rd2_mem),
    .alu_res_out(alu_res_mem)
);

//SLU
assign dmem_we=dmem_access_mem[3];
assign dmem_addr=alu_res_mem[31:2]<<2;
wire [31:0] rd_out_mem,wd_out_mem;
SLU slu(
    .addr(alu_res_mem[1:0]),
    .dmem_access(dmem_access_mem),
    .rd_in(dmem_rdata),
    .wd_in(rf_rd2_mem),
    .rd_out(rd_out_mem),
    .wd_out(wd_out_mem)
);
assign dmem_wdata=wd_out_mem;

//MEM-WB
wire stall_mem=0;
wire flush_mem=0;
wire commit_wb;
wire [31:0] inst_wb,pc_wb,pc_add4_wb;
wire [3:0] alu_op_wb,dmem_access_wb;
wire [31:0] imm_wb;
wire [4:0] rf_ra1_wb,rf_ra2_wb,rf_wa_wb;
wire rf_we_wb;
wire [1:0] rf_wd_sel_wb;
wire alu_src0_sel_wb,alu_src1_sel_wb;
wire [3:0] br_type_wb;
wire [31:0] rf_rd1_wb,rf_rd2_wb;
wire [31:0] alu_res_wb;
wire [31:0] rd_out_wb,wd_out_wb;
SegReg mem_wb(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .stall(stall_mem),
    .flush(flush_mem),
    .commit_in(commit_mem),
    .inst_in(inst_mem),
    .pc_in(pc_mem),
    .pc_add4_in(pc_add4_mem),
    .alu_op_in(alu_op_mem),
    .dmem_access_in(dmem_access_mem),
    .imm_in(imm_mem),
    .rf_ra1_in(rf_ra1_mem),
    .rf_ra2_in(rf_ra2_mem),
    .rf_wa_in(rf_wa_mem),
    .rf_we_in(rf_we_mem),
    .rf_wd_sel_in(rf_wd_sel_mem),
    .alu_src0_sel_in(alu_src0_sel_mem),
    .alu_src1_sel_in(alu_src1_sel_mem),
    .br_type_in(br_type_mem),
    .rf_rd1_in(rf_rd1_mem),
    .rf_rd2_in(rf_rd2_mem),
    .alu_res_in(alu_res_mem),
    .rd_out_in(rd_out_mem),
    .wd_out_in(wd_out_mem),
    .commit_out(commit_wb),
    .inst_out(inst_wb),
    .pc_out(pc_wb),
    .pc_add4_out(pc_add4_wb),
    .alu_op_out(alu_op_wb),
    .dmem_access_out(dmem_access_wb),
    .imm_out(imm_wb),
    .rf_ra1_out(rf_ra1_wb),
    .rf_ra2_out(rf_ra2_wb),
    .rf_wa_out(rf_wa_wb),
    .rf_we_out(rf_we_wb),
    .rf_wd_sel_out(rf_wd_sel_wb),
    .alu_src0_sel_out(alu_src0_sel_wb),
    .alu_src1_sel_out(alu_src1_sel_wb),
    .br_type_out(br_type_wb),
    .rf_rd1_out(rf_rd1_wb),
    .rf_rd2_out(rf_rd2_wb),
    .alu_res_out(alu_res_wb),
    .rd_out_out(rd_out_wb),
    .wd_out_out(wd_out_wb)
);

//RF_WD_MUX
wire [31:0] rf_wd_wb;
RF_WD_MUX rf_wd_mux(
    .src0(pc_add4_wb),
    .src1(alu_res_wb),
    .src2(rd_out_wb),
    .src3(0),
    .sel(rf_wd_sel_wb),
    .res(rf_wd_wb)
);

// Commit
reg  [ 0 : 0]   commit_reg          ;
reg  [31 : 0]   commit_pc_reg       ;
reg  [31 : 0]   commit_inst_reg     ;
reg  [ 0 : 0]   commit_halt_reg     ;
reg  [ 0 : 0]   commit_reg_we_reg   ;
reg  [ 4 : 0]   commit_reg_wa_reg   ;
reg  [31 : 0]   commit_reg_wd_reg   ;
reg  [ 0 : 0]   commit_dmem_we_reg  ;
reg  [31 : 0]   commit_dmem_wa_reg  ;
reg  [31 : 0]   commit_dmem_wd_reg  ;

// Commit
always @(posedge clk) begin
    if (rst) begin
        commit_reg          <= 1'B0;
        commit_pc_reg       <= 32'H0;
        commit_inst_reg     <= 32'H0;
        commit_halt_reg     <= 1'B0;
        commit_reg_we_reg   <= 1'B0;
        commit_reg_wa_reg   <= 5'H0;
        commit_reg_wd_reg   <= 32'H0;
        commit_dmem_we_reg  <= 1'B0;
        commit_dmem_wa_reg  <= 32'H0;
        commit_dmem_wd_reg  <= 32'H0;
    end
    else if (global_en) begin
        commit_reg          <= commit_wb;
        commit_pc_reg       <= pc_wb;   // TODO
        commit_inst_reg     <= inst_wb;   // TODO
        commit_halt_reg     <= inst_wb==32'H00100073;   // TODO
        commit_reg_we_reg   <= rf_we_wb;   // TODO
        commit_reg_wa_reg   <= rf_wa_wb;   // TODO
        commit_reg_wd_reg   <= rf_wd_wb;   // TODO
        commit_dmem_we_reg  <= dmem_access_wb[3];   // TODO
        commit_dmem_wa_reg  <= alu_res_wb[31:2]<<2;   // TODO
        commit_dmem_wd_reg  <= wd_out_wb;   // TODO
    end
end

assign commit           = commit_reg;
assign commit_pc        = commit_pc_reg;
assign commit_instr     = commit_inst_reg;
assign commit_halt      = commit_halt_reg;
assign commit_reg_we    = commit_halt?0:commit_reg_we_reg;
assign commit_reg_wa    = commit_reg_wa_reg;
assign commit_reg_wd    = commit_reg_wd_reg;
assign commit_dmem_we   = commit_dmem_we_reg;
assign commit_dmem_wa   = commit_dmem_wa_reg;
assign commit_dmem_wd   = commit_dmem_wd_reg;

endmodule