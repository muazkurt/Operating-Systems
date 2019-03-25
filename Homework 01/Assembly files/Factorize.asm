        ; 8080 assembler code
        .hexfile Factorize.hex
        .binfile Factorize.com
        ; try "hex" for downloading in hex format
        .download bin  
        .objcopy gobjcopy
        .postbuild echo "OK!"
        ;.nodump

	; OS call list
PRINT_B		equ 4
PRINT_MEM	equ 3
READ_B		equ 7
READ_MEM	equ 2
PRINT_STR	equ 1
READ_STR	equ 8

	; Position for stack pointer
stack   equ 0F000h

	org 000H
	jmp begin

	; Start of our Operating System
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
	; ---------------------------------------------------------------
	; YOU SHOULD NOT CHANGE ANYTHING ABOVE THIS LINE        

	;This program prints a null terminated string to the screen

string:	dw ', ',00H 
NewLine: dw '',00AH,00H
errorText: dw 'NEGATIVE INPUT', 00AH, 00H


begin:
		MVI A, READ_B
		call GTU_OS
		MOV D, B
		MOV E, B
		INR D 
		MVI A, 0
		SUB B
		JP ERROR

		MVI C,1
YES:
		MOV B, C
		MVI A, PRINT_B
		call GTU_OS
		PUSH B
		LXI B, string
		MVI A, PRINT_STR
		call GTU_OS
		POP B
LOOP: 		
		INR C
		MOV A, C
		SUB D
			JZ END
		MOV A, E
MODULO: 
		SUB C
		JZ YES
		JP MODULO
		JMP LOOP

ERROR:
		LXI B, errorText
		MVI A, PRINT_STR
		call GTU_OS

END:
		LXI B, NewLine
		MVI A, PRINT_STR
		call GTU_OS
		hlt
