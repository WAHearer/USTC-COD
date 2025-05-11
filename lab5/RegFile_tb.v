`timescale 1ns / 1ps

module RegFile_tb();
    
reg clk=0;
always #5 clk = ~clk;
reg [4:0] rf_ra1,rf_wa;
reg rf_we;
reg [31:0] rf_wd;
initial begin
    #5;
    rf_ra1=1;
    rf_wa=1;
    rf_we=1;
    rf_wd=10;
end
wire [31:0] rf_rd1;
RegFile regfile(
    .clk(clk),
    .rf_ra1(rf_ra1),
    .rf_ra2(0),
    .rf_wa(rf_wa),
    .rf_we(rf_we),
    .rf_wd(rf_wd),
    .debug_reg_ra(0),
    .rf_rd1(rf_rd1)
);
endmodule