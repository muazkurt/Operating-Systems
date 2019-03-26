PRINT_STR	equ 1
READ_MEM	equ 2
PRINT_MEM	equ 3
PRINT_B		equ 4
LOAD_EXEC	equ 5
SET_QUANTUM 	equ 6
READ_B		equ 7
READ_STR	equ 8
PROCESS_EXIT	equ 9



nameinit:   dw 'init',00H
sum:        dw 'Sum.com',00H 
primes:     dw 'Primes.com',00H
collatz:    dw 'Collatz.com',00H


Begin: Org 0 
	JMP INIT

ORG 07H
GTU_OS:	PUSH D
	push D
	push H
	push psw
	nop	; This is where we run our OS in C++, see the CPU8080::isSystemCall()
		; function for the detail.
	pop psw
	pop h
	pop d
	pop D
	ret

ORG 28H 
Scheudler:              ; pc = 28
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
        INR H           ; NEXT_NEXT POINTER H
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
        PUSH D          ; DE

        INX H           ; E
        INX H           ; H
        MOV D, M

        INX H           ; L
        MOV E, M        
        PUSH D          ; HL

        INX H           ; SP L
        INX H           ; SP H
        INX H           ; PC L
        MOV E, M

        INX H           ; PC H
        MOV D, M       
        PUSH D          ; PC

        INX H           ; BASE L
        MOV D, M

        INX H           ; BASE H
        MOV E, M
        PUSH D          ; BASE

        INX H           ; CC
        MOV L, M        
        MOV H, A
        PUSH H          ; PSW
        POP PSW         ; PSW
        POP D           ; BASE
        POP H           ; PC
    EI
    PCHL


ORG 200H
INIT: 
    DI
        LXI H, 300H
        LXI B, 200H
        MOV M, B
        INX H
        MOV M, C
        INX H               ; PROCESS ID
        MOV M, C            ; 0 INIT
        INX H               ; PROCESS NAME H
        LXI D, nameinit
        MOV M, D 
        INX H               ; PROCESS NAME L
        MOV M, E
        LXI H, 3FFH
        SPHL
    EI
    LXI H, sum
    PUSH H
    LXI H, primes
    PUSH H
    LXI H, collatz
    PUSH H
    MVI B, 1
    WHILE:
        MVI A, 3
        CMP B
        JZ ADDED

        MVI D, 2
        
        SEARCH:
            INR D
            LDAX D
            MOV E, A
            DCR D
            CMP D
            JNZ SEARCH
            JM SEARCH
            FOUND:
                    INR D           ; NEXT PROCESS POINTER
                    INR D           ; ADDING PROCESS DATA
                    INR D           ; ADDING PROCESS'S NEXT PROCESS
                    MOV H, D
                    MVI L, 0
                    MOV M, E        ; PRE-NEXT * -> NEXT_NEXT * HIGH
                    INX H
                    MVI M, 0        ; LOW
                    INX H
                    MOV M, B        ; ID
                    MOV A, B
                    POP B
                    INX H           ; NAME P HIGH
                    MOV M, B
                    INX H           ; NAME P LOW
                    MOV M, C
                    MVI L, 13       ; STACK P HIGH
                    MOV M, H        
                    DCX H           ; STACK P LOW
                    MVI M, 255
                    
                    DCR D           ; ADDING PROCESS DATA
                    MOV H, D        ;
                    MVI L, 0        ;

                    MOV E, A
                    PUSH D
                    MVI A, LOAD_EXEC
                    CALL GTU_OS     ; READ PROCESS FROM MEMORY
                    POP D
                    MOV B, E
                    INR B
                    DCR H
                    MOV M, D
                    JMP WHILE

ADDED:
    MVI A, 2
    LXI H, 300H
    LOOP:
        CMP M
        JNZ LOOP
    HLT



    

    
