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

    while ((option = getopt(argc, argv, "m:n:p:a:")) != -1) {
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
				calc_avg_temp = atoi(optarg);
				break;
        }
    }
	
	float** a;
	a = malloc(m * sizeof(float*));
	for (int i=0; i<m; i++){
		a[i] = malloc(n * sizeof(float));
	}
	//alloc_matrix(a, m, n);
	float** b;
	b = malloc(m * sizeof(float*));
	for (int i=0; i<m; i++){
		b[i] = malloc(n * sizeof(float));
	}
	//alloc_matrix(b, m, n);
	
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
	
	//free_matrix(a, m);
	for (int i=0; i<m; i++){
		free(a[i]);
	}
	free(a);
	//free_matrix(b, m);
	for (int i=0; i<m; i++){
		free(b[i]);
	}
	free(b);

    return 0;
}
