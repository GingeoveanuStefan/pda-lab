#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <cuda.h>

__global__ void MatrixMult(float* A, float* B, float* C, int N) {
    int i = blockIdx.x;                             //block
    int j = blockDim.x * blockIdx.x + threadIdx.x;  //thread
    int k;

    for(k = 0; k < N; k++)
        C[i][j] += A[i][k] * B[k][j];
}

int main() {
    FILE *file;
    file = fopen("input.txt","r");

    int M, N, P;
    float *h_A, *h_B, *h_C;
    float *d_A, *d_B, *d_C;
    int i, j;
    size_t sizeM, sizeN, sizeP;

    fscanf(file, "%d%", &M);
    fscanf(file, "%d%", &N);
    fscanf(file, "%d%", &P);

    sizeM = M * sizeof(float);
    sizeN = N * sizeof(float);
    sizeP = P * sizeof(float);

    float* h_A = (float*)malloc(sizeM*sizeN);
    float* h_B = (float*)malloc(sizeN*sizeP);
    float* h_C = (float*)malloc(sizeN*sizeP);

    // Read matrices
    for(i=0 ;i<M; i++) {    // A
        for(j=0; j<N; j++) {
            fscanf(file, "%f%", &A[i][j]);
        }
    }
    for(i=0 ;i<N; i++) {    // B
        for(j=0; j<P; j++) {
            fscanf(file, "%f%", &A[i][j]);
        }
    }

    fclose(file);

    cudaMalloc(&d_A, sizeM*sizeN);
    cudaMalloc(&d_B, sizeN*sizeP);
    cudaMalloc(&d_C, sizeM*sizeP);

    cudaMemcpy(d_A, h_A, sizeM*sizeN, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, sizeN*sizeP, cudaMemcpyHostToDevice);

    // Invoke kernel with M blocks (one block per line) and P threads per block (one thread per element)
    MatrixMult<<<M, P>>>(d_A, d_B, d_C, N);

    // COPY RESULT TO HOST
    cudaMemcpy(h_C, d_C, sizeM*sizeP, cudaMemcpyDeviceToHost);

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    //PRINT RESULT
    for(i=0; i<M; i++){
        for(j=0; j<P;j++){
            printf("%f ", d_C[i][j]);
        }
        printf("/n");
    }

    free(h_A);
    free(h_B);
    free(h_C);

    return 0;
}
