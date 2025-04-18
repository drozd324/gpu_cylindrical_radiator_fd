#include "task2_funcs.h"

__global__ void copySurface(cudaSurfaceObject_t inputSurface, cudaSurfaceObject_t outputSurface, int width, int height) {
	unsigned int idx = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idx<width && idy<height) {
		float data;
		surf2Dread(&data, inputSurface, idx * 4, idy);
		surf2Dwrite(data, outputSurface, idx * 4, idy);
	}
}

__global__ void transformSurfaceToGlobal(cudaSurfaceObject_t surface, float* gpu_data, int width, int height) {
	unsigned int idx = blockIdx.x*blockDim.x + threadIdx.x;
	unsigned int idy = blockIdx.y*blockDim.y + threadIdx.y;

	if ( (idx < width) && (idy < height) ) {
		surf2Dread(&(gpu_data[idy*width+idx]), surface, idx*4 , idy);
    }
}

__global__ void transformGlobalToSurface(float* gpu_data, cudaSurfaceObject_t surface, int width, int height) {
	unsigned int idx = blockIdx.x*blockDim.x + threadIdx.x;
	unsigned int idy = blockIdx.y*blockDim.y + threadIdx.y;

	if ( (idx < width) && (idy < height) ) {
		surf2Dwrite(gpu_data[idy*width + idx], surface, idx * 4, idy);
    }
}

__global__ void iterate_GPU(cudaSurfaceObject_t nextSurface, cudaSurfaceObject_t prevSurface, int m, int n){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	float prevSurf_j_minus2; 
	float prevSurf_j_minus1;
	float prevSurf_j;
	float prevSurf_j_plus1;
	float prevSurf_j_plus2;

	float nextSurf_j;

	int mod_j_minus2;
	int mod_j_minus1;
	int mod_j_plus1;
	int mod_j_plus2;


	if (idx<m){
		if (idy<n){

			mod_j_minus2 = (idy - 2 + m) % m;
			mod_j_minus1 = (idy - 1 + m) % m;
			mod_j_plus1 = (idy + 1) % m;
			mod_j_plus2 = (idy + 2) % m;

			// read
			surf2Dread(&prevSurf_j_minus2, prevSurface, idx*4, mod_j_minus2);
			surf2Dread(&prevSurf_j_minus1, prevSurface, idx*4, mod_j_minus1);
			surf2Dread(&prevSurf_j       , prevSurface, idx*4, idy         );
			surf2Dread(&prevSurf_j_plus1 , prevSurface, idx*4, mod_j_plus1 );
			surf2Dread(&prevSurf_j_plus2 , prevSurface, idx*4, mod_j_plus2 );

			// compute
			nextSurf_j = ((1.60*prevSurf_j_minus2) + (1.55*prevSurf_j_minus1) + prevSurf_j + (0.60*prevSurf_j_plus1) + (0.25*prevSurf_j_plus2)) / ((float)(5.0));
			
			// write
			surf2Dwrite(nextSurf_j, nextSurface, idx * 4, idy);
		}
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

	//__syncthreads();

	if (idx<m){
		if (idy == 0){
			thermometer[idx] /= m;
		}
	}
}

