addi a2,a2,-2
addi a3,zero,0
addi a4,zero,1
addi a5 zero,0
addi a6,zero,1
loop:
beqz a2,exit
add t2,a4,a6
sltu t0,t2,a4#和小于加数说明发生进位
add t1,a3,a5
add t1,t1,t0
addi a5,a3,0
addi a6,a4,0
addi a3,t1,0
addi a4,t2,0
addi a2,a2,-1
j loop
exit:
ebreak