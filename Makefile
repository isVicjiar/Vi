CC = iverilog

FLAGS = -Wall -Winfloop

all: modules

modules: *.v
	$(CC) $(FLAGS) -o * *.v
