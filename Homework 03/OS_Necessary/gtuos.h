#ifndef H_GTUOS
#define H_GTUOS

#include "8080emuCPP.h"
#include <fstream>

#define LAST_PROCESS			0xcffe
#define PROCESS_TABLE_START 	0xd000
#define BASE_PROCESS_ADDR	 	0x500
#define PROCESS_LENGTH			0x200
#define PTABLE_ENTRY_LENGTH 	0x100
#define MAILBOX_START			0x120

#define A_ADDR			0
#define B_ADDR			1
#define C_ADDR			2
#define D_ADDR			3
#define E_ADDR			4
#define H_ADDR			5
#define L_ADDR			6
#define STACK_P_L		7
#define STACK_P_H		8
#define PROG_CNT_L		9
#define PROG_CNT_H		10
#define BASE_REG_L		11
#define BASE_REG_H		12
#define PSW_ADDR		13
#define PROCESS_ID		14
#define P_STATE			15
#define P_NAME_L		16
#define P_NAME_H		17	
#define CONDITION		18
#define MAIL_DEST_ID	19
	

#define PROCESS_READY	1
#define PROCESS_RUNNING	2
#define PROCESS_BLOCKED	3

#define WAITING			0
#define SIGNALLED		1


enum SYS_CALL{
	PRINT_B = 0x04,
	PRINT_MEM = 0x03,
	READ_B = 0x07,
	READ_MEM = 0x02,
	PRINT_STR = 0x01,
	READ_STR = 0x08,
	LOAD_EXEC = 0x05,
	PROCESS_EXIT = 0x09,
	SET_QUANTUM = 0x06,
	PRINT_WHOLE = 0x0a
};


class GTUOS{	
 public:
	/*
	 * Constructor and destructor are written
	 * for file open,close processing
	 */
	GTUOS();
	~GTUOS();

	uint64_t handleCall(CPU8080	& cpu);
	uint64_t sysPrintB(CPU8080 & cpu);
	uint64_t sysPrintMem(CPU8080 & cpu);
	uint64_t sysReadB(CPU8080 & cpu);
	uint64_t sysReadMem(CPU8080 & cpu);
	uint64_t sysPrintStr(CPU8080 & cpu);
	uint64_t sysReadStr(CPU8080 & cpu);
	uint64_t loadExec(CPU8080& cpu);
	uint64_t processExit(CPU8080& cpu);
	uint64_t setQuantum(CPU8080& cpu);	
	uint64_t printWhole(CPU8080& cpu);
	uint64_t wait(CPU8080& cpu);
	uint64_t signal(CPU8080& cpu);
 private:
	/*These are used for file processing*/
	std::ifstream in;
	std::ofstream out;
};

#endif
