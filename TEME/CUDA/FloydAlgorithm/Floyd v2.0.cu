#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <cuda.h>

__global__ void Floyd(float* A, int N, int k) {
    int i = blockIdx.x;                             //block
    int j = blockDim.x * blockIdx.x + threadIdx.x;  //thread

    if( (i<N && j<N) && (a[i][k]+a[k][j]) < a[i][j] ) {
        a[i][j] = a[i][k]+a[k][j];
    }
}

int main() {
    FILE *file;
    file = fopen("floyd.txt","r");

    int N;
    float *h_A, *d_A;
    int i, j, k;
    size_t sizeA;

    fscanf(file, "%d%", &N);
    sizeA = N * N * sizeof(float);

    h_A = (float*)malloc(sizeA);

    // INPUT MATRIX
    for(i=0 ;i<M; i++) {
        for(j=0; j<N; j++) {
            fscanf(file, "%f%", &A[i][j]);
        }
    }

    fclose(file);

    // Copy data to device
    cudaMalloc(&d_A, sizeA);
    cudaMemcpy(d_A, h_A, sizeA, cudaMemcpyHostToDevice);

    // Invoke kernel

    int numOfThreads = 256;
	int numOfBlocks = (N + numOfThreads - 1) / numOfThreads;
	
	dim3 dimBlock(numOfThreads, numOfThreads);
	dim3 dimGrid(numOfBlocks, numOfBlocks);
	
    for(k=0; k<N; k++) {
		Floyd <<<dimGrid, dimBlock>>>(d_A, N, k);
	}

    // COPY RESULT TO HOST
    cudaMemcpy(h_A, d_A, sizeA, cudaMemcpyDeviceToHost);

    cudaFree(d_A);

    //PRINT RESULT
    for(i=0; i<N; i++){
        for(j=0; j<N;j++){
            printf("%f ", d_A[i][j]);
        }
        printf("/n");
    }

    free(h_A);

    return 0;
}
