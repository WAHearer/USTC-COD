module PC (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,
    input                   [ 0 : 0]            en,
    input                   [31 : 0]            npc,

    output      reg         [31 : 0]            pc
);
initial begin
    pc=32'h00400000;
end
always @(posedge clk) begin
    if(rst)
        pc<=32'h00400000;
    else if(en)
        pc<=npc;
end
endmodule