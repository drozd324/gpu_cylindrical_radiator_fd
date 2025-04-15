#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "task1_funcs.h"
#include "task2_funcs.h"

int main(int argc, char *argv[]) {

	int option;
	int m = 32;
	int n = 32;
	int iter = 10;
	int calc_cpu = 0;
	int calc_avg_temp = 0;
	int show_timings_next_to_eachother = 0;

    while ((option = getopt(argc, argv, "m:n:p:act")) != -1) {
        switch (option) {
            case 'm': // set num cols m of matrix
	            m = atoi(optarg);
				break;
			case 'n': // set num rows n of matrix
				n = atoi(optarg);
				break;
			case 'p': // set iterations
				iter = atoi(optarg);
				break;
			case 'a': // sets caclulation of average temperature for each row
				calc_avg_temp = 1;
				break;
			case 'c': // caclulates cpu version of algorithm
				calc_cpu = 1;
				break;
			case 't': // caclulates cpu version of algorithm
				show_timings_next_to_eachother = 1;
				calc_avg_temp = 1;
				break;
        }
    }

	
	// GPU Calculation //
	//=================================================================//

	int N = n;
	int M = m;
	int block_size = 4;
	dim3 dimBlock (block_size, block_size);
	dim3 dimGrid ( (N/dimBlock.x) + (!(N%dimBlock.x)?0:1),(M/dimBlock.y) + (!(M%dimBlock.y)?0:1) );
		
	if (( (n*m) % block_size) != 0){
		fprintf(stderr, "ERROR: block size (number of threads per block) doesnt divide the total size of the matrix\n");
		return 1;
	}

	//cuda timings
	cudaEvent_t start, finish;
	cudaEventCreate(&start);
	cudaEventCreate(&finish);
	float elapsedTime;

	float time_allocating;
	float time_transfering_to_gpu;
	float time_compute_gpu;
	float time_calc_averages;
	float time_transfering_to_cpu;

	// allocalte matrices a_h, b_h on host
	float* a_h;
	float* b_h;
	a_h = (float*) malloc(m*n * sizeof(float));
	b_h = (float*) malloc(m*n * sizeof(float));
	
	// alloc on device
	cudaEventRecord(start, 0);
	float* a_d;
	float* b_d;
	cudaMalloc((void**)&a_d, m*n * sizeof(float));
	cudaMalloc((void**)&b_d, m*n * sizeof(float));
	cudaEventRecord(finish, 0);

	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time allocating on GPU = %f\n", elapsedTime);
	time_allocating = elapsedTime;

	cudaEventRecord(start, 0);
	init_matrix_GPU<<<dimGrid, dimBlock>>>(a_d, m, n);
	init_matrix_GPU<<<dimGrid, dimBlock>>>(b_d, m, n);
	cudaEventRecord(finish, 0);
	
	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time initialising matrices on GPU = %f\n", elapsedTime);

	cudaEventRecord(start, 0);
	for (int i=0; i<iter; i++){
		iterate_GPU<<<dimGrid, dimBlock>>>(a_d, b_d, m, n);
		iterate_GPU<<<dimGrid, dimBlock>>>(b_d, a_d, m, n);
	}
	cudaEventRecord(finish, 0);
		
	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time for compute on GPU = %f\n", elapsedTime);
	time_compute_gpu = elapsedTime;

	if (calc_avg_temp == 1){
		float* thermometer_d;
		cudaMalloc((void**)&thermometer_d, m * sizeof(float));

		cudaEventRecord(start, 0);
		calculate_avg_temp_GPU<<<dimGrid, dimBlock>>>(a_d, m, n, thermometer_d);
		cudaEventRecord(finish, 0);

		cudaEventSynchronize(start);
		cudaEventSynchronize(finish);
		cudaEventElapsedTime(&elapsedTime, start, finish);
		printf("Time to calculate averages on GPU = %f\n", elapsedTime);	
		time_calc_averages = elapsedTime;

		cudaFree(thermometer_d);
	}	


	cudaEventRecord(start, 0);
	cudaMemcpy(a_h, a_d, m*n * sizeof(float), cudaMemcpyDeviceToHost);
	cudaMemcpy(b_h, b_d, m*n * sizeof(float), cudaMemcpyDeviceToHost);
	cudaEventRecord(finish, 0);
	
	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time to transfer to RAM = %f\n", elapsedTime);	
	time_transfering_to_cpu = elapsedTime;
	
	// free
	free(a_h);	
	free(b_h);	
	cudaFree(a_d);	
	cudaFree(b_d);	

	// end //
	//=================================================================//

	if (calc_cpu == 1){
			// allocalte matrices a, b

			float time_start, time_end;			
			float time_allocating;
			float time_transfering_to_gpu;
			float time_compute_gpu;
			float time_calc_averages;
			float time_transfering_to_cpu;
	
			time_start = walltime();
			// allocalte matrices a_h, b_h on host
			float* a;
			float* b;
			a = (float*) malloc(m*n * sizeof(float));
			b = (float*) malloc(m*n * sizeof(float));
			time_end = walltime();
			
			init_matrix(a, m, n);
			init_matrix(b, m, n);
			
			for (int i=0; i<iter; i++){
				iterate(a, b, m, n);
				iterate(b, a, m, n);
			}
				
			if (calc_avg_temp == 1){
				float* thermometer = (float*) calloc(m, sizeof(float));
				calculate_avg_temp(a, m, n, thermometer);
				free(thermometer);
			}	
			
			// free matrices a, b
			free(a);
			free(b);
	}

    return 0;
}
