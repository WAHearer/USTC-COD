module BRANCH(
    input                   [ 3 : 0]            br_type,

    input                   [31 : 0]            br_src0,
    input                   [31 : 0]            br_src1,

    output      reg         [ 1 : 0]            npc_sel
);
always @(*) begin
    case(br_type)
        4'b0000:begin//beq
            if(br_src0==br_src1)
                npc_sel=2'b01;
            else
                npc_sel=2'b00;
        end
        4'b0001:begin//bne
            if(br_src0!=br_src1)
                npc_sel=2'b01;
            else
                npc_sel=2'b00;
        end
        4'b0010:npc_sel=2'b10;//jal
        4'b0011:npc_sel=2'b10;//jalr
        4'b0100:begin//blt
            if((br_src0[31]==1&&br_src1[31]==0)||(br_src0[31]==br_src1[31]&&br_src0<br_src1))
                npc_sel=2'b01;
            else
                npc_sel=2'b00;
        end
        4'b0101:begin//bge
            if((br_src0[31]==0&&br_src1[31]==1)||(br_src0[31]==br_src1[31]&&br_src0>=br_src1))
                npc_sel=2'b01;
            else
                npc_sel=2'b00;
        end
        4'b0110:begin//bltu
            if(br_src0<br_src1)
                npc_sel=2'b01;
            else
                npc_sel=2'b00;
        end
        4'b0111:begin//bgeu
            if(br_src0>=br_src1)
                npc_sel=2'b01;
            else
                npc_sel=2'b00;
        end
        default:npc_sel=2'b00;
    endcase
end
endmodule