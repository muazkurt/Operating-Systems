#ifndef H_GTUOS
#define H_GTUOS

#include "8080emuCPP.h"
#include <iostream>
#include <fstream>



class GTUOS{
	public:
		GTUOS();
		~GTUOS();
		uint64_t handleCall(const CPU8080 & cpu);
	private:
		void	print_b(uint8_t decimal);
		std::ofstream output;
		std::ifstream input;
};

#endif
