typedef double textureType;  // How to use a double type

__global__ void copySurface(cudaSurfaceObject_t inputSurface, cudaSurfaceObject_t outputSurface, int width, int height);
__global__ void transformSurfaceToGlobal(cudaSurfaceObject_t surface, double* gpu_data, int width, int height);
__global__ void transformGlobalToSurface(double* gpu_data, cudaSurfaceObject_t surface, int width, int height);
__global__ void iterate_GPU_surface(cudaSurfaceObject_t nextSurface, cudaSurfaceObject_t prevSurface, int m, int n);

__global__ void iterate_GPU_global(double* nextMatrix, double* previousMatrix, int m, int n);
__global__ void init_matrix_GPU_global(double* matrix, int m, int n);

__global__ void calculate_avg_temp_GPU(double* matrix, int m, int n, double* thermometer);


__global__ void sum_rows_gpu(int m, int n, double* a, double* v);
