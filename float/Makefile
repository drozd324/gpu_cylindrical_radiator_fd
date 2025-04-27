CC = gcc
NVCC = nvcc
DEBUG =  #-g # -Wextra -W -lefence #-Wall 
DEBUGNV = #-g -G --target-processes 
NVCCFLAGS = -O4# -funroll-loops --use_fast_math --compiler-options  -arch=sm_75

EXECS = task1 task2 

all: $(EXECS)

task1: task1.c task1_funcs.o
	    $(CC) $(NVCCFLAGS) -o $@ $^ $(DEBUG) $(DEBUGNV)

task1_funcs.o: task1_funcs.c
	    $(CC) $(NVCCFLAGS) -c $< $(DEBUG) $(DEBUGNV)

task2: task2.cu task2_funcs.o task1_funcs.o	
	    $(NVCC) $(NVCCFLAGS) -o $@ $^ $(DEBUG) $(DEBUGNV)

task2_funcs.o: task2_funcs.cu
	    $(NVCC) $(NVCCFLAGS) -c $< $(DEBUG) $(DEBUGNV)

clean:
	rm *.o $(EXECS)
