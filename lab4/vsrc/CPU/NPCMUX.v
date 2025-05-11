module NPCMUX # (
    parameter               WIDTH                   = 32
)(
    input                   [WIDTH-1 : 0]           pc_add4,pc_offset,pc_j,
    input                   [      1 : 0]           npc_sel,

    output reg              [WIDTH-1 : 0]           npc
);

always @(*) begin
    case(npc_sel)
        2'b00:npc=pc_add4;
        2'b01:npc=pc_offset;
        2'b10:npc=pc_j;
        2'b11:npc=0;
    endcase
end

endmodule