#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void alloc_matrix(float** matrix, int m, int n);
void free_matrix(float** matrix, int m);
void init_matrix(float** matrix, int m, int n);
void iterate(float** nextMatrix, float** previousMatrix, int m, int n);
void calculate_avg_temp(float** matrix, int m, int n, float* thermometer);
