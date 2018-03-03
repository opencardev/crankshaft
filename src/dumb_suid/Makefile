CC=gcc
CFLAGS=-I. -O3
PROG=dumb_suid

all: $(PROG)

$(PROG): $(PROG).c
	$(CC) $(CFLAGS) -o $(PROG) $(PROG).c

.PHONY: clean

clean:
	rm $(PROG)
