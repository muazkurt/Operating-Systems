        ; 8080 assembler code
        .hexfile Factorize.hex
        .binfile Factorize.com
        ; try "hex" for downloading in hex format
        .download bin  
        .objcopy gobjcopy
        .postbuild echo "OK!"
        ;.nodump

	; OS call list
PRINT_STR	equ 1
READ_MEM	equ 2
PRINT_MEM	equ 3
PRINT_B		equ 4
LOAD_EXEC	equ 5
SET_QUANTUM 	equ 6
READ_B		equ 7
READ_STR	equ 8
PROCESS_EXIT	equ 9

string:	dw ', ',00H 
NewLine: dw '',00AH,00H
errorText: dw 'NEGATIVE INPUT', 00AH, 00H

org 07H
GTU_OS:	

org 00H
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
		MVI A, PROCESS_EXIT
		CALL GTU_OS
