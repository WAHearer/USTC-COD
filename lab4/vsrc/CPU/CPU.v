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
    output                  [31 : 0]            commit_inst,
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

wire [3:0] br_type;
wire [31:0] cur_pc,cur_npc,pc_add4,pc_offset,pc_j;
wire [1:0] npc_sel;
wire [31:0] inst;
wire [1:0] rf_wd_sel;
wire rf_we;
wire [4:0] rf_ra1,rf_ra2,rf_wa;
wire [31:0] rf_wd,rf_rd1,rf_rd2;
wire alu_src0_sel,alu_src1_sel;
wire [31:0] imm;
wire [3:0] alu_op;
wire [31:0] alu_src0,alu_src1,alu_res;
wire [3:0] dmem_access;
wire [31:0] rd_out;

assign imem_raddr=cur_pc-32'h00400000;
assign inst=imem_rdata;
Decoder decoder(
    .inst(inst),
    .alu_op(alu_op),
    .dmem_access(dmem_access),
    .imm(imm),
    .rf_ra1(rf_ra1),
    .rf_ra2(rf_ra2),
    .rf_wa(rf_wa),
    .rf_we(rf_we),
    .rf_wd_sel(rf_wd_sel),
    .alu_src0_sel(alu_src0_sel),
    .alu_src1_sel(alu_src1_sel),
    .br_type(br_type)
);

MUX mux1(
    .src0(cur_pc),
    .src1(rf_rd1),
    .sel(alu_src0_sel),
    .res(alu_src0)
);
MUX mux2(
    .src0(imm),
    .src1(rf_rd2),
    .sel(alu_src1_sel),
    .res(alu_src1)
);

ALU alu(
    .alu_src0(alu_src0),
    .alu_src1(alu_src1),
    .alu_op(alu_op),
    .alu_res(alu_res)
);

RF_WD_MUX rf_wd_mux(
    .src0(pc_add4),
    .src1(alu_res),
    .src2(rd_out),
    .src3(0),
    .sel(rf_wd_sel),
    .res(rf_wd)
);

RegFile regFile(
    .clk(clk),
    .rf_ra1(rf_ra1),
    .rf_ra2(rf_ra2),
    .rf_wa(rf_wa),
    .rf_we(rf_we),
    .rf_wd(rf_wd),
    .debug_reg_ra(debug_reg_ra),
    .rf_rd1(rf_rd1),
    .rf_rd2(rf_rd2),
    .debug_reg_rd(debug_reg_rd)
);

BRANCH branch(
    .br_type(br_type),
    .br_src0(rf_rd1),
    .br_src1(rf_rd2),
    .npc_sel(npc_sel)
);

assign pc_add4=cur_pc+4;
assign pc_offset=alu_res;
assign pc_j=alu_res&32'hfffffffe;
NPCMUX npcmux(
    .pc_add4(pc_add4),
    .pc_offset(pc_offset),
    .pc_j(pc_j),
    .npc_sel(npc_sel),
    .npc(cur_npc)
);
PC pc(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .npc(cur_npc),
    .pc(cur_pc)
);

assign dmem_we=dmem_access[3];
assign dmem_addr=alu_res-alu_res%4;
SLU slu(
    .addr(alu_res%4),
    .dmem_access(dmem_access),
    .rd_in(dmem_rdata),
    .wd_in(rf_rd2),
    .rd_out(rd_out),
    .wd_out(dmem_wdata)
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
        commit_reg          <= 1'B1;
        commit_pc_reg       <= cur_pc;   // TODO
        commit_inst_reg     <= imem_rdata;   // TODO
        commit_halt_reg     <= imem_rdata==32'H00100073;   // TODO
        commit_reg_we_reg   <= rf_we;   // TODO
        commit_reg_wa_reg   <= rf_wa;   // TODO
        commit_reg_wd_reg   <= rf_wd;   // TODO
        commit_dmem_we_reg  <= dmem_we;   // TODO
        commit_dmem_wa_reg  <= dmem_addr;   // TODO
        commit_dmem_wd_reg  <= dmem_wdata;   // TODO
    end
end

assign commit           = commit_reg;
assign commit_pc        = commit_pc_reg;
assign commit_inst      = commit_inst_reg;
assign commit_halt      = commit_halt_reg;
assign commit_reg_we    = commit_reg_we_reg;
assign commit_reg_wa    = commit_reg_wa_reg;
assign commit_reg_wd    = commit_reg_wd_reg;
assign commit_dmem_we   = commit_dmem_we_reg;
assign commit_dmem_wa   = commit_dmem_wa_reg;
assign commit_dmem_wd   = commit_dmem_wd_reg;

endmodule