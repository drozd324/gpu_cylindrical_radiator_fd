#include "task2_funcs.h"

__global__ void init_matrix_GPU(float** matrix, int m, int n){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idx<m){
		if (idy==0){
			matrix[idx][0] = 0.98 * (float)((i+1)*(i+1)) / (float)(n*n); 
		}
	}
	
	if (idx<m){
		if ((1<=idy) && (idy<n)){
			matrix[idx][idy] = matrix[idx][0] * ( ((float)((m-idy)*(m-idy))) / ((float)(m*m)));	
		}
	}
}

__global__ void iterate_GPU(float** nextMatrix, float** previousMatrix, int m, int n){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idx<m){
		if ((2<=idy) && (idy<n-2)){
			nextMatrix[idx][idy] = ((1.60*previousMatrix[idx][idy-2]) + 
									(1.55*previousMatrix[idx][idy-1]) + 
									previousMatrix[idx][idy] + 
									(0.60*previousMatrix[idx][idy+1]) +
									(0.25*previousMatrix[idx][idy+2]));
			nextMatrix[idx][idy] /= (float)(5.0);
		}
	}
}

__global__ void calculate_avg_temp_GPU(float** matrix, int m, int n, float* thermometer){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idx<m){
		float* loc_therm = calloc(n, sizeof(float));
		if (idy<n){
			atomicAdd(&(thermometer[idx]), matrix[idx][idy]);	
		}
		thermometer[i] /= m;
	}
}

