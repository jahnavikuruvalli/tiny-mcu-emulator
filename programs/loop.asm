MOV R0,5
MOV R1,1
MOV R2,1

loop:
JZ R0,done

PUSH R0
CALL multiply
POP R0

SUB R0,R2
JMP loop

done:
HALT


multiply:
MOV R3,0
PUSH R1
POP R4

mul_loop:
JZ R0,mul_end
ADD R3,R4
SUB R0,R2
JMP mul_loop

mul_end:
PUSH R3
POP R1
RET