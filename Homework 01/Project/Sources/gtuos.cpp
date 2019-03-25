#include "8080emuCPP.h"
#include "gtuos.h"


GTUOS::GTUOS() : output("output.txt"), input("input.txt")
{}

GTUOS::~GTUOS()
{
	input.close();
	output.close();
}

uint64_t GTUOS::handleCall(const CPU8080 & cpu){
	switch(cpu.state->a)
	{
	case 4:
		output << (int) cpu.state->b << std::flush;
		break;
	case 3:
		output << (int) cpu.memory->at((cpu.state->b << 8) | cpu.state->c) << std::flush;
		break;
	case 7:
		int temp;
		input >> temp;
		cpu.state->b = temp;
		break;
	case 2:
	{
		int temp;
		input >> temp;
		cpu.memory->at((cpu.state->b << 8) | cpu.state->c) = temp;
	}
		break;
	case 1:
		{
			uint16_t current_point = (cpu.state->b << 8) | cpu.state->c;
			for(uint8_t to_print = cpu.memory->at(current_point);
				to_print != 0;
				to_print = cpu.memory->at(++current_point))
			{
				output << (char) to_print;
			}
			output << std::flush;
		}
		break;
	case 8:
		{
			uint16_t current_point = (cpu.state->b << 8) | cpu.state->c;
			char in;
			do
			{
				input >> in;
				cpu.memory->at(current_point++) = in;
			} while(!input.eof());
		}
		break;
	default:
		std::cerr	<< "\n Unimplemented OS call" << std::endl;
		throw -1;
	}
	return 0;
}

