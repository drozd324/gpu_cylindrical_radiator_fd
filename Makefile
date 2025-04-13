execs := task1

CC := gcc 
CFLAGS := -O3  
LDFLAGS := 
DEBUG := -g -fsanitize=address -lefence -Wall -Wextra #$(" ") #

all: $(execs)

task1: task1.c
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(DEBUG)

#conj_grad.o: conj_grad.c
#	$(CC) $(CFLAGS) -c $< $(LDFLAGS) $(DEBUG) 

.PHONY: clean
clean:
	rm -f *.o $(execs)

