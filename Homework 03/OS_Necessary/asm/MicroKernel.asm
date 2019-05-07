					; 8080 assembler code
			.hexfile MicroKernel1.hex
			.binfile MicroKernel1.com
			; try "hex" for downloading in hex format
			.download bin  
			.objcopy gobjcopy
			.postbuild echo "OK!"
			;.nodump


	.org 000h
		jmp begin


		; Start of our Operating System
	GTU_OS:
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
		ret
		; ---------------------------------------------------------------
		; YOU SHOULD NOT CHANGE ANYTHING ABOVE THIS LINE        

		;This program adds numbers from 0 to 10. The result is stored at variable
		; sum. The results is also printed on the screen.
	;




		; OS call list
	PRINT_STR			equ 1
	READ_MEM			equ 2
	PRINT_MEM			equ 3
	PRINT_B				equ 4
	LOAD_EXEC 			equ 5
	SET_QUANTUM 		equ 6
	READ_B				equ 7
	READ_STR			equ 8
	PROCESS_EXIT		equ 9
	PRINT_WHOLE			equ 10d	
		
		

		; Position for stack pointer
	stack				equ 0F000h
	INIT_STACK 			equ 0C000h



	PTABLE_START		equ 0d000h		;start address of process table,53248
	PENTRY_LEN 			equ 00100h		;ptable entry ,256 bytes
	PROCESS_START_ADDR 	equ 00500h		;Start address of the processes
	MAILBOX_IN_PR_SPACE	equ 00120h		;0500h * x + 120h = own mailbox of process.
	PROCESS_LEN 		equ 00200h		;Length of the process,512 bytes


	MEM_BASE   			equ 256d		;Memory base for storing current process' registers


	PROCESS_COUNT		equ 0cfffh		;Store how many processes in memory
	LAST_PROCESS 		equ 0cffeh		;Store the last process scheduled
	MAX_PROCESS 		equ 0cffdh		;Store the number of processes created
	NEXT_SP 			equ 0cffbh		;Store the next stack pointer for init	

	
	.org 13d
	init 			dw 'Init'			,00H
	RECEIVER:		dw './receiver.com'	,00H
	.org 61h
	SENDER:			dw './sender.com'	,00H
	
		
	A_ADDR				equ	0d
	B_ADDR				equ	1d
	C_ADDR				equ	2d
	D_ADDR				equ	3d
	E_ADDR				equ	4d
	H_ADDR				equ 5d
	L_ADDR				equ	6d
	STACK_P_L			equ 7d
	STACK_P_H			equ 8d
	PROG_CNT_L			equ 9d
	PROG_CNT_H			equ 10d
	BASE_REG_L			equ 11d
	BASE_REG_H			equ 12d
	PSW_ADDR			equ 13d
	PROCESS_ID			equ	14d
	P_STATE				equ	15d
	P_NAME_L			equ 16d
	P_NAME_H			equ 17d
	;
	CONDITION			equ 18d
	MAIL_DEST_ID		equ 19d
	;
	PROCESS_READY		equ 1
	PROCESS_RUNNING		equ	2
	PROCESS_BLOCKED		equ 3

	;; this is called
	;; when interrupt occurs
	;; and it calls interrupt handler
	;; its address is 000D
	;; so it is loaded to 028h address
	;; at the very beginning of the program
		.org 00200H
	intr_handler_caller:
		jmp intr_handler
	;;



		
	begin:
		DI		;Disable interrupt until first scheduling done
		LXI SP,stack 	; always initialize the stack pointer
		
		call HANDLE_ID
		call INIT_PROCESSES
		MVI A,PRINT_WHOLE	
		call GTU_OS ;print process table as required
		
		jmp SCHEDULE_FIRST
	;


	;; Initialize all the processes' process tables
	;; and load them into proper address
	INIT_PROCESSES:
		LXI H,PROCESS_START_ADDR
		call INIT_PROCESS

		LXI D,PROCESS_LEN
		DAD D
		MVI A,5
		LXI B,SENDER
		call GTU_OS
		
		PUSH H
		PUSH D
		LXI D, MAILBOX_IN_PR_SPACE
		DAD D
		MVI M, 1
		POP D
		POP H


		LXI D,PROCESS_LEN
		DAD D
		LXI B,RECEIVER
		call GTU_OS

		PUSH H
		PUSH D
		LXI D, MAILBOX_IN_PR_SPACE
		DAD D
		MVI M, 1
		POP D
		POP H


		call INIT_PROCESS
		call INIT_PROCESS
		
		ret
	;


	;;Initialize the process table of the new process 
	INIT_PROCESS:
		PUSH PSW
		PUSH B
		PUSH D
		PUSH H

		LXI B,PTABLE_START	;LOAD 0d000h

		LXI D,PROCESS_COUNT
		LDAX D	;store process count in A

		LXI H,00h
		call GET_INCREMENT

		call PUT_BASE_PID_STATE_SP		;Put Base Register in the right entry
		
		call INCREMENT_PCOUNT
		
		POP H
		POP D
		POP B
		POP PSW
		ret
	;


	;; Increment Process Count stored at 0cfff
	;; Also increment number of processes created
	;; stored ad 0cffd
	INCREMENT_PCOUNT:
		LXI D,PROCESS_COUNT	;Load D Process Count which stored at 0cfff
		LDAX D
		INR A
		STAX D

		LXI D,MAX_PROCESS	;Load D num of created processes stored ad 0cffd
		LDAX D
		INR A
		STAX D
		
		ret
	;



	;; Calculate the Base Register
	;; Put it in HL
	GET_BASE:
		CPI 0
		RZ	;If process count is zero,return
		LXI D,PROCESS_LEN
		DAD D	;PTABLE_START += PROCESS_LEN
		DCR A
		jmp GET_BASE
	;


	;; Calculate the base register of the process
	;; Then put it the right place
	PUT_BASE_PID_STATE_SP:
		DAD B	;H -> H + B,current process' entry

		PUSH H	;save current process' entry	
		LXI H,PROCESS_START_ADDR
		LXI D,PROCESS_COUNT
		LDAX D	;store process count in A
		call GET_BASE

		MOV B,H	;restore base register in BC
		MOV C,L
		
		POP H

		LXI D,STACK_P_L  ;Put 7 to get SP.low
		DAD D	  ;H -> H + D ,SP.low

		MOV D,H
		MOV E,L

		PUSH B	; Base register
		PUSH H	; Stack pointer
		LXI B,248d	; 7 + _248_ = 255
		DAD B	; H -> H + 255,Start of Stack

		
		MOV A,L	;Move SP.low
		STAX D	;Store Sp.low

		INX D
		MOV A,H	;Move SP.high
		STAX D
		
		POP H	; Stack
		POP B	; Base
		
		LXI D,4d ;Put 7 + _4_ = 11 to get the place of BaseReg
		DAD D	  ;H -> H + D , BaseReg.Low

		MOV D,H
		MOV E,L

		MOV A,C
		STAX D	;Store BaseReg.Low

		INX D
		MOV A,B
		STAX D
		
		MOV H,D
		MOV L,E	;store pentry's 12th address in HL

		LXI D,PROCESS_COUNT
		LDAX D ;Store current process count as pid in A
		
		LXI D,2d	; PID is at 14th entry. 12 + _2_ = 14
		DAD D	;H -> H + 2 ,Process Id

		MOV D,H
		MOV E,L
		
		STAX D	;Store Pid at 14th place of pentry

		INX D
		MVI A,PROCESS_READY	;Process State,Ready = 1,Running = 2
		STAX D				;Store State at the 15th place of pentry

		call PUT_PROCESS_NAME
		
		ret
	;



	;; Put the process' name
	;; in the memory
	PUT_PROCESS_NAME:
		PUSH H
		LXI B,PROCESS_COUNT
		LDAX B	;Get process counter
		call GET_NAME
		INX D	;Get place of process name

		MOV A,C	;Process_Name.lower
		STAX D

		INX D
		MOV A,B	;Process_Name.higher
		STAX D
		
		INX D	;CONDITION
		INX D	;MAILBOX ID
		MOV A,H	; Store Mailbox ID, If it's 1 then read mode, own mailbox. Otherwise, write to given PID's mailbox.
		STAX D	; STORE MAILBOX ID

		POP H
		ret
	;


	;; Get the name of the process
	;; in B,
	;; Get mailbox_destination's id
	;; in D
	GET_NAME:
		LXI B,init
		CPI 0		;Check if it is Init
		MVI H, 0
		RZ		;Return if it is
		LXI B,SENDER	;Check if it is second process
		MVI H,2			; Writer to ID
		CPI 1
		RZ
		LXI B,RECEIVER	;Check if it is third process
		MVI H,1			; Read to... If 0, read from own mailbox.
		CPI 2
		RZ
		ret
	;


	;; PUT HL the increment address
	;; from the PTABLE_START
	GET_INCREMENT:
		CPI 0
		RZ ;IF process count is zero,return
		LXI D,PENTRY_LEN
		DAD D	;H -> H + D
		DCR A	;A -> A - 1
		jmp GET_INCREMENT
	;	


	;; LOAD -1 to LAST_PROCESS
	;; So first time it is incremented
	;; it becomes 0
	HANDLE_ID:
		LXI D,LAST_PROCESS
		MVI A,000h
		STAX D
		ret

	;


	;; Save all registers until all of them
	;; are stored
	SAVE_REGS:
		PUSH PSW	
		PUSH H
		PUSH B
		PUSH D
		
		MVI H,0

		LXI D,MEM_BASE
		
		
		;; LXI B,PTABLE_START	
		call LOAD_PROCESS_ENTRY	
		
		call SAVE_REGS_RECURSIVE	; BC IS AT PROCESS ID POSITION... (H[X], L[14])
		INX B						; BC = 15, STATE
		MVI A, PROCESS_READY		; STATE GOES READY
		STAX B						; MAKE PROCESS READY.

		POP D
		POP B
		POP H
		POP PSW	
		ret
	;


	;;; save the given table to process table
	SAVE_REGS_RECURSIVE:
		LDAX D
		STAX B

		INX D
		INX B

		INR H
		MOV A,H
		CPI PROCESS_ID ; check if those 14 items are stored
		JNZ SAVE_REGS_RECURSIVE
		ret
	;


	;; LOAD HL register with PC
	;; starting from PTABLE_START
	LOAD_HL_PC:
		PUSH PSW
		PUSH B
		PUSH D
		
		;; LXI B,PTABLE_START
		call LOAD_PROCESS_ENTRY
		LXI H,PROG_CNT_L
		DAD B	; H -> PTABLE_START + 9 for PC.LOW

		MOV D,H
		MOV E,L
		
		LDAX D	;LOAD PC to A
		MOV B,A
		
		INX H	; H -> PTABLE_START + 10 for PC.HIGH

		MOV D,H
		MOV E,L
		
		LDAX D	;LOAD PC to A
		
		MOV H,A
		MOV L,B

		POP D
		POP B
		POP PSW
		
		ret
	;


	;; LOAD DE register with DE
	;; starting from PTABLE_START
	LOAD_DE:
		;; LXI B,PTABLE_START
		call LOAD_PROCESS_ENTRY	
		LXI H,D_ADDR
		DAD B	; H -> PTABLE_START + 3 for D register

		MOV D,H
		MOV E,L
		
		LDAX D	;LOAD D to A
		MOV B,A
		
		INX H	; H -> PTABLE_START + 4 for E register

		MOV D,H
		MOV E,L
		
		LDAX D	;LOAD E to A
		
		MOV E,A
		MOV D,B
		
		ret
	;	


	;; LOAD HL register with HL
	;; starting from PTABLE_START	
	LOAD_HL:
		PUSH D
		PUSH B
		PUSH PSW
		
		;; LXI B,PTABLE_START
		call LOAD_PROCESS_ENTRY	
		LXI H,H_ADDR
		DAD B	; H -> PTABLE_START + 5 for H register

		MOV D,H
		MOV E,L
		
		LDAX D	;LOAD H to A
		MOV B,A
		
		INX H	; H -> PTABLE_START + 6 for L register

		MOV D,H
		MOV E,L
		
		LDAX D	;LOAD L to A
		
		MOV L,A
		MOV H,B

		POP PSW
		POP B
		POP D
		ret	
		
	;	


	;; LOAD all  registers
	;; from PTABLE_START
	;; to current registers
	;; Whole registers are loaded
	;; after this subroutine returns
	LOAD_REGS:
		call LOAD_HL	
		PUSH H

		call LOAD_DE
		PUSH D
		
		;; LXI B,PTABLE_START
		call LOAD_PROCESS_ENTRY	
		LDAX B
		MOV L,A ;Load A in L 

		INX B
		LDAX B
		MOV H,A ;Load B in H

		INX B
		LDAX B

		
		MOV C,A	;Load C in C
		MOV B,H	;LOAD B in B
		MOV A,L	;LOAD A in A

		POP D
		POP H
		ret	
	;


	;; Load flags from the 256+13
	;; to the current process' flags
	LOAD_PSW:
		PUSH B
		PUSH D
		PUSH H

		;; LXI B,PTABLE_START
		call LOAD_PROCESS_ENTRY
		LXI H,PSW_ADDR
		DAD B	; H -> PTABLE_START + 13 for PSW

		MOV B,A

		MOV C,M

		PUSH B
		POP PSW

		POP H
		POP D
		POP B
		ret
	;


	;; Load flags from the 256+13
	;; to the current process' flags
	SET_STATE:
		PUSH B
		PUSH D
		PUSH H

		;; LXI B,PTABLE_START
		call LOAD_PROCESS_ENTRY
		LXI H,P_STATE
		DAD B	; H -> H + P_STATE for process state info

		MVI M, PROCESS_RUNNING


		POP H
		POP D
		POP B
		ret
	;


	;; Instead of LXI B,PTABLE_START
	;; Use this to decide which process
	;; is going to be scheduled
	;; Put BC register the current process' entry
	LOAD_PROCESS_ENTRY:
		PUSH PSW
		PUSH D
		PUSH H
		
		LXI D,LAST_PROCESS
		LDAX D		;Store current process' id in A

		LXI H,PTABLE_START
		call GET_INCREMENT
		MOV B,H
		MOV C,L

		POP H
		POP D
		POP PSW
		ret
		
	;


	;; Gets the current process'
	;; state,current pid stored in B
	;; return the state in A
	GET_STATE:
		PUSH B
		PUSH D
		PUSH H

		MOV A,B
		LXI H,PTABLE_START
		call GET_INCREMENT	;Get HL the process' entry

		LXI D,P_STATE
		DAD D	;Get the state of the process

		MOV D,H
		MOV E,L

		LDAX D	;Load the state of the process in A
		
		POP H
		POP D
		POP B
		ret
		
	;


	;; Called from LOAD_PROCESS
	;; gets the pid of the process
	;; to be scheduled
	;; PID is stored in B
	GET_NEXT_PID:
		MOV B,A				;Store Next Pid in B

		LXI D,MAX_PROCESS
		LDAX D				;Get number of processes created
		CMP B				;Compare pid with number of processes created
		JZ MAKE_ZERO_PID	;If they are equal,start from begin

		call GET_STATE		;Get the current process' state

		CPI PROCESS_READY	;Compare current process' state
		RZ					;If it is ready,then schedule it

		CPI 0d				;If there is no process
		INR B
		MOV A,B				;Look for the next process
		jmp GET_NEXT_PID
	;


	MAKE_ZERO_PID:
		MVI A,1
		jmp GET_NEXT_PID

	;


	;; it is called when all processes are done
	;; it also kills the init process
	exit:
		LXI D,LAST_PROCESS
		MVI A,0		;load init process
		STAX D

		MVI A,PRINT_WHOLE	
		call GTU_OS ;print process table as required
		
		hlt
		
	;


	;; Choose which process to load
	;; according to last worked one
	LOAD_PROCESS:
		LXI D,PROCESS_COUNT	;check if all processes are done
		LDAX D
		CPI 1
		JZ exit
		
		LXI D,LAST_PROCESS
		LDAX D
		INR A	;Get the next Pid

		call GET_NEXT_PID

		MOV A,B
		LXI D,LAST_PROCESS
		STAX D

		ret

	;


	;; Load the SP to the HL register
	LOAD_SP:
		PUSH PSW
		PUSH D
		PUSH B

		call LOAD_PROCESS_ENTRY	;Load next process entry start

		MOV H,B	;Store entry start addrr in HL
		MOV L,C

		LXI B,STACK_P_L
		DAD B	;H -> H + B for SP.low

		MOV B,H
		MOV C,L

		LDAX B	;Get SP.low in A
		MOV E,A	;Store SP.low in E

		INX H
		MOV B,H
		MOV C,L
		LDAX B	;Get SP.high in A

		MOV H,A
		MOV L,E

		POP B
		POP D
		POP PSW
		ret

			
	;


	;; Put Base Register of the next process
	;; in DE register pair
	LOAD_BASE_REG:
		PUSH PSW
		PUSH H
		PUSH B
		call LOAD_PROCESS_ENTRY	;Load next process entry start

		MOV H,B	;Store entry start addrr in HL
		MOV L,C

		LXI B,BASE_REG_L
		DAD B	;H -> H + B for basereg.low

		
		MOV E,M	;Store basereg.low in E

		INX H	;H -> H + 1 basereg.high
		MOV D,M	;Store basereg.high in D 
		
		POP B
		POP H
		POP PSW
		ret


	;


	;; Called when an interrupt
	;; occured
	intr_handler:
		org 00028H
		POP H ;pop the return of handler since no need

		LXI SP,INIT_STACK
		
		DI
		call SAVE_REGS		;save the registers
		jmp SCHEDULE_FIRST	;schedule the processes

	;


	;; Schedule the processes
	;; using Round Robin
	SCHEDULE_FIRST:
		org 00040h	
		call LOAD_PROCESS

		call LOAD_SP
		SPHL

		call LOAD_REGS	
		PUSH D
		PUSH H
		
		call LOAD_HL_PC
		call LOAD_BASE_REG

		PUSH PSW
		MVI A,PRINT_WHOLE	
		call GTU_OS ;print process table as required
		POP PSW

		call LOAD_PSW
		
		call SET_STATE

		EI
		PCHL
	;

