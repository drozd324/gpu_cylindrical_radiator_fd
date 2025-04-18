#include "task2_funcs.h"

__global__ void init_matrix_GPU(float* matrix, int m, int n){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idx<m){
		if (idy==0){
			matrix[idx*n + 0] = 0.98 * (float)((idx+1)*(idx+1)) / (float)(n*n); 
		}
	}
	
	if (idx<m){
		if ((1<=idy) && (idy<n)){
			matrix[idx*n + idy] = ( 0.98 * (float)((idx+1)*(idx+1)) / (float)(n*n) )
									* ( ((float)((m-idy)*(m-idy))) / ((float)(m*m)));	
		}
	}
}

//__global__ void iterate_GPU(float* nextMatrix, float* previousMatrix, int m, int n){
__global__ void iterate_GPU(float* nextMatrix, float* previousMatrix, int m, int n){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idx<m){
		if ((2<=idy) && (idy<n-2)){
			nextMatrix[idx*n + idy] = ((1.60*previousMatrix[idx*n + idy-2]) + 
									(1.55*previousMatrix[idx*n + idy-1]) + 
									previousMatrix[idx*n + idy] + 
									(0.60*previousMatrix[idx*n + idy+1]) +
									(0.25*previousMatrix[idx*n + idy+2]));
			nextMatrix[idx*n + idy] /= (float)(5.0);
		}
	}
}



__global__ void iterate_GPU_old(float* nextMatrix, float* previousMatrix, int m, int n){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	//__syncthreads();

	if (idx<m){
		if ((2<=idy) && (idy<n-2)){
			nextMatrix[idx*n + idy] = ((1.60*previousMatrix[idx*n + idy-2]) + 
									(1.55*previousMatrix[idx*n + idy-1]) + 
									previousMatrix[idx*n + idy] + 
									(0.60*previousMatrix[idx*n + idy+1]) +
									(0.25*previousMatrix[idx*n + idy+2]));
			nextMatrix[idx*n + idy] /= (float)(5.0);
		}
	}


__global__ void calculate_avg_temp_GPU(float* matrix, int m, int n, float* thermometer){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;


	if (idx<m){
		if (idy<n){
			atomicAdd(&(thermometer[idx]), matrix[idx*n + idy]);
		}
	}

	__syncthreads();

	if (idx<m){
		if (idy == 0){
			thermometer[idx] /= m;
		}
	}
}

