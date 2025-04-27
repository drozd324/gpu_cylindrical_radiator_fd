#include <sys/time.h>
#include <stddef.h>
#include <time.h>
#include <math.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
	void print_matrix(float* a, int m, int n);
	void init_matrix(float* matrix, int m, int n);
	void iterate(float* nextMatrix, float* previousMatrix, int m, int n);
	void calculate_avg_temp(float* matrix, int m, int n, float* thermometer);
	float max_diff(float* a, float* b, int m, int n);
}
#endif
