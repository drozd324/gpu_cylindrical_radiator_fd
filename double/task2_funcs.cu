#include "task2_funcs.h"

//__global__ void copySurface(cudaSurfaceObject_t inputSurface, cudaSurfaceObject_t outputSurface, int m, int n) {
//	unsigned int idx = blockIdx.x * blockDim.x + threadIdx.x;
//	unsigned int idy = blockIdx.y * blockDim.y + threadIdx.y;
//
//	if (idx<n && idy<m) {
//		double data;
//		surf2Dread(&data, inputSurface, idx*8, idy);
//		surf2Dwrite(data, outputSurface, idx*8, idy);
//	}
//}

__global__ void transformSurfaceToGlobal(cudaSurfaceObject_t surface, double* gpu_data, int m, int n) {
	unsigned int idx = blockIdx.x*blockDim.x + threadIdx.x;
	unsigned int idy = blockIdx.y*blockDim.y + threadIdx.y;

	if ((idx<m) && (idy<n)) {
		float temp = 0.0f;
		surf2Dread(&temp, surface, idx * 8, idy);  
		gpu_data[idx * n + idy] = (double) temp;

		//surf2Dread(&(gpu_data[idx*n + idy]), surface, idx*8 , idy);
    }
}

__global__ void transformGlobalToSurface(double* gpu_data, cudaSurfaceObject_t surface, int m, int n) {
	unsigned int idx = blockIdx.x*blockDim.x + threadIdx.x;
	unsigned int idy = blockIdx.y*blockDim.y + threadIdx.y;

	if ((idx<m) && (idy<n)) {
		surf2Dwrite((float)gpu_data[idx*n + idy], surface, idx*8, idy);
    }
}

__global__ void iterate_GPU_surface(cudaSurfaceObject_t nextSurface, cudaSurfaceObject_t prevSurface, int m, int n){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	float prevSurf_j_minus2; 
	float prevSurf_j_minus1;
	float prevSurf_j;
	float prevSurf_j_plus1;
	float prevSurf_j_plus2;

	double nextSurf_j;

	int mod_j_minus2;
	int mod_j_minus1;
	int mod_j_plus1;
	int mod_j_plus2;


	if ((idx<m) && (idy<n)){

		mod_j_minus2 = (idy - 2 + n) % n;
		mod_j_minus1 = (idy - 1 + n) % n;
		mod_j_plus1 = (idy + 1) % n;
		mod_j_plus2 = (idy + 2) % n;

		// read
		surf2Dread(&prevSurf_j_minus2, prevSurface, idx*8, mod_j_minus2);
		surf2Dread(&prevSurf_j_minus1, prevSurface, idx*8, mod_j_minus1);
		surf2Dread(&prevSurf_j       , prevSurface, idx*8, idy         );
		surf2Dread(&prevSurf_j_plus1 , prevSurface, idx*8, mod_j_plus1 );
		surf2Dread(&prevSurf_j_plus2 , prevSurface, idx*8, mod_j_plus2 );

		// compute
		nextSurf_j = ((1.60*(double)prevSurf_j_minus2) + (1.55*(double)prevSurf_j_minus1) + (double)prevSurf_j + (0.60*(double)prevSurf_j_plus1) + (0.25*(double)prevSurf_j_plus2)) / ((double)(5.0));
		
		// write
		surf2Dwrite((float)nextSurf_j, nextSurface, idx*8, idy);
	}
}

__global__ void calculate_avg_temp_GPU(double* matrix, int m, int n, double* thermometer){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if ((idx<m) && (idy<n)){
		atomicAdd(&(thermometer[idx]), matrix[idx*n + idy] / (double)n);
	}
}


// iteration function for global memory data
__global__ void iterate_GPU_global(double* nextMatrix, double* previousMatrix, int m, int n){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	int mod_j_minus2;
	int mod_j_minus1;
	int mod_j_plus1;
	int mod_j_plus2;

	if ((idx<m) && (idy<n)){
		mod_j_minus2 = (idy - 2 + n) % n;
		mod_j_minus1 = (idy - 1 + n) % n;
		mod_j_plus1 = (idy + 1) % n;
		mod_j_plus2 = (idy + 2) % n;


		nextMatrix[idx*n + idy] = ((1.60*previousMatrix[idx*n + mod_j_minus2]) + 
									(1.55*previousMatrix[idx*n + mod_j_minus1]) + 
									previousMatrix[idx*n + idy] + 
									(0.60*previousMatrix[idx*n + mod_j_plus1]) +
									(0.25*previousMatrix[idx*n + mod_j_plus2]));
		nextMatrix[idy*n + idy] /= (double)(5.0);
	}
}


// hw1 reduce code

__global__ void sum_rows_gpu(int m, int n, double* a, double* v){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;

	if (idx < m){
        v[idx] = 0;

       	for (int j=0; j<n; j++){ 
           	v[idx] += (0 < (a[idx*n + j])) ? a[idx*n + j] : -a[idx*n + j];
       	}
		
		v[idx] = v[idx] / n;     // added the divide in order for this function to copmute the average
	}
}

// hw1 reduce code end
