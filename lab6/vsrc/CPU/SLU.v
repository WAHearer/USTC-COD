module SLU (
    input                   [ 1 : 0]                addr,
    input                   [ 3 : 0]                dmem_access,

    input                   [31 : 0]                rd_in,
    input                   [31 : 0]                wd_in,

    output      reg         [31 : 0]                rd_out,
    output      reg         [31 : 0]                wd_out
);
always @(*) begin
    case(dmem_access[3])
        1'b0:begin
            wd_out=0;
            case(dmem_access[2:0])
                3'b000:begin//lb
                    case(addr)
                        2'b00:rd_out={{24{rd_in[7]}},rd_in[7:0]};
                        2'b01:rd_out={{24{rd_in[15]}},rd_in[15:8]};
                        2'b10:rd_out={{24{rd_in[23]}},rd_in[23:16]};
                        2'b11:rd_out={{24{rd_in[31]}},rd_in[31:24]};
                    endcase
                end
                3'b001:begin//lh
                    case(addr)
                        2'b00:rd_out={{16{rd_in[15]}},rd_in[15:0]};
                        2'b10:rd_out={{16{rd_in[31]}},rd_in[31:16]};
                        default:rd_out=0;
                    endcase
                end
                3'b010:rd_out=rd_in;//lw
                3'b100:begin//lbu
                    case(addr)
                        2'b00:rd_out={24'b0,rd_in[7:0]};
                        2'b01:rd_out={24'b0,rd_in[15:8]};
                        2'b10:rd_out={24'b0,rd_in[23:16]};
                        2'b11:rd_out={24'b0,rd_in[31:24]};
                    endcase
                end
                3'b101:begin//lhu
                    case(addr)
                        2'b00:rd_out={16'b0,rd_in[15:0]};
                        2'b10:rd_out={16'b0,rd_in[31:16]};
                        default:rd_out=0;
                    endcase
                end
                default:rd_out=0;
            endcase
        end
        1'b1:begin
            rd_out=0;
            case(dmem_access[2:0])
                3'b000:begin//sb
                    case(addr)
                        2'b00:wd_out={rd_in[31:8],wd_in[7:0]};
                        2'b01:wd_out={rd_in[31:16],wd_in[7:0],rd_in[7:0]};
                        2'b10:wd_out={rd_in[31:24],wd_in[7:0],rd_in[15:0]};
                        2'b11:wd_out={wd_in[7:0],rd_in[23:0]};
                    endcase
                end
                3'b001:begin//sh
                    case(addr)
                        2'b00:wd_out={rd_in[31:16],wd_in[15:0]};
                        2'b10:wd_out={wd_in[15:0],rd_in[15:0]};
                        default:wd_out=0;
                    endcase
                end
                3'b010:wd_out=wd_in;//sw
                default:wd_out=0;
            endcase
        end
    endcase
end
endmodule