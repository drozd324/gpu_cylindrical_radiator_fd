#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
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

	int block_size_x = 2; //threads per block
	int block_size_y = 2; //threads per block

    while ((option = getopt(argc, argv, "m:n:p:x:y:act")) != -1) {
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
			case 'x': // set block_size_x
				block_size_x = atoi(optarg);
				break;
			case 'y': // set block_size_y
				block_size_y = atoi(optarg);
				break;
			case 'a': // sets caclulation of average temperature for each row
				calc_avg_temp = 1;
				break;
			case 'c': // caclulates cpu version of algorithm
				calc_cpu = 1;
				break;
			case 't': // caclulates all timings
				show_timings_next_to_eachother = 1;
				calc_cpu = 1;
				calc_avg_temp = 1;
				break;
        }
    }

	
	// GPU Calculation //
	//=================================================================//
	printf("\n//======================================//\n");
	printf("              GPU Calculation               \n");
	printf("//======================================//\n\n");

	if ( ((n*m) % (block_size_x*block_size_y)) != 0){
		fprintf(stderr, "ERROR: block size (number of threads per block) doesnt divide the total size of the matrix\n");
		return 1;
	}

	int N = n;
	int M = m;
	dim3 dimBlock (block_size_x, block_size_y);
	dim3 dimGrid ( (N/dimBlock.x) + (!(N%dimBlock.x)?0:1),(M/dimBlock.y) + (!(M%dimBlock.y)?0:1) );
		
	//cuda timings
	cudaEvent_t start, finish;
	cudaEventCreate(&start);
	cudaEventCreate(&finish);
	float elapsedTime;

	float time_allocating;
	//float time_transfering_to_gpu;
	float time_compute;
	float time_calc_averages;
	//float time_transfering_to_cpu;

	// allocalte matrices a_h, b_h on host
	float* a_h;
	float* b_h;
	a_h = (float*) malloc(m*n * sizeof(float));
	b_h = (float*) malloc(m*n * sizeof(float));
	
	// alloc on device
	float* a_d;
	float* b_d;
	cudaEventRecord(start, 0);
	cudaMalloc((void**)&a_d, m*n * sizeof(float));
	cudaMalloc((void**)&b_d, m*n * sizeof(float));
	cudaEventRecord(finish, 0);

	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time allocating on GPU = %.17f\n", elapsedTime);
	time_allocating = elapsedTime;

	// init on cpu
	init_matrix(a_h, m, n);
	init_matrix(b_h, m, n);

	// copy to gpu
	cudaEventRecord(start, 0);
	cudaMemcpy(a_d, a_h, m*n * sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(b_d, b_h, m*n * sizeof(float), cudaMemcpyHostToDevice);
	cudaEventRecord(finish, 0);

	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time transfering to GPU = %.17f\n", elapsedTime);
	//time_transfering_to_gpu = elapsedTime;

	cudaEventRecord(start, 0);
	init_matrix_GPU<<<dimGrid, dimBlock>>>(a_d, m, n);
	init_matrix_GPU<<<dimGrid, dimBlock>>>(b_d, m, n);
	cudaEventRecord(finish, 0);
	
	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time initialising matrices on GPU = %.17f\n", elapsedTime);

	cudaEventRecord(start, 0);
	for (int i=0; i<iter; i++){
		iterate_GPU<<<dimGrid, dimBlock>>>(a_d, b_d, m, n);
		iterate_GPU<<<dimGrid, dimBlock>>>(b_d, a_d, m, n);
	}
	cudaEventRecord(finish, 0);
		
	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time for compute on GPU = %.17f\n", elapsedTime);
	time_compute = elapsedTime;

	if (calc_avg_temp == 1){
		float* thermometer_d;
		cudaMalloc((void**)&thermometer_d, m * sizeof(float));

		cudaEventRecord(start, 0);
		calculate_avg_temp_GPU<<<dimGrid, dimBlock>>>(a_d, m, n, thermometer_d);
		cudaEventRecord(finish, 0);

		cudaEventSynchronize(start);
		cudaEventSynchronize(finish);
		cudaEventElapsedTime(&elapsedTime, start, finish);
		printf("Time to calculate averages on GPU = %.17f\n", elapsedTime);	
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
	printf("Time to transfer to RAM = %.17f\n", elapsedTime);	
	//time_transfering_to_cpu = elapsedTime;
	
	// free
	free(a_h);	
	free(b_h);	
	cudaFree(a_d);	
	cudaFree(b_d);	

	// end //
	//=================================================================//
	
		
	clock_t time_start;			
	clock_t time_end;			
	float cpu_time_allocating;
	float cpu_time_compute;
	float cpu_time_calc_averages;

	// CPU Calculation //
	//=================================================================//
	if (calc_cpu == 1){
			printf("\n//======================================//\n");
			printf("               CPU Calculation              \n");
			printf("//======================================//\n\n");

	
			// allocalte matrices a, b
			float* a;
			float* b;
			time_start = clock();
			a = (float*) malloc(m*n * sizeof(float));
			b = (float*) malloc(m*n * sizeof(float));
			time_end = clock();
			cpu_time_allocating = (float)(time_end - time_start) / (CLOCKS_PER_SEC * 1e-3);
			printf("Time allocating on CPU = %.17f\n", cpu_time_allocating);
			
			time_start = clock();
			init_matrix(a, m, n);
			init_matrix(b, m, n);
			time_end = clock();
			printf("Time initialising matrices on CPU = %.17f\n", (float)(time_end - time_start) / (CLOCKS_PER_SEC * 1e-3));
			
			time_start = clock();
			for (int i=0; i<iter; i++){
				iterate(a, b, m, n);
				iterate(b, a, m, n);
			}
			time_end = clock();
			cpu_time_compute = (float)(time_end - time_start) / (CLOCKS_PER_SEC * 1e-3);
			printf("Time for compute on CPU = %.17f\n", cpu_time_compute);
				
			if (calc_avg_temp == 1){
				float* thermometer = (float*) calloc(m, sizeof(float));

				time_start = clock();
				calculate_avg_temp(a, m, n, thermometer);
				time_end = clock();
				cpu_time_calc_averages = (float)(time_end - time_start) / (CLOCKS_PER_SEC * 1e-3);
				printf("Time to calculate averages on CPU = %.17f\n", cpu_time_calc_averages);

				free(thermometer);
			}	
			
			// free matrices a, b
			free(a);
			free(b);
	}
	// end //
	//=================================================================//

	if (show_timings_next_to_eachother == 1){
		printf("\n//======================================//\n");
		printf("      SHOWING MAIN TIMINGS AND SPEEDUPS     \n");
		printf("//======================================//\n\n");
			
		printf("Allocating memory    | CPU: %.17f | GPU: %.17f | Speedup: %.17f\n", 
				cpu_time_allocating, time_allocating, cpu_time_allocating/time_allocating);
		printf("Main compute         | CPU: %.17f | GPU: %.17f | Speedup: %.17f\n", 
				cpu_time_compute, time_compute, cpu_time_compute/time_compute);
		printf("Calculating averages | CPU: %.17f | GPU: %.17f | Speedup: %.17f\n", 
				cpu_time_calc_averages, time_calc_averages, cpu_time_calc_averages/time_calc_averages);
		printf("\n");


		char filename[100];
		sprintf(filename, "writeup/task3.csv");
		FILE *fp = fopen(filename, "a");

		//fprintf(fp,"m,n,block_size_x,block_size_y,cpu_time_allocating,time_allocating,speedup_time_allocating,cpu_time_compute,time_compute,speedup_time_compute,cpu_time_calc_averages,time_calc_averages,speedup_time_calc_averages);

//				      1		2	3		4	5		6	7		8	9		10	  11	 12		13	
		fprintf(fp, "%d,%d,%d,%d,%.17f,%.17f,%.17f,%.17f,%.17f,%.17f,%.17f,%.17f,%.17f", 
				m, n, block_size_x, block_size_y,
				cpu_time_allocating, time_allocating, cpu_time_allocating/time_allocating,
				cpu_time_compute, time_compute, cpu_time_compute/time_compute,
				cpu_time_calc_averages, time_calc_averages, cpu_time_calc_averages/time_calc_averages);
		fprintf(fp, "\n");
		fclose(fp);

	}


    return 0;
}
