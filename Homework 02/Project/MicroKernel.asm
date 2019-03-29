       	; 8080 assembler code
        .hexfile MicorKernel1.hex
        .binfile MicorKernel1.com
       	; try "hex" for downloading in hex format
        .download bin  
        .objcopy gobjcopy
        .postbuild echo "OK!"
       	;.nodump

	; OS call list
PRINT_STR		equ 1
READ_MEM		equ 2	
PRINT_MEM		equ 3
PRINT_B			equ 4
LOAD_EXEC		equ 5
SET_QUANTUM 	equ 6
READ_B			equ 7
READ_STR		equ 8
PROCESS_EXIT	equ 9



Begin: Org 0
	JMP INIT


nameinit:	dw 'init',00H
	
ORG 07H
GTU_OS: 


sum:		dw 'Sum.com',00H 
primes:		dw 'Primes.com',00H
collatz:	dw 'Collatz.com',00H


ORG 28H 
Scheudler:				 ; pc = 28
	DI
		LXI H, 10AH
		MOV B, M
		LDA 10CH
		ADD B
		MOV B, A
		MVI C, 255
		INX B			; NEXT PROCESS POINTER H
		MOV H, B
		MOV L, C
		MOV B, M
		INX H			;NEXT PROCESS POINTER L
		MOV C, M
		PUSH B			 ; NEXT PROCESS
			INX H			; C PROCESS ID
			INX H			; C PROCESS NAME P H
			INX H			; C PROCESS NAME P L
			
			INX H			; A
			LDA 100H
			MOV M, A

			INX H			; B
			LDA 101H
			MOV M, A

			INX H			; C
			LDA 102H
			MOV M, A
			
			INX H			; D
			LDA 103H
			MOV M, A
			
			INX H			; E
			LDA 104H
			MOV M, A
			
			INX H			; H
			LDA 105H
			MOV M, A
			
			INX H			; L
			LDA 106H
			MOV M, A
			
			INX H			; SP L
			LDA 107H
			MOV M, A
			
			INX H			; SP H
			LDA 108H
			MOV M, A
			
			INX H			; PC L
			LDA 109H
			MOV M, A
			
			INX H			; PC H
			LDA 10AH
			MOV M, A
			
			INX H			; BASE L
			LDA 10BH
			MOV M, A
			
			INX H			; BASE H
			LDA 10CH
			MOV M, A
			
			INX H			; CC
			LDA 10DH
			MOV M, A
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		POP H
		INR H			; NEXT_NEXT POINTER H
		INX H			; NEXT_NEXT POINTER L
		INX H			; NEXT_NEXT PROCESS ID 
		INX H			; NEXT_NEXT PROCESS NAME H
		INX H			; NEXT_NEXT PROCESS NAME L

		INX H			; A
		MOV A, M		

		INX H			; B
		MOV B, M

		INX H			; C
		MOV C, M

		INX H			; D
		INX H			; E
		INX H			; H
		INX H			; L	
		INX H			; SP L
		MOV E, M		; D <- SP L
		INX H			; SP H
		MOV D, M		; D <- SP H
		XCHG			; DE <-> HL
		SPHL
		XCHG			; DE <-> HL
		DCX H			; SP L	
		DCX H			; L
		DCX H			; H

		DCX H			; E
		MOV E, M

		DCX H			; D
		MOV D, M
		PUSH D				 ; DE

		INX H			; E
		INX H			; H
		MOV D, M

		INX H			; L
		MOV E, M			
		PUSH D			 ; HL

		INX H			; SP L
		INX H			; SP H
		INX H			; PC L	
		MOV E, M	

		INX H			; PC H
		MOV D, M		
		PUSH D			 ; PC

		INX H			; BASE L
		MOV E, M

		INX H			; BASE H
		MOV D, M
		PUSH D			 ; BASE

		INX H			; CC
		MOV L, M		
		MOV H, A
		PUSH H			 ; PSW
		POP PSW			; PSW
		POP D			; BASE
		POP H			; PC
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
		INX H				; PROCESS ID
		MOV M, C			; 0 INIT
		INX H				; PROCESS NAME H
		LXI D, nameinit
		MOV M, D 
		INX H				; PROCESS NAME L
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
		MVI A, 4
		CMP B
		JZ ADDED

		MVI D, 2
		MVI E, 0

		DI
		SEARCH:
			INR D
			LDAX D
			MOV E, A
			DCR D
			CMP D
			JZ FOUND
			JM FOUND
				MOV D, E
				MVI E, 0
				JMP SEARCH
			FOUND:
					INR D			; NEXT PROCESS POINTER
					MOV H, D		; NEXT PROCESS POINTER
					MVI L, 0
					INR D			; ADDING PROCESS DATA
					MOV M, D
					INX H
					MVI M, 0
					INR D			; ADDING PROCESS'S NEXT PROCESS
					MOV H, D
					MVI L, 0
					MOV M, E		; PRE-NEXT * -> NEXT_NEXT * HIGH
					INX H
					MVI M, 0		; LOW
					INX H
					MOV M, B		; ID
					MOV A, B
					POP B
					INX H			; NAME P HIGH
					MOV M, B
					INX H			; NAME P LOW
					MOV M, C
					INX H			; A
					MVI M, 0
					INX H			; B
					MVI M, 0		
					INX H			; C
					MVI M, 0		
					INX H			; D
					MVI M, 0		
					INX H			; E
					MVI M, 0		
					INX H			; H
					MVI M, 0		
					INX H			; L
					MVI M, 0		

					INX H			; STACK P LOW
					MVI M, 255
					INX H			; STACK P HIGH
					MOV M, H		

					INX H			; PC LOW
					MVI M, 0	
					INX H			; PC HIGH
					MVI M, 0		; PC HIGH 0

					INX H			; BASE L
					MVI M, 0		; BASE L <- 0
					INX H			; BASE H
					DCR D			; ADDING PROCESS'S DATA
					MOV M, D		; BASE H <- PROCESS DATA START

					INX H			; CC
					MVI M, 0		


					MOV H, D		;
					MVI L, 0		;

					MOV E, A
					MVI A, LOAD_EXEC
				EI
					CALL GTU_OS		; READ PROCESS FROM MEMORY
					MOV B, E
					INR B
				
					JMP WHILE

ADDED:
	MVI A, 2
	LXI H, 300H
	LOOP:
		CMP M
		JNZ LOOP
	HLT



	

	
