execs := task1

CC := gcc 
CFLAGS := -O3  
LDFLAGS := 
DEBUG := -g -fsanitize=address -lefence -Wall -Wextra #$(" ") #

all: $(execs)

task1: task1.c task1_funcs.o
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(DEBUG)

task1_funcs.o: task1_funcs.c
	$(CC) $(CFLAGS) -c $< $(LDFLAGS) $(DEBUG) 

.PHONY: clean
clean:
	rm -f *.o $(execs)

