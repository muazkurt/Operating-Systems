exe: ./Binaries/8080emu.o ./Binaries/gtuos.o ./Binaries/main.o
	g++ -o exe ./Binaries/8080emu.o ./Binaries/gtuos.o ./Binaries/main.o

./Binaries/8080emu.o: ./Sources/8080emu.cpp
	g++ -c ./Sources/8080emu.cpp -o ./Binaries/8080emu.o

./Binaries/gtuos.o: ./Sources/gtuos.cpp
	g++ -c ./Sources/gtuos.cpp -o ./Binaries/gtuos.o

./Binaries/main.o: ./Sources/main.cpp
	g++ -c ./Sources/main.cpp -o ./Binaries/main.o

clear:
	rm ./Binaries/* ./exe
