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

wire [31:0] cur_pc,cur_npc;
wire [31:0] inst;
assign cur_npc=cur_pc+4;
wire rf_we;
wire [4:0] rf_ra0,rf_ra1,rf_wa;
wire [31:0] rf_wd,rf_rd0,rf_rd1;
wire alu_src0_sel,alu_src1_sel;
wire [31:0] imm;
wire [3:0] alu_op;
wire [31:0] alu_src0,alu_src1,alu_res;
PC pc(
    .clk(clk),
    .rst(rst),
    .en(global_en),
    .npc(cur_npc),
    .pc(cur_pc)
);

assign inst=imem_rdata;

Decoder decoder(
    .inst(inst),
    .alu_op(alu_op),
    .imm(imm),
    .rf_ra0(rf_ra0),
    .rf_ra1(rf_ra1),
    .rf_wa(rf_wa),
    .rf_we(rf_we),
    .alu_src0_sel(alu_src0_sel),
    .alu_src1_sel(alu_src1_sel)
);

assign rf_wd=alu_res;

RegFile regFile(
    .clk(clk),
    .rf_ra0(rf_ra0),
    .rf_ra1(rf_ra1),
    .rf_wa(rf_wa),
    .rf_we(rf_we),
    .rf_wd(rf_wd),
    .debug_reg_ra(debug_reg_ra),
    .rf_rd0(rf_rd0),
    .rf_rd1(rf_rd1),
    .debug_reg_rd(debug_reg_rd)
);

MUX mux1(
    .src0(cur_pc),
    .src1(rf_rd0),
    .sel(alu_src0_sel),
    .res(alu_src0)
);
MUX mux2(
    .src0(imm),
    .src1(rf_rd1),
    .sel(alu_src1_sel),
    .res(alu_src1)
);

ALU alu(
    .alu_src0(alu_src0),
    .alu_src1(alu_src1),
    .alu_op(alu_op),
    .alu_res(alu_res)
);

assign imem_raddr=cur_pc-32'h00400000;

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
        commit_dmem_we_reg  <= 0;   // TODO
        commit_dmem_wa_reg  <= 0;   // TODO
        commit_dmem_wd_reg  <= 0;   // TODO
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