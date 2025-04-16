CC = gcc
NVCC = nvcc
DEBUG = $(" ") # -g -fsanitize=address -Wall -Wextra -lefence #$(" ") #
DEBUGNV = #-g -G #--target-processes # -Wall -W #$(" ") #
NVCCFLAGS = -O4 --use_fast_math --compiler-options -funroll-loops -arch=sm_75

all: task1 task2

task1: task1.c task1_funcs.o
	    $(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(DEBUG)

task1_funcs.o: task1_funcs.c
	    $(CC) $(CFLAGS) -c $< $(LDFLAGS) $(DEBUG)

task2: task2.cu task2_funcs.o task1_funcs.o	
	    $(NVCC) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(DEBUG)

task2_funcs.o: task2_funcs.cu
	    $(NVCC) $(CFLAGS) -c $< $(LDFLAGS) $(DEBUG)

clean:
	rm task1 task2 *.o
