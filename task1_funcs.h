#include <sys/time.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
	void init_matrix(float* matrix, int m, int n);
	void iterate(float* nextMatrix, float* previousMatrix, int m, int n);
	void calculate_avg_temp(float* matrix, int m, int n, float* thermometer);
	double walltime();
}
#endif
