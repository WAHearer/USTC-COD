module ALU_tb();
reg [31:0] src0,src1;
reg [4:0] sel;
wire [31:0] res;
    initial begin
        src0=32'hffff; src1=32'hffff; sel=5'b00000;
        #30
        sel=5'b00010;
        #30
        sel=5'b00100;
        #30
        sel=5'b00101;
        #30
        sel=5'b01001;
        #30
        sel=5'b01010;
        #30
        sel=5'b01011;
        #30
        sel=5'b01110;
        src1=32'h0002;
        #30
        sel=5'b01111;
        #30
        sel=5'b10000;
        src0=32'h8fff8fff;
        #30
        sel=5'b10001;
        #30
        sel=5'b10010;
    end
ALU alu(
    .alu_src0(src0),
    .alu_src1(src1),
    .alu_op(sel),
    .alu_res(res)
);
endmodule