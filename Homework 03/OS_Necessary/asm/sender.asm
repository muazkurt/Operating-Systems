				; 8080 assembler code
        .hexfile sender.hex
        .binfile sender.com
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
LOAD_EXEC 		equ 5
SET_QUANTUM 	equ 6
READ_B			equ 7
READ_STR		equ 8
PROCESS_EXIT	equ 9

RAND_INT		equ 12
WAIT			equ 13
SIGNAL			equ 14	
	
	; Position for stack pointer
stack   equ 0F000h

	org 000H
	jmp begin

	; Start of our Operating System
GTU_OS:
	DI
	PUSH D
	push D
	push H
	push psw
	nop	; This is where we run our OS in C++, see the CPU8080::isSystemCall()
		; function for the detail.
	pop psw
	pop h
	pop d
	pop D
	EI
	ret
	; ---------------------------------------------------------------
	; YOU SHOULD NOT CHANGE ANYTHING ABOVE THIS LINE        

	;This program adds numbers from 0 to 10. The result is stored at variable
	; sum. The results is also printed on the screen.


OUT_NUM				equ 8d
NUM 				equ 50d
MAILBOX_IN_PR_SPACE	equ 00120h		;0500h * x + 120h = own mailbox of process.
MAILBOX_OUT_PR_SPC	equ	00156h		;own_mailbox + 54 = sending mailbox.
MAILBOX_WRITE_SEM1	equ 0016h	
MAILBOX_WRITE_MUTEX	equ 0017h	
MAILBOX_WRITE_SEM2	equ 0018h	
begin:
	;; LXI SP,stack 	; always initialize the stack pointer


MOV A, OUT_NUM
MVI D, 0
OUTER:
	PUSH PSW

	CALL LOCK
	LDX H, MAILBOX_WRITE_SEM2
	MOV A, M
	
	LDX H,MAILBOX_WRITE_SEM1
	MOV A, M
	loop:
		PUSH PSW
		ADI A, 3
		MOV E, A
		DAD D
		CALL produce

		POP PSW
		
		INC A
		CPI NUM
		JNZ loop

	CALL UNLOCK
	MVI A, SIGNAL
	MVI B, 2
	MVI C, 2

	POP PSW
	
	DCR A
	CPI 0
	JNZ OUTER

MVI A,PROCESS_EXIT
call GTU_OS
	

;;	HL -> address of adding entry's position.
produce:
	LDX A, RAND_INT
	call GTU_OS
	MOV M, B
	ret

	
LOCK:
	LXI D, MAILBOX_WRITE_MUTEX
	LXI H, 0H
	MVI A, 0H
	PUSH D
	XTHL
	CMP L
	JNZ COULDNT 
	MOV L, 0
WAIT:
		XCHG 
		CMP H
		JZ	DONE
		PUSH H
		MVI B, 2
		MVI C, 1
		MVI A, WAIT
		CALL GTU_OS
		POP H
		JMP WAIT

		
DONE:
	POP D
	ret
COULDNT:
	XTHL
	JMP LOCK

UNLOCK:
	LXI MAILBOX_WRITE_MUTEX
	MOV M, 1
	ret