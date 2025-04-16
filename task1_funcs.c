#include "task1_funcs.h"

void init_matrix(float* matrix, int m, int n){
	for (int i=0; i<m; i++){
		matrix[i*n + 0] = 0.98 * (float)((i+1)*(i+1)) / (float)(n*n); //(so the values range between 0.98/(float)(n*n) and 0.98)
	}
	
	for (int i=0; i<m; i++){	
		for (int j=1; j<n; j++){	
			matrix[i*n + j] = matrix[i*n + 0] * ( ((float)((m-j)*(m-j))) / ((float)(m*m)));	
		}
	}
}

void iterate(float* nextMatrix, float* previousMatrix, int m, int n){
	for (int i=0; i<m; i++){	
		for (int j=2; j<n-2; j++){
			nextMatrix[i*n + j] = ((1.60*previousMatrix[i*n + j-2]) + 
								(1.55*previousMatrix[i*n + j-1]) + 
								previousMatrix[i*n + j] + 
								(0.60*previousMatrix[i*n + j+1]) +
								(0.25*previousMatrix[i*n + j+2]));
			nextMatrix[i*n + j] /= (float)(5.0);
		}
	}
}

void calculate_avg_temp(float* matrix, int m, int n, float* thermometer){
	for (int i=0; i<m; i++){	
		for (int j=0; j<n; j++){	
			thermometer[i] += matrix[i*n + j];
		}
		thermometer[i] /= m;
	}
}

	
/**
 * @brief Function to measure time
 * 
 * @param[out] Actual time in seconds
 */
extern float walltime(){
	struct timeval t;
	gettimeofday(&t, NULL);	
	float wtime = (float)(t.tv_sec + t.tv_usec*1e-6);
	return wtime*1e-3;
}
	
