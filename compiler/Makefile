CC = gcc
GG = g++
CFLAGS = -I /usr/include/pccts/

all: clean groceries

groceries: groceries.c
		$(GG) -o groceries.exe groceries.c scan.c err.c $(CFLAGS)
groceries.c: groceries.g
		antlr -gt groceries.g
		dlg -ci parser.dlg scan.c
clean:
		rm -f *.o *.c groceries.exe parser.dlg tokens.h mode.h scan.c err.c
