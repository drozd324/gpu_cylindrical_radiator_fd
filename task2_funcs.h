typedef float textureType;  // How to use a float type

__global__ void copySurface(cudaSurfaceObject_t inputSurface, cudaSurfaceObject_t outputSurface, int width, int height);
__global__ void transformSurfaceToGlobal(cudaSurfaceObject_t surface, float* gpu_data, int width, int height);
__global__ void transformGlobalToSurface(float* gpu_data, cudaSurfaceObject_t surface, int width, int height);
__global__ void iterate_GPU_surface(cudaSurfaceObject_t nextSurface, cudaSurfaceObject_t prevSurface, int m, int n);

__global__ void iterate_GPU_global(float* nextMatrix, float* previousMatrix, int m, int n);
__global__ void init_matrix_GPU_global(float* matrix, int m, int n);

__global__ void calculate_avg_temp_GPU(float* matrix, int m, int n, float* thermometer);
