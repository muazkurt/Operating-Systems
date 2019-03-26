PRINT_STR	equ 1
READ_MEM	equ 2
PRINT_MEM	equ 3
PRINT_B		equ 4
READ_B		equ 7
READ_STR	equ 8

sum:        dw 'Sum.com',00H 
primes:     dw 'Primes.com',00H
collatz:    dw 'Collatz.com',00H


Scheudler: ORG 2; pc = 2
    DI
        LXI H, 10AH
        MOV B, M
        MVI C, 255
        INX B           ; NEXT PROCESS POINTER H
        MOV H, B
        MOV L, C
        MOV B, M
        INX H           ;NEXT PROCESS POINTER L
        MOV C, M
        PUSH B          ; NEXT PROCESS
            INX H           ; C PROCESS ID
            INX H           ; C PROCESS NAME P H
            INX H           ; C PROCESS NAME P L
            
            INX H           ; A
            LDA 100H
            MOV M, A

            INX H           ; B
            LDA 101H
            MOV M, A

            INX H           ; C
            LDA 102H
            MOV M, A
            
            INX H           ; D
            LDA 103H
            MOV M, A
            
            INX H           ; E
            LDA 104H
            MOV M, A
            
            INX H           ; H
            LDA 105H
            MOV M, A
            
            INX H           ; L
            LDA 106H
            MOV M, A
            
            INX H           ; SP L
            LDA 107H
            MOV M, A
            
            INX H           ; SP H
            LDA 108H
            MOV M, A
            
            INX H           ; PC L
            LDA 109H
            MOV M, A
            
            INX H           ; PC H
            LDA 10AH
            MOV M, A
            
            INX H           ; BASE L
            LDA 10BH
            MOV M, A
            
            INX H           ; BASE H
            LDA 10CH
            MOV M, A
            
            INX H           ; CC
            LDA 10DH
            MOV M, A
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        POP H
        MVI A, 1
        ADD H
        MOV H, A        ; NEXT_NEXT POINTER H
        INX H           ; NEXT_NEXT POINTER L
        INX H           ; NEXT_NEXT PROCESS ID 
        INX H           ; NEXT_NEXT PROCESS NAME H
        INX H           ; NEXT_NEXT PROCESS NAME L

        INX H           ; A
        MOV A, M        

        INX H           ; B
        MOV B, M

        INX H           ; C
        MOV C, M

        INX H           ; D
        INX H           ; E
        INX H           ; H
        INX H           ; L
        INX H           ; SP L
        MOV E, M        ; D <- SP L
        INX H           ; SP H
        MOV D, M        ; D <- SP H
        XCHG            ; DE <-> HL
        SPHL
        XCHG            ; DE <-> HL
        DCX H           ; SP L
        DCX H           ; L
        DCX H           ; H

        DCX H           ; E
        MOV E, M

        DCX H           ; D
        MOV D, M
    PUSH D              ; DE

        INX H           ; E
        INX H           ; H
        MOV D, M

        INX H           ; L
        MOV E, M        
    PUSH D              ; HL

        INX H           ; SP L
        INX H           ; SP H
        INX H           ; PC L
        MOV D, M

        INX H           ; PC H
        MOV E, M       
    PUSH D              ; PC

        INX H           ; BASE L
        MOV D, M

        INX H           ; BASE H
        MOV E, M
    PUSH D              ; BASE

        INX H           ; CC
        MOV H, M        
        MOV L, A
    PUSH D              ; PSW
    POP PSW
    POP D               ; BASE
    POP H               ; PC
    EI
    PCHL



init: ORG 200H
    DI
        LXI H, 300H
        LXI B, 200H
        MOV M, B
        INX H
        MOV M, C
        LXI H, 3FFH
        SPHL
    EI
    LXI H, sum
    PUSH H
    LXI H, primes
    PUSH H
    LXI H, collatz
    PUSH H
    MOV A, 0
    

    
