#include <iostream>
#include "8080emuCPP.h"
#include "gtuos.h"
#include "memory.h"
#include <string.h>
#include <fstream> 

using namespace std;

#define CYCLE 10

GTUOS::GTUOS(){
	//string inputFile = "input.txt";
	//string outputFile = "output.txt";	

	/*open files*/
	//cin.open(inputFile);
	//cout.open(outputFile);	
}

GTUOS::~GTUOS(){
	/*close files*/
	//cin.close();
	//cout.close();	
}

/*
	Handle the operating system calls
*/
uint64_t GTUOS::handleCall(CPU8080& cpu)
{
	//cout << "system" << endl;
	uint16_t cycles;

	int c = 0;
	if(1 || (cin && cout))
	{
		switch(cpu.state->a)
		{
			case PRINT_B:
				cycles = sysPrintB(cpu);
				break;	
			case PRINT_MEM:
				cycles = sysPrintMem(cpu);	
				break;
			case READ_B:
				cycles = sysReadB(cpu);
				break;
			case READ_MEM:
				cycles = sysReadMem(cpu);
				break;
			case PRINT_STR:
				cycles = sysPrintStr(cpu);
				break;
			case READ_STR:
				cycles = sysReadStr(cpu);
				break;
			case LOAD_EXEC:
				cycles = loadExec(cpu);
				break;
			case PROCESS_EXIT:
				cycles = processExit(cpu);
				break;
			case SET_QUANTUM:
				break;
			case PRINT_WHOLE:
				cycles = printWhole(cpu);
				break;
			case 11:		
				for(int i = 0 ; i < 0x10000 ; ++i){
				// for(int i = 53248 ; i < 53280 ; ++i){
					if(i % 32 == 0){
						printf("\n");
						printf("%d - ",c++);
					}
					printf("%3d ",cpu.memory->at(i));
				}
				printf("\n");
				break;
			case 12:
				cout << endl << "generated :" << (cpu.state->b = ((Memory *) cpu.memory)->getBaseRegister() >> 8) << " by ";
				//printf("%x\nWrites to: %x\n", ((Memory *) cpu.memory)->getBaseRegister(), (cpu.state->h << 8) | cpu.state->l);

				cycles = 60;
				break;
			case 13:
				cycles = wait(cpu);
				break;
			case 14:
				break;
			default:
				exit(EXIT_FAILURE);
				break;
		}
	}
	else
		cout << "Not found input.txt or output.txt" << endl;
	return cycles;
}



uint64_t GTUOS::wait(CPU8080& cpu)
{
	uint16_t 	condition_addr	= PROCESS_TABLE_START + PTABLE_ENTRY_LENGTH * cpu.state->c
									+ CONDITION;
	uint8_t 	status_addr		= PROCESS_TABLE_START + PTABLE_ENTRY_LENGTH * cpu.state->c
									+ P_STATE;

	cpu.memory->physicalAt(condition_addr)	= WAITING;
	cpu.memory->physicalAt(status_addr)		= PROCESS_BLOCKED;
	cpu.dispatchScheduler();
	return 200;
}


uint64_t GTUOS::signal(CPU8080& cpu)
{
	uint16_t 	condition_addr	= PROCESS_TABLE_START + PTABLE_ENTRY_LENGTH * cpu.state->c
									+ CONDITION;
	uint8_t 	status_addr		= PROCESS_TABLE_START + PTABLE_ENTRY_LENGTH * cpu.state->c
									+ P_STATE;

	cpu.memory->physicalAt(condition_addr)	= SIGNALLED;
	cpu.memory->physicalAt(status_addr)		= PROCESS_READY;
	cpu.dispatchScheduler();
	return 200;
}


/*
 * Called when scheduling happened
 * Prints PID,PC,MEM_BASE Content and Address,SP
 **/
uint64_t GTUOS::printWhole(CPU8080& cpu)
{
	uint8_t pid 			= cpu.memory->at(LAST_PROCESS);
	uint16_t ptableAddr 	= PROCESS_TABLE_START + pid * PTABLE_ENTRY_LENGTH;
	uint16_t pAddr		 	= BASE_PROCESS_ADDR + pid * PROCESS_LENGTH;

	uint16_t sp 			= (cpu.memory->at(ptableAddr + STACK_P_H) 	<< 8) | cpu.memory->at(ptableAddr + STACK_P_L);
	uint16_t pc				= (cpu.memory->at(ptableAddr + PROG_CNT_H) << 8) | cpu.memory->at(ptableAddr + PROG_CNT_L);
	uint16_t base 			= (cpu.memory->at(ptableAddr + BASE_REG_H) << 8) | cpu.memory->at(ptableAddr + BASE_REG_L);
	uint16_t baseContent 	= base + pc;
	uint16_t processNameAddr= (cpu.memory->at(ptableAddr + P_NAME_H) << 8) | cpu.memory->at(ptableAddr + P_NAME_L);
	{
		cout << "\n----Context Scheduling----" << endl;
		printf("PID	 :\t%4d | ",	pid);
		printf("PNAME	: ");
		while(cpu.memory->at(processNameAddr) != (uint8_t) 0)
		{
			cout << cpu.memory->at(processNameAddr);
			processNameAddr++;
		}
		printf("\t| ");

		printf("PC	:\t%4x | ",	pc);
		printf("SP	:\t%4x = %4x | ",	sp, cpu.memory->at(sp));
		printf("BASE	:\t%4x | ",	base);
		printf("BASE_CONTENT	:\t%4x\n",	baseContent);
		cout << endl;
	}
	uint8_t dest = cpu.memory->at(ptableAddr + MAIL_DEST_ID);
	cout << (int) dest << endl;
	if(dest == 0);
	else
	{
		uint16_t destAddr = BASE_PROCESS_ADDR;
		for(uint8_t tempPid = dest; tempPid > 0; --tempPid)
			destAddr	+= PROCESS_LENGTH;
		destAddr	+= MAILBOX_START;
		pAddr 		+= MAILBOX_START;
		for(int i = 0; i < 53; ++i)
			cout << (int) (cpu.memory->physicalAt(pAddr + i) = cpu.memory->physicalAt(destAddr + i)) << " ";
	}
	cout << endl << "--------------------------------------" << endl;
	return CYCLE;
}

