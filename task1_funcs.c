#include "task1_funcs.h"

void init_matrix(float* matrix, int m, int n){
	for (int i=0; i<m; i++){
		matrix[i*n + 0] = 0.98 * (float)((i+1)*(i+1)) / (float)(n*n); 
	}
	
	for (int i=0; i<m; i++){	
		for (int j=1; j<n; j++){	
			matrix[i*n + j] = matrix[i*n + 0] * ( ((float)((m-j)*(m-j))) / ((float)(m*m)));	
		}
	}
}

void iterate(float* nextMatrix, float* previousMatrix, int m, int n){
	int mod_j_minus2;
	int mod_j_minus1;
	int mod_j_plus1;
	int mod_j_plus2;

	for (int i=0; i<m; i++){	
		for (int j=0; j<n; j++){

			mod_j_minus2 = (j - 2 + n) % n;
			mod_j_minus1 = (j - 1 + n) % n;
			mod_j_plus1 = (j + 1) % n;
			mod_j_plus2 = (j + 2) % n;
 

			nextMatrix[i*n + j] = ((1.60*previousMatrix[i*n + mod_j_minus2]) + 
								(1.55*previousMatrix[i*n + mod_j_minus1]) + 
								previousMatrix[i*n + j] + 
								(0.60*previousMatrix[i*n + mod_j_plus1]) +
								(0.25*previousMatrix[i*n + mod_j_plus2]));
			nextMatrix[i*n + j] /= (float)(5.0);
		}
	}
}

void calculate_avg_temp(float* matrix, int m, int n, float* thermometer){
	for (int i=0; i<m; i++){	
		for (int j=0; j<n; j++){	
			thermometer[i] += matrix[i*n + j];
		}
		thermometer[i] /= n;
	}
}

float max_diff(float* a, float* b, int m, int n){
	float diff;
	float max_diff = 0;

	for (int i=0; i<m; i++){
		for (int j=0; j<n; j++){
			diff = fabs(a[i*n + j] - b[i*n + j]);
			if (max_diff < diff){
				max_diff = diff;
			}
		}
	}

	return max_diff;
}
