        ; 8080 assembler code
        .hexfile Palindrome.hex
        .binfile Palindrome.com
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

yes:	dw ': Palindrome',00AH,00H 
no:	dw ': NOT Palindrome',00AH,00H
input:	ds 255

begin:
	LXI B, input
	MVI A, READ_STR
	call GTU_OS
	PUSH B			;store start
	MVI A, PRINT_STR
	call GTU_OS	
	
	MOV H, B
	MOV L, C
	MVI A, 0
LOOP:
	MOV B, M
	CMP B
	JZ OUT
	INX H
	JMP LOOP
OUT:
	DCX H
	PUSH H
	
Search_words:
	POP H
	POP D
	PUSH D
	PUSH H
	MOV A, H
	CMA
	MOV H, A
	MOV A, L
	CMA
	MOV L, A
	DAD D
	INX H
	PUSH H
		MVI A, 128
		ANA H
		MVI H, 128
		CMP A
	POP H
	JNZ yes_p
	MOV A, H
	ORA L
	MVI L, 0
	CMP L
	JZ yes_p
	POP H
	PUSH H

	MOV B, M
	MOV H, D
	MOV L, E
	MOV C, M
	

	MOV A, B
	XRA C
	MVI B, 0
	CMP B
	JNZ not_p
	
	POP H
	POP D
		INX D
		DCX H
	PUSH D
	PUSH H
	JMP Search_words




not_p:
	POP D
	POP H
	LXI B, no
	MVI A, PRINT_STR
	call GTU_OS
	hlt

yes_p:
	POP D
	POP H
	LXI B, yes
	MVI A, PRINT_STR
	call GTU_OS
	hlt
