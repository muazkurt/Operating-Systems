#ifndef H_GTUOS
#define H_GTUOS

#include "8080emuCPP.h"
#include <iostream>
#include <fstream>


class GTUOS{
	public:
		GTUOS();
		~GTUOS();
		uint64_t handleCall(CPU8080 & cpu);
	private:
		std::ofstream output;
		std::ifstream input;
};

#endif
