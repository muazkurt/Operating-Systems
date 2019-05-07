				; 8080 assembler code
        .hexfile receiver.hex
        .binfile receiver.com
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
STACK_BEFORE 	equ 54013


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
MUTEX_XTHL	        equ 0011Fh		;0500h + 0200h * x + 120h = own mailbox of process.
									; declared as 119 because, XTHL exchanges sp and sp + 1
MAILBOX_WRITE_MUTEX	equ 00120h	
MAILBOX_WRITE_SEM1	equ 00121h	
MAILBOX_WRITE_SEM2	equ 00122h	
MAILBOX_O_INDEX		equ 00123h
begin:

;MVI A, OUT_NUM
;MVI D, 0
;OUTER:
;	PUSH PSW

;	CALL LOCK
;	LXI H, MAILBOX_WRITE_SEM2
;	MOV A, M
	

	loop:
		CALL LOCK					;Lock mutex.
		LXI H,MAILBOX_WRITE_SEM1	;SEMAPHORE, WHERE TO PUT ITEM
        MVI A, 0
    C_WAIT:
        CMP M
        JNZ GOON
			PUSH B
			MVI A, WAIT
			MVI B, 1
			MVI C, 2
			CALL GTU_OS
			POP B
			JMP C_WAIT
    GOON:
        MOV E,M
		LXI H,MAILBOX_O_INDEX		;first element of mailbox.
		MVI D,0
		DAD D
		CALL consume				;Generate a random number.

		LXI H,MAILBOX_WRITE_SEM1	;MAILBOX COUNTER'S POSITION		
	    DCR M						;DE-Sem Write. Save mailbox's item count in semaphore..
		CALL UNLOCK
        PUSH B
        MVI A, SIGNAL
        MVI B, 1
        MVI C, 1
        CALL GTU_OS
        POP B
		MVI A, NUM
		CMP M
		JNC loop

    LXI H, MAILBOX_WRITE_SEM2
    MVI M, 1

OOOHOOOO:
    MVI A, 0
    CMP M
    JNZ OOOHOOOO
;	CALL UNLOCK
;	MVI A, SIGNAL
;	MVI B, 2
;	MVI C, 2

;	POP PSW
	
;	DCR A
;	CPI 0
;	JNZ OUTER

MVI A,PROCESS_EXIT
call GTU_OS
	

;;	HL -> address of adding entry's position.
consume:
    
	ret

LOCK:
	LXI H, MUTEX_XTHL				;MUTEX - 1
	SPHL							;PUSH SEM WRITE ADDRESS TO EXCHANGE WITH L, H
	MVI A, 1H						;MUTEX'S LOCKABLE VALUE, LOAD FOR COMPARING
	MOV L, M						;SAVE MUTEX-1'S CURRENT VALUE
	MVI H, 0H						;MUTEX, LOCKED VALUE
BUSY_W:
	XTHL							; H <- MUTEX, L <- SEM WRITE
	CMP H							; MUTEX == 1?
	JNZ BUSY_W	 					; LOCKED, GOTO FINISH OF PROCEDURE
	LXI H, STACK_BEFORE
	SPHL
	ret								; RETURN.
;


UNLOCK:
	LXI H, MAILBOX_WRITE_MUTEX		;HL <- ADDRESS OF THE MUTEX
	MVI M, 1						; MUTEX <- 1 (UNLOCKED)
	ret								; RETURN