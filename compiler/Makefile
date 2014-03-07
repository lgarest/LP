CC = gcc
GG = g++
CFLAGS = -I /usr/include/pccts/

all: clean compres

compres: compres.c
		$(GG) -o compres compres.c scan.c err.c $(CFLAGS)
compres.c: compres.g
		antlr -gt compres.g
		dlg -ci parser.dlg scan.c
derp:
		antlr -gt compres.g
		dlg -ci parser.dlg scan.c
clean:
		rm -f *.o *.c compres parser.dlg tokens.h mode.h scan.c err.c
