#include <sys/time.h>
#include <stddef.h>
#include <time.h>
#include <math.h>
#include <stdio.h>

#ifdef __cplusplus
extern "C" {
	void print_matrix(double* a, int m, int n);
	void init_matrix(double* matrix, int m, int n);
	void iterate(double* nextMatrix, double* previousMatrix, int m, int n);
	void calculate_avg_temp(double* matrix, int m, int n, double* thermometer);
	double max_diff(double* a, double* b, int m, int n);
}
#endif
