#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "task1_funcs.h"

int main(int argc, char *argv[]) {

	int option;
	int m = 32;
	int n = 32;
	int iter = 10;
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
        }
    }
	
	// allocalte matrices a, b
	float* a;
	float* b;
	a = malloc(m*n * sizeof(float));
	b = malloc(m*n * sizeof(float*));
	
	init_matrix(a, m, n);
	init_matrix(b, m, n);
	
	for (int i=0; i<iter; i++){
		iterate(a, b, m, n);
		iterate(b, a, m, n);
	}
		
	if (calc_avg_temp == 1){
		float* thermometer = calloc(m, sizeof(float));
		calculate_avg_temp(a, m, n, thermometer);
	
		printf("Average temperatures\n");
		for (int t=0; t<m; t++){
			printf("%f ", thermometer[t]);
		}
		printf("\n");
		free(thermometer);
	}	
	
	// free matrices a, b
	free(a);
	free(b);

    return 0;
}