/*
 * Called to set the quantum time of scheduling
 */
uint64_t GTUOS::setQuantum(CPU8080& cpu){
	uint8_t quantum = cpu.state->b;
	cpu.setQuantum(quantum);
	return 0;
}

/*
 * Caleld when a process wants to exit
 * Removes process from the memory,
 * process table and reduces number of processes
 * by one
 */
uint64_t GTUOS::processExit(CPU8080& cpu)
{

	uint16_t ptableAddr = PROCESS_TABLE_START;
	
	uint16_t currProcessAddr = ((Memory*)(cpu.memory))->getBaseRegister();
	uint16_t tempProcessAddr = currProcessAddr;

	uint16_t schedulerAddr = 0x00040;
	
	int i = 0;
	while(tempProcessAddr != BASE_PROCESS_ADDR){
	tempProcessAddr -=PROCESS_LENGTH;
	i++;
	}

	while(i > 0){
	ptableAddr += PTABLE_ENTRY_LENGTH;
	i--;
	}

	uint16_t processCount = 0x0cfff;
	
	((Memory*)(cpu.memory))->setBaseRegister(0);
	memset(&cpu.memory->at(currProcessAddr),0,PROCESS_LENGTH);
	memset(&cpu.memory->at(ptableAddr),0,PTABLE_ENTRY_LENGTH);

	//cpu.memory->at(LAST_PROCESS) = cpu.memory->at(LAST_PROCESS) - 1;
	cpu.memory->at(processCount) = cpu.memory->at(processCount) - 1;
	cpu.state->pc = schedulerAddr; //go back to scheduler
	return (CYCLE * 8);
}

/*
 * Loads a new process to the given address 
 **/
uint64_t GTUOS::loadExec(CPU8080& cpu)
{
	uint16_t fileNameAddr;
	uint16_t processStartAddr;
	
	char* fileName = (char* ) malloc(sizeof(uint8_t) * 64);

	fileNameAddr = ((uint16_t)cpu.state->b << 8) | cpu.state->c;

	int i = 0;
	while(cpu.memory->at(fileNameAddr) != (uint8_t) 0)
	{
		fileName[i] = cpu.memory->at(fileNameAddr);
		fileNameAddr++;
		i++;
	}
	fileName[i] = 0;

	processStartAddr = ((uint16_t)cpu.state->h << 8) | cpu.state->l;
	printf("%s, %d\n", fileName, processStartAddr);
	cpu.ReadFileIntoMemoryAt(fileName, processStartAddr);
	return (CYCLE * 10);
}

/*
	Print the contents of register B
*/
uint64_t GTUOS::sysPrintB( CPU8080& cpu)
{
	//cout << "-";
	cout << (int)cpu.state->b;
	//printf("%d",(int)cpu.state->b);
	return CYCLE;
}
/*
	Print the content of memory pointed by B and C
	Calculate start address first then get the block
*/
uint64_t GTUOS::sysPrintMem( CPU8080& cpu)
{
	uint16_t fileNameAddr;
	fileNameAddr = ((uint16_t)cpu.state->b << 8) | cpu.state->c;
	cout << (int)cpu.memory->at(fileNameAddr);
	//printf("%02x\n",(int)cpu.memory->at(fileNameAddr));
	return CYCLE;
}

/*
	Read an integer and put it to B
*/
uint64_t GTUOS::sysReadB( CPU8080& cpu)
{
	uint16_t num;
	cin >> num;
	cpu.state->b = num;
	
	return CYCLE;
}

/*
	Read an integer and put it to memory address pointed
	by B and C
*/
uint64_t GTUOS::sysReadMem( CPU8080& cpu)
{
	int readVal;
	uint16_t realValue;

	cin >> readVal;
	realValue = (uint16_t) readVal;

	if (readVal < 0 || readVal > 65535)
		cout << "Error! Bigger than 16 bits not accepted" << endl;
	else
	{
		uint8_t leastSign = (uint8_t) realValue;
		uint8_t mostSign = (uint8_t) (realValue >> 8);
		cpu.state->c = leastSign;
		cpu.state->b = mostSign;
	}
	return CYCLE;
}

/*
	Print the null terminated string
	whose start address is stored cin B and C
*/
uint64_t GTUOS::sysPrintStr( CPU8080& cpu){
	uint16_t fileNameAddr;
	fileNameAddr = ((uint16_t)cpu.state->b << 8) | cpu.state->c;
	
	while(cpu.memory->at(fileNameAddr) != (uint8_t) 0)
	{
		cout << cpu.memory->at(fileNameAddr);
		fileNameAddr++;
	}
	return CYCLE;
}
/*
	Read string and put it to memory address
	pointed by B and C
*/
uint64_t GTUOS::sysReadStr( CPU8080& cpu)
{
	uint16_t fileNameAddr;
	string str;
	cin >> str;
	fileNameAddr = (((uint16_t)cpu.state->b) << 8) | cpu.state->c;
	for(int i = 0 ; i < (signed) str.length() ; ++i)
	{
		cpu.memory->at(fileNameAddr) = str[i];
		fileNameAddr++;
	}
	cpu.memory->at(fileNameAddr) = (uint8_t)'\0'; 
	return CYCLE;
}
