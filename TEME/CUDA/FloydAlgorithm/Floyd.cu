#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <cuda.h>

__global__ void Floyd(float* A, int N) {
    int i = blockIdx.x;                             //block
    int j = blockDim.x * blockIdx.x + threadIdx.x;  //thread
    int k;

    for(k = 0; k < N; k++) {
        if( (a[i][k]+a[k][j]) < a[i][j] )
            a[i][j] = a[i][k]+a[k][j];
    }
}

int main() {
    FILE *file;
    file = fopen("floyd.txt","r");

    int N;
    float *h_A;
    float *d_A;
    int i, j;
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

    cudaMalloc(&d_A, sizeA);

    cudaMemcpy(d_A, h_A, sizeA, cudaMemcpyHostToDevice);

    // Invoke kernel with N blocks and N threads per block
    Floyd<<<N, N>>>(d_A, N);

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
