       	; 8080 assembler code
        .hexfile Primes.hex
        .binfile Primes.com
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




	; Position for stack pointer

	org 000H
	jmp begin

	org 007H
		; Start of our Operating System
GTU_OS:
	; ---------------------------------------------------------------
	; YOU SHOULD NOT CHANGE ANYTHING ABOVE THIS LINE        

	;This program prints a null terminated string to the screen

start_print: dw '00',00AH,00H
sec_print: dw '01',00AH,00H
prime: dw 'prime',00H
newline: dw 00AH,00H


memory: ds 60
current: ds 2


begin:
	LXI B, start_print					; B <- '0\n'
	MVI A, PRINT_STR					; A <- print string opcode
	call GTU_OS 						; system call

	LXI B, sec_print					; B <- '1\n'
	call GTU_OS						; system call

	
	LXI B, memory						; <- BC <- memory's address
	PUSH B 							; push B and C registers to stack (Current Working Possition)
	MVI A, 0 						; MS byte of 2
	STAX B 							; Store A register's content into (BC) ... BC' pointed address's memory content
	INX B 							; BC <- BC + 1
	MVI A, 2 						; LS byte of 2
	STAX B 

start_op:	
							;while *current < 1000
	POP H 							; Read 2 Stack content to HL (NOW HL is Memmory's current pointed address)
	PUSH H 							; Push Memmory position to stack for possible loss
		MOV B, M 					; Read memory content to B (MS byte of current working integer)
		INX H						; Current Position <- Current Position + 1
		MOV C, M 					; Read memory content to C (LS byte of current working integer)

		MVI A, 0 					; Load A <- 1000's LS byte (1110 1000), 232
		CMP C						; Compare A with C (IF C == A ? Z = 1 : Z = 0)
		JNZ KEEP_GOING					; if not equal, keep going (no necessarity to check ms byte).
		MVI A, 1 					; Load A <- 1000's MS byte (0000 0011), 2
		CMP B 						; Compare A with B (IF B == A ? Z = 1 : Z = 0)
		JZ finish 					;if equal, finish operations, keep going otherwise

	KEEP_GOING:
	POP B							; Get current memory position to BC (MS byte of working content)
	PUSH B							; 	Push it for possible loss
	MVI A, PRINT_MEM					; A <- Print_mem 
	call GTU_OS						; system call
	INX B							; BC <- BC + 1 (LS byte of working content)
	call GTU_OS						; system call

	LXI H,memory						; HL <- Start position of Memory. (temp = memory)

	SEARCH:
							;while (temp != current)
		POP B						; BC <- current working memory position
		PUSH B						; 	Push for possible loss
			MOV A, L				; A <- L (LS byte of temp...iterator)
			CMP C					; Check iterator and current working memmory position's LS bytes are equal (IF C == A ? Z = 1 : Z = 0)
			JNZ STILL_ALIVE				; If not equal, then temp is still less than current working memmory position.
			MOV A, H				; A <- H (MS byte of temp...iterator)
			CMP B					; Check iterator and current working memmory position's MS bytes are equal.
			JZ yes_prime				; If they are matched, no prewious prime integers can divide the currently working int.

		STILL_ALIVE:
		PUSH H						; Temp (HL) -> stack
			MOV D, M				; D <- HL (temp (iterator) content's MS byte )
			INX H					; HL <- HL + 1 for finding LS byte 
			MOV E, M				; E <- HL (LS byte of temp(iterator)'s content)
			INX H					; Finding next iterator position. HL <- HL + 1, temp += 1
		POP H						; Temp (HL) <- stack

		POP B						; BC <- Current working memory position.
		PUSH B						; 	push for possible memory loss
		PUSH H						; Push Next working position (temp)
			MOV H, B				; Current working position, BC
			MOV L, C				;		to HL 
			MOV B, M				; Current working position's content(MS) to B
			INX H					; HL <- HL + 1, Current working position's LS byte address.
			MOV C, M				; Current working position's content(LS) to C
		POP H						; Restore Temp into memory.
	

			MOD:
			PUSH H					; Push Temp into memory for possible loss
				MOV A, B			; Current working address's content's MS to A
				CMA				; A <- A'
				MOV H, A			; H <- A (CWA's content's MS byte's 1s compliment to H)
				MOV A, C			; Current working address's content's LS to A
				CMA				; A <- A'
				MOV L, A			; L <- A (CWA's content's LS byte's 1s compliment to L)
				DAD D				; *temp + (1s compliement of *curr) 
				INX H				; HL <- HL + 1. (*temp + (2s compliement of *curr)) = (*temp - *curr)
				MVI A, 128			; A <- 1000 0000
				ANA H				; A <- A & H
				PUSH H				; Push (*temp - *curr) because its important
					MOV H, A		; H <- A, (check MSB is 1 or 0)
					MVI A, 128		; A <- 1000 0000
					CMP H			; Check if MSB is 0 or 1 (*temp - *curr)'s result was positive or negative.
				POP H				; Restore (*temp - *curr)
				JZ Calculation			; If (*temp - *curr) < 0, keep on calculating modulo

				MVI A, 0			; A <- 0000 0000
				ORA H				; MS byte of (*temp - *curr) | 0
				ORA L				; LS byte of (*temp - *curr) | 0
				MOV H, A			; H <- A | H(old) | L
				MVI A, 0			; A <- 0000 0000
				CMP H				; OR operations must be equal to 0, if the result is 0
			POP H					; Restore Temp.
			JZ not_prime				; If (*temp - *curr) == 0, it's not prime.
			INX H					; temp + 1 for LS *temp
			INX H					; temp + 2 for next position
			JMP Search				; IF (*temp - *curr) == 0, then temp positioned prime number and currently working number are prime in between them.

				Calculation:
					POP H			; Restore temp
					PUSH H			; Save Temp for possible loss
					PUSH B			; Save Current Working position for possible loss
						MOV B, M	; B <- *temp(MS byte)
						INX H		; *temp + 1 for LS byte
						MOV L, M	; L <- *temp(LS byte)
						MOV H, B	, H <- *temp(MS byte)
						DAD D		; D <- D + *temp, E <- E + *temp
						MOV D, H	;
						MOV E, L	;
					POP B			; Restore currently working position.
					POP H			; Restore temp
					JMP MOD			; GOTO check modulo operation


	yes_prime:						; If number is prime
		PUSH B						; Save BC for safety
		MVI A, PRINT_STR				; A <- Print string system call number
		LXI B, prime					; Put string's address into BC.
		CALL GTU_OS					; system call
		POP B						; Restore BC.
		
		POP H						; BC <- Currently working position (curr)
		MOV B, M					; B <- Currently working position's content(MS byte) (*curr (MS))
		INX H						; Cwp LS byte
		MOV C, M					; C <- Currently working position's content(LS byte) (*curr (LS))
		INX H						; Next working Position <- Current working position. (curr+= 1)
		PUSH H						; Save it for later usages.
		MOV M, B					; Fill next position's content's(MS) with *curr(MS)
		INX H						; point to LS byte 
		MOV M, C					; Fill next position's content's(LS) with *curr(LS)

	not_prime:						; If number is not prime
		PUSH B
		MVI A, PRINT_STR			
		LXI B, newline
		CALL GTU_OS
		POP B
	POP H							; Restore curr
	PUSH H							; Save for next usages
	MOV B, M						; B <- *curr(MS byte)
	INX H							; New curr's content's LS position.
	MOV C, M						; C <- *curr(LS byte)
	INX B							; BC <- BC + 1, next working number
	POP H							; Curr(MS)
	PUSH H							; Save for next usages
	MOV M, B						; Save B (NEXT ITEMS MS byte) as the new curr's content(MS).
	INX H							; Curr(LS)
	MOV M, C						; Save C (NEXT ITEMS LS byte) as the new curr's content(LS).
	
	JMP start_op						; go to calculation 

finish:
	POP B							; Free stack.
	MVI A, PROCESS_EXIT
	CALL GTU_OS
							; EXIT


