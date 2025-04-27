#include "task1_funcs.h"

void print_matrix(double* a, int m, int n){
	for (int i=0; i<m; i++){
		for (int j=0; j<n; j++){
			printf("%f ", a[i*n + j]);
		}
		printf("\n");
	}
}


void init_matrix(double* matrix, int m, int n){
	for (int i=0; i<m; i++){
		matrix[i*n + 0] = 0.98 * (double)((i+1)*(i+1)) / (double)(n*n); 
	}
	
	for (int i=0; i<m; i++){	
		for (int j=1; j<n; j++){	
			matrix[i*n + j] = matrix[i*n + 0] * ( ((double)((m-j)*(m-j))) / ((double)(m*m)));	
		}
	}
}

void iterate(double* nextMatrix, double* previousMatrix, int m, int n){
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
			nextMatrix[i*n + j] /= (double)(5.0);
		}
	}
}

void calculate_avg_temp(double* matrix, int m, int n, double* thermometer){
	for (int i=0; i<m; i++){	
		for (int j=0; j<n; j++){	
			thermometer[i] += matrix[i*n + j];
		}
		thermometer[i] /= (double)n;
	}
}

double max_diff(double* a, double* b, int m, int n){
	double diff;
	double max_diff = 0;

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
