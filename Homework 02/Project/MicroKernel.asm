Stack equ 0F00h
Scheudler: ; pc = 2
    DI 
        LXI SP, Stack
        POP B
        POP D
        



    EI


add_process:
    DI
        LXI H, base
        MOV B, M
        INX H
        MOV C, M
        INX H
    LOOP:
        