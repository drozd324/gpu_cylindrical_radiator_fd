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
	int calc_avg_temp_no_atomic = 0;
	int show_timings_next_to_eachother = 0;
	int save_data = 0;

	char filename[100];
	sprintf(filename, "writeup/task3.csv");

	int block_size_x = 2; //threads per block
	int block_size_y = 2; //threads per block

    while ((option = getopt(argc, argv, "m:n:p:x:y:aActs")) != -1) {
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
			case 'A': // sets caclulation of average temperature for each row with hw1 implementation
				calc_avg_temp = 1;
				calc_avg_temp_no_atomic = 1;
				sprintf(filename, "writeup/task3_old_reduce.csv");
				
				break;
			case 'c': // caclulates cpu version of algorithm
				calc_cpu = 1;
				break;
			case 't': // caclulates all timings
				show_timings_next_to_eachother = 1;
				calc_cpu = 1;
				calc_avg_temp = 1;
				break;
			case 's': // saves all the data to a csv file
				show_timings_next_to_eachother = 1;
				calc_cpu = 1;
				calc_avg_temp = 1;
				save_data = 1;
				break;
        }
    }

	// GPU Calculation //
	//=================================================================//
	printf("\n//======================================//\n");
	printf("              GPU Calculation               \n");
	printf("//======================================//\n\n");

	if ( ((n*m) % (block_size_x*block_size_y)) != 0){
		fprintf(stderr, "[ERROR]: block size (number of threads per block) doesnt divide the total size of the matrix\n");
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

	double time_allocating;
	//double time_transfering_to_gpu;
	double time_compute;
	double time_calc_averages;
	//double time_transfering_to_cpu;

	// allocalte matrices a_h, b_h on host
	double* a_h;
	double* b_h;
	a_h = (double*) malloc(m*n * sizeof(double));
	b_h = (double*) malloc(m*n * sizeof(double));

	// init on cpu
	init_matrix(a_h, m, n);
	init_matrix(b_h, m, n);

//	printf("before \n");
//	printf("printing a_h\n");
//	print_matrix(a_h, m, n);
	
	// alloc on device global memory
	double* a_d;
	double* b_d;
	cudaEventRecord(start, 0);
	cudaMalloc((void**)&a_d, m*n * sizeof(double));
	cudaMalloc((void**)&b_d, m*n * sizeof(double));
	cudaEventRecord(finish, 0);

	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time allocating on GPU = %lf\n", elapsedTime);
	time_allocating = elapsedTime;

	// alloc surface memory
	int width = n;
	int height = m;
	int size = width * height * sizeof(double);
	double* host_input_data = (double*)malloc(size);

	//////////////////////////////TEXTURE/SURFACE MEMORY SHTUFF////////////////////////////////////////////////

	// Allocate CUDA arrays in device memory
	cudaChannelFormatDesc channelDesc = cudaCreateChannelDesc(64, 64, 0, 0, cudaChannelFormatKindFloat);

	cudaArray* array_a_d; // array a on device
	cudaArray* array_b_d;
	cudaMallocArray(&array_a_d, &channelDesc, width, height, cudaArraySurfaceLoadStore);
	cudaMallocArray(&array_b_d, &channelDesc, width, height, cudaArraySurfaceLoadStore);

	// Copy to device memory some data located at address host_input_data  in host memory
	const size_t spitch = width * sizeof(double);
	cudaMemcpy2DToArray(array_a_d, 0, 0, a_h, spitch, width * sizeof(double), height, cudaMemcpyHostToDevice);
	cudaMemcpy2DToArray(array_b_d, 0, 0, b_h, spitch, width * sizeof(double), height, cudaMemcpyHostToDevice);

	// Create the surface objects
	// Declare the surface memory arrays
	cudaSurfaceObject_t aSurf = 0;
	cudaSurfaceObject_t bSurf = 0;

	// Set up the structure for the surfaces
	struct cudaResourceDesc resDesc_aSurf;
	memset(&resDesc_aSurf, 0, sizeof(resDesc_aSurf));
	resDesc_aSurf.resType = cudaResourceTypeArray;
	resDesc_aSurf.res.array.array = array_a_d;

	struct cudaResourceDesc resDesc_bSurf;
	memset(&resDesc_bSurf, 0, sizeof(resDesc_bSurf));
	resDesc_bSurf.resType = cudaResourceTypeArray;
	resDesc_bSurf.res.array.array = array_b_d;

	// Bind the arrays to the surface objects
	cudaCreateSurfaceObject(&aSurf, &resDesc_aSurf);
	cudaCreateSurfaceObject(&bSurf, &resDesc_bSurf);

	//////////////////////////////////////////////////////////////////////////////////////////////////	


	// copy to gpu
	cudaEventRecord(start, 0);
	cudaMemcpy(a_d, a_h, m*n * sizeof(double), cudaMemcpyHostToDevice);
	cudaMemcpy(b_d, b_h, m*n * sizeof(double), cudaMemcpyHostToDevice);
	// copy into surface memory
	transformGlobalToSurface<<<dimGrid, dimBlock>>>(a_d, aSurf, m, n); 
	transformGlobalToSurface<<<dimGrid, dimBlock>>>(b_d, bSurf, m, n); 
	cudaEventRecord(finish, 0);

	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time transfering to GPU = %lf\n", elapsedTime);
	//time_transfering_to_gpu = elapsedTime;

	cudaEventRecord(start, 0);
	for (int i=0; i<iter; i++){
		iterate_GPU_surface<<<dimGrid, dimBlock>>>(aSurf, bSurf, m, n);
		iterate_GPU_surface<<<dimGrid, dimBlock>>>(bSurf, aSurf, m, n);
	}
	cudaEventRecord(finish, 0);
		
	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time for compute on GPU = %lf\n", elapsedTime);
	time_compute = elapsedTime;

	// copy into RAM
	cudaEventRecord(start, 0);
	transformSurfaceToGlobal<<<dimGrid, dimBlock>>>(aSurf, a_d, m, n); 
	transformSurfaceToGlobal<<<dimGrid, dimBlock>>>(bSurf, b_d, m, n); 
	cudaMemcpy(a_h, a_d, m*n * sizeof(double), cudaMemcpyDeviceToHost);
	cudaMemcpy(b_h, b_d, m*n * sizeof(double), cudaMemcpyDeviceToHost);
	cudaEventRecord(finish, 0);
	
	cudaEventSynchronize(start);
	cudaEventSynchronize(finish);
	cudaEventElapsedTime(&elapsedTime, start, finish);
	printf("Time to transfer to RAM = %lf\n", elapsedTime);	
	//time_transfering_to_cpu = elapsedTime;

	double* thermometer_d;
	double* thermometer_h = (double*) malloc(m * sizeof(double));
	if (calc_avg_temp == 1){
		cudaMalloc((void**)&thermometer_d, m * sizeof(double));
		cudaMemset(thermometer_d, 0, m * sizeof(double));

		if (calc_avg_temp_no_atomic == 0){
			cudaEventRecord(start, 0);
			calculate_avg_temp_GPU<<<dimGrid, dimBlock>>>(a_d, m, n, thermometer_d);
			cudaEventRecord(finish, 0);
		} else { // from hw1
			cudaEventRecord(start, 0);
 			sum_rows_gpu<<<dimGrid, dimBlock>>>(m, n, a_d, thermometer_d);
			cudaEventRecord(finish, 0);

		}

		cudaEventSynchronize(start);
		cudaEventSynchronize(finish);
		cudaEventElapsedTime(&elapsedTime, start, finish);
		printf("Time to calculate averages on GPU = %lf\n", elapsedTime);	
		time_calc_averages = elapsedTime;

	}	
	cudaMemcpy(thermometer_h, thermometer_d, m * sizeof(double), cudaMemcpyDeviceToHost);

	

	// end //
	//=================================================================//
	
		
	clock_t time_start;			
	clock_t time_end;			
	double cpu_time_allocating;
	double cpu_time_compute;
	double cpu_time_calc_averages;

	double* a;
	double* b;
	double* thermometer;

	// CPU Calculation //
	//=================================================================//
	if (calc_cpu == 1){
			printf("\n//======================================//\n");
			printf("               CPU Calculation              \n");
			printf("//======================================//\n\n");

	
			// allocalte matrices a, b
			time_start = clock();
			a = (double*) malloc(m*n * sizeof(double));
			b = (double*) malloc(m*n * sizeof(double));
			time_end = clock();
			cpu_time_allocating = (double)(time_end - time_start) / (CLOCKS_PER_SEC * 1e-3);
			printf("Time allocating on CPU = %lf\n", cpu_time_allocating);
			
			time_start = clock();
			init_matrix(a, m, n);
			init_matrix(b, m, n);
			time_end = clock();
			printf("Time initialising matrices on CPU = %lf\n", (double)(time_end - time_start) / (CLOCKS_PER_SEC * 1e-3));
			
//			printf("before \n");
//			printf("printing a\n");
//			print_matrix(a, m, n);

			time_start = clock();
			for (int i=0; i<iter; i++){
				iterate(a, b, m, n);
				iterate(b, a, m, n);
			}
			time_end = clock();
			cpu_time_compute = (double)(time_end - time_start) / (CLOCKS_PER_SEC * 1e-3);
			printf("Time for compute on CPU = %lf\n", cpu_time_compute);
				
			thermometer = (double*) calloc(m, sizeof(double));
			if (calc_avg_temp == 1){

				time_start = clock();
				calculate_avg_temp(a, m, n, thermometer);
				time_end = clock();
				cpu_time_calc_averages = (double)(time_end - time_start) / (CLOCKS_PER_SEC * 1e-3);
				printf("Time to calculate averages on CPU = %lf\n", cpu_time_calc_averages);

			}	
	}
	// end //
	//=================================================================//

		

	if (show_timings_next_to_eachother == 1){
		// compute errors
		printf("\n");
		double max_matrix_diff = max_diff(a_h, a, m, n);
		double max_avg_diff = max_diff(thermometer_h, thermometer, m, 1);

		printf("\n//======================================//\n");
		printf("      SHOWING MAIN TIMINGS AND SPEEDUPS     \n");
		printf("//======================================//\n\n");
			
		printf("Allocating memory    | CPU: %lf | GPU: %lf | Speedup: %lf\n", 
				cpu_time_allocating, time_allocating, cpu_time_allocating/time_allocating);
		printf("Main compute         | CPU: %lf | GPU: %lf | Speedup: %lf\n", 
				cpu_time_compute, time_compute, cpu_time_compute/time_compute);
		printf("Calculating averages | CPU: %lf | GPU: %lf | Speedup: %lf\n", 
				cpu_time_calc_averages, time_calc_averages, cpu_time_calc_averages/time_calc_averages);
		printf("\n");

		printf("Maximum difference between CPU and GPU | Avg temp: %lf\n                                       | Matrices: %lf\n",max_avg_diff, max_matrix_diff); 
		
		printf("\n");

		if (save_data == 1){
			FILE *fp = fopen(filename, "a");

			fprintf(fp, "%d,%d,%d,%d,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf,%lf", 
					m, n, block_size_x, block_size_y,
					cpu_time_allocating, time_allocating, cpu_time_allocating/time_allocating,
					cpu_time_compute, time_compute, cpu_time_compute/time_compute,
					cpu_time_calc_averages, time_calc_averages, cpu_time_calc_averages/time_calc_averages);
			fprintf(fp, "\n");
			fclose(fp);
		}

//		printf("after \n");
//		printf("printing a_h\n");
//		print_matrix(a_h, m, n);
//		printf("printing a\n");
//		print_matrix(a, m, n);

	}

	// free cuda parts
	free(a_h);
	free(b_h);
	free(thermometer_h);
	cudaFree(a_d);
	cudaFree(b_d);
	cudaFreeArray(array_a_d); // frees cuda surface
	cudaFreeArray(array_b_d);
	cudaFree(thermometer_d);

	// free cpu parts
	if (calc_cpu == 1){
		free(a);
		free(b);
		free(thermometer);
	}


    return 0;
}
