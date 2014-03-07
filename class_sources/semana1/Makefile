CC = gcc
GG = g++
CFLAGS = -I /usr/include/pccts/

all: clean example0 example1

example0: example0.c
		$(CC) -o example0 example0.c scan.c err.c $(CFLAGS)
example0.c: example0.g
		antlr example0.g
		dlg parser.dlg scan.c
example1: example1.c
		$(GG) -o example1 example1.c scan.c err.c $(CFLAGS)
example1.c: example1.g
		antlr -gt example1.g
		dlg -ci parser.dlg scan.c
clean:
		rm -f *.o *.c example1 example0 example parser.dlg tokens.h mode.h scan.c err.c
