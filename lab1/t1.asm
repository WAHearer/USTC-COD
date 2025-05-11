addi a2,a2,-2
addi a3,zero,1
addi a4,zero,0
loop:
beqz a2,exit
add t1,a3,a4
addi a4,a3,0
addi a3,t1,0
addi a2,a2,-1
j loop
exit:
