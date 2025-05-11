module SegCtrl (
    input      [ 0:0] rf_we_ex,
    input      [ 1:0] rf_wd_sel_ex,
    input      [ 4:0] rf_wa_ex,
    input      [ 4:0] rf_ra1_id,rf_ra2_id,
    input      [ 1:0] npc_sel_ex,

    output reg [ 0:0] stall_pc,stall_if_id,flush_if_id,flush_id_ex
);
always @(*) begin
    if(rf_we_ex&&rf_wd_sel_ex==2'b10&&rf_wa_ex!=0&&(rf_ra1_id==rf_wa_ex||rf_ra2_id==rf_wa_ex))
        stall_pc=1;
    else
        stall_pc=0;
    if(rf_we_ex&&rf_wd_sel_ex==2'b10&&rf_wa_ex!=0&&(rf_ra1_id==rf_wa_ex||rf_ra2_id==rf_wa_ex))
        stall_if_id=1;
    else
        stall_if_id=0;
    if(npc_sel_ex!=2'b00)
        flush_if_id=1;
    else
        flush_if_id=0;
    if((rf_we_ex&&rf_wd_sel_ex==2'b10&&rf_wa_ex!=0&&(rf_ra1_id==rf_wa_ex||rf_ra2_id==rf_wa_ex))||(npc_sel_ex!=2'b00))
        flush_id_ex=1;
    else
        flush_id_ex=0;
end
endmodule