#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "task1_funcs.h"
#include "task2_funcs.h"

#ifdef __cplusplus
extern "C" {
	void init_matrix(float** matrix, int m, int n);
	void iterate(float** nextMatrix, float** previousMatrix, int m, int n);
	void calculate_avg_temp(float** matrix, int m, int n, float* thermometer);
}
#endif


int main(int argc, char *argv[]) {

	int option;
	int m = 32;
	int n = 32;
	int iter = 10;
	int calc_cpu = 0;
	int calc_avg_temp = 0;

    while ((option = getopt(argc, argv, "m:n:p:a")) != -1) {
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
        }
    }
		

	//int block_size=8;
	//dim3 dimBlock(block_size);
	//dim3 dimGrid ( (N/dimBlock.x) + (!(N%dimBlock.x)?0:1) );
	//int idx = blockIdx.x * blockDim.x + threadIdx.x;

	int N = m*n;
	int block_size = 2;
	dim3 dimBlock(block_size, block_size);
	dim3 dimGrid ( (N/dimBlock.x) + (!(N%dimBlock.x)?0:1),(M/dimBlock.y) + (!(M%dimBlock.y)?0:1) );
		
	if ((N % block_size) != 0){
		fprintf(stderr, "ERROR: block size (number of threads per block) doesnt divide the total size of the matrix\n");
		return 1;
	}

	if (calc_cpu == 1){
			// allocalte matrices a, b
			float** a;
			a = malloc(m * sizeof(float*));
			for (int i=0; i<m; i++){
				a[i] = malloc(n * sizeof(float));
			}
			float** b;
			b = malloc(m * sizeof(float*));
			for (int i=0; i<m; i++){
				b[i] = malloc(n * sizeof(float));
			}
			
			init_matrix(a, m, n);
			init_matrix(b, m, n);
			
			for (int i=0; i<iter; i++){
				iterate(a, b, m, n);
				iterate(b, a, m, n);
			}
				
			if (calc_avg_temp == 1){
				float* thermometer = calloc(m, sizeof(float));
				calculate_avg_temp(a, m, n, thermometer);
				free(thermometer);
			}	
			
			// free matrices a, b
			for (int i=0; i<m; i++){
				free(a[i]);
			}
			free(a);
			for (int i=0; i<m; i++){
				free(b[i]);
			}
			free(b);
	}

    return 0;
}
