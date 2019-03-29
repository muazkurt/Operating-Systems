        ; 8080 assembler code
        .hexfile printstr.hex
        .binfile printstr.com
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
stack   equ 0F000h

	org 000H
	jmp begin
	org 007H
	; Start of our Operating System
GTU_OS:

string:	dw 'Hello world',00AH,00H ; null terminated string

begin:
	LXI SP,stack 	; always initialize the stack pointer

			; Now we will call the OS to print the value of sum
	LXI B, string	; put the address of string in registers B and C
	MVI A, PRINT_STR	; store the OS call code to A
	call GTU_OS	; call the OS
	MVI A, PROCESS_EXIT
	CALL GTU_OS
