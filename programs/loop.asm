MOV R0, 3
MOV R1, 1

loop:
SUB R0, R1
JZ end
JMP loop

end:
HALT
