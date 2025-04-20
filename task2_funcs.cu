#include "task2_funcs.h"

__global__ void copySurface(cudaSurfaceObject_t inputSurface, cudaSurfaceObject_t outputSurface, int m, int n) {
	unsigned int idx = blockIdx.x * blockDim.x + threadIdx.x;
	unsigned int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if (idx<n && idy<m) {
		float data;
		surf2Dread(&data, inputSurface, idx*4, idy);
		surf2Dwrite(data, outputSurface, idx*4, idy);
	}
}

__global__ void transformSurfaceToGlobal(cudaSurfaceObject_t surface, float* gpu_data, int m, int n) {
	unsigned int idx = blockIdx.x*blockDim.x + threadIdx.x;
	unsigned int idy = blockIdx.y*blockDim.y + threadIdx.y;

	if ( (idx < n) && (idy < m) ) {
		surf2Dread(&(gpu_data[idy*n+idx]), surface, idx*4 , idy);
    }
}

__global__ void transformGlobalToSurface(float* gpu_data, cudaSurfaceObject_t surface, int m, int n) {
	unsigned int idx = blockIdx.x*blockDim.x + threadIdx.x;
	unsigned int idy = blockIdx.y*blockDim.y + threadIdx.y;

	if ( (idx < n) && (idy < m) ) {
		surf2Dwrite(gpu_data[idy*n + idx], surface, idx*4, idy);
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

	float nextSurf_j;

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
		surf2Dread(&prevSurf_j_minus2, prevSurface, idx*4, mod_j_minus2);
		surf2Dread(&prevSurf_j_minus1, prevSurface, idx*4, mod_j_minus1);
		surf2Dread(&prevSurf_j       , prevSurface, idx*4, idy         );
		surf2Dread(&prevSurf_j_plus1 , prevSurface, idx*4, mod_j_plus1 );
		surf2Dread(&prevSurf_j_plus2 , prevSurface, idx*4, mod_j_plus2 );

		// compute
		nextSurf_j = ((1.60*prevSurf_j_minus2) + (1.55*prevSurf_j_minus1) + prevSurf_j + (0.60*prevSurf_j_plus1) + (0.25*prevSurf_j_plus2)) / ((float)(5.0));
		
		// write
		surf2Dwrite(nextSurf_j, nextSurface, idx*4, idy);
	}
}

__global__ void calculate_avg_temp_GPU(float* matrix, int m, int n, float* thermometer){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if ((idx<m) && (idy<n)){
		atomicAdd(&(thermometer[idx]), matrix[idx*n + idy]);
	}

	//__syncthreads();

	if ((idx<m) && (idy == 0)){
		thermometer[idx] /= n;
	}
}


__global__ void iterate_GPU_global(float* nextMatrix, float* previousMatrix, int m, int n){
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
		nextMatrix[idy*n + idy] /= (float)(5.0);
	}
}

__global__ void init_matrix_GPU_global(float* matrix, int m, int n){
	int idx = blockIdx.x * blockDim.x + threadIdx.x;
	int idy = blockIdx.y * blockDim.y + threadIdx.y;

	if ((idx<m) && (idy==0)){
		matrix[idx*n + 0] = 0.98 * (float)((idx+1)*(idx+1)) / (float)(n*n); 
	}
	
	if ((idx<m) &&  ((1<=idy) && (idy<n))){
		matrix[idx*n + idy] = ( 0.98 * (float)((idx+1)*(idx+1)) / (float)(n*n) )
								* ( ((float)((m-idy)*(m-idy))) / ((float)(m*m)));	
	}
}

// wont work
//__global__ void iterate_GPU_texture(cudaTextureObject_t nextTexture, cudaTextureObject_t prevTexture, int m, int n){
//	int idx = blockIdx.x * blockDim.x + threadIdx.x;
//	int idy = blockIdx.y * blockDim.y + threadIdx.y;
//
//	if ((idx<n) && (idy<m)){
//		// compute
//		tex2D<textureType>(nextTexture, idx, idy) = ( (1.60*tex2D<textureType>(prevTexture, idx, idy-2)  + 
//														(1.55*tex2D<textureType>(prevTexture, idx, idy-1)) +
//														tex2D<textureType>(prevTexture, idx, idy)          +
//														(0.60*tex2D<textureType>(prevTexture, idx, idy+1)) +
//														(0.25*tex2D<textureType>(prevTexture, idx, idy+2)) ) 
//														/ ((float)(5.0));
//	}
//}
