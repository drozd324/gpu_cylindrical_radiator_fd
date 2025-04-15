__global__ void init_matrix_GPU(float* matrix, int m, int n);
__global__ void iterate_GPU(float* nextMatrix, float* previousMatrix, int m, int n);
__global__ void calculate_avg_temp_GPU(float* matrix, int m, int n, float* thermometer);

