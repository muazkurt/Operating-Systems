#include <iostream>
#include "8080emuCPP.h"
#include "gtuos.h"
#include "memory.h"
#include <unistd.h>
	// This is just a sample main function, you should rewrite this file to handle problems 
	// with new multitasking and virtual memory additions.
int main (int argc, char**argv)
{
	if (argc != 3){
		std::cerr << "Usage: prog exeFile debugOption\n";
		exit(1); 
	}
	int DEBUG = atoi(argv[2]);

	unsigned int microseconds = 200000;

	Memory mem(65535);
	CPU8080 theCPU(&mem);
	GTUOS	theOS;

	theCPU.ReadFileIntoMemoryAt(argv[1], 0x0000);
	int i = 0;
	do	
	{
		theCPU.Emulate8080p(DEBUG);
		if(theCPU.isSystemCall())
			theOS.handleCall(theCPU);
		++i;
	//	usleep(microseconds);
	}	while (i < 40000 && !theCPU.isHalted())
;
	return 0;
}

