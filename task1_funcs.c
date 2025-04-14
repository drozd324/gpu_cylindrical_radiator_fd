#include "task1_funcs.h"

void init_matrix(float** matrix, int m, int n){
	for (int i=0; i<m; i++){
		matrix[i][0] = 0.98 * (float)((i+1)*(i+1)) / (float)(n*n); //(so the values range between 0.98/(float)(n*n) and 0.98)
	}
	
	for (int i=0; i<m; i++){	
		for (int j=1; j<n; j++){	
			matrix[i][j] = matrix[i][0] * ( ((float)((m-j)*(m-j))) / ((float)(m*m)));	
		}
	}
}

void iterate(float** nextMatrix, float** previousMatrix, int m, int n){
	for (int i=0; i<m; i++){	
		for (int j=2; j<n-2; j++){
			nextMatrix[i][j] = ((1.60*previousMatrix[i][j-2]) + 
								(1.55*previousMatrix[i][j-1]) + 
								previousMatrix[i][j] + 
								(0.60*previousMatrix[i][j+1]) +
								(0.25*previousMatrix[i][j+2]));
			nextMatrix[i][j] /= (float)(5.0);
		}
	}
}

void calculate_avg_temp(float** matrix, int m, int n, float* thermometer){
	for (int i=0; i<m; i++){	
		for (int j=0; j<n; j++){	
			thermometer[i] += matrix[i][j];
		}
		thermometer[i] /= m;
	}
}

