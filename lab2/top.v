module TOP (
    input                   [ 0 : 0]            clk,
    input                   [ 0 : 0]            rst,

    input                   [ 0 : 0]            enable,
    input                   [ 4 : 0]            in,
    input                   [ 1 : 0]            ctrl,

    output                  [ 3 : 0]            seg_data,
    output                  [ 2 : 0]            seg_an
);
reg [31:0] src0,src1,data;
reg [4:0] op;
wire [31:0] res;
ALU alu(
    .alu_src0(src0),
    .alu_src1(src1),
    .alu_op(op),
    .alu_res(res)
);
Segment segment(
    .clk(clk),
    .rst(rst),
    .output_data(data),
    .seg_data(seg_data),
    .seg_an(seg_an)
);
always @(posedge clk) begin
    if(enable) begin
        case(ctrl)
            2'b00:op<=in;
            2'b01:src0<={{27{in[4]}},in};
            2'b10:src1<={{27{in[4]}},in};
            2'b11:data<=res;
        endcase
    end
end
endmodule