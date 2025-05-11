module RF_WD_MUX # (
    parameter               WIDTH                   = 32
)(
    input                   [WIDTH-1 : 0]           src0, src1, src2, src3,
    input                   [      1 : 0]           sel,

    output reg              [WIDTH-1 : 0]           res
);

always @(*) begin
    case(sel)
        2'b00:res=src0;
        2'b01:res=src1;
        2'b10:res=src2;
        2'b11:res=src3;
    endcase
end

endmodule