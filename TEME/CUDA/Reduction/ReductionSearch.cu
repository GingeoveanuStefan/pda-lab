#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <cuda.h>

// g_data		=	array of values
// target		=	value to find
// g_posdata	=	array of array of positions
//		g_posdata[0]	has N/1 + 1 max elements
//		g_posdata[N/2]	has N/2 + 1 max elements
//		g_posdata[N/4]	has N/4  max elements
//		g_posdata[N/8]	has N/8  max elements
//		g_posdata[N/16]	has N/16 max elements


__global__ void reduce_sum(int *g_data, int **g_posdata, int target) {
	extern __shared__ int sdata[][];

	unsigned int tid = threadIdx.x;
	unsigned int i = blockIdx.x *blockDim.x + threadIdx.x;
	
	if(g_data[i] == target) {	//add initial position if target found
		sdata[tid][0] = i;
	}
	
	__syncthreads();
	
	// do reduction in shared mem
	for (unsigned int s = 1; s < blockDim.x; s *= 2) {
		if (tid % (2 * s) == 0)  {
			if (g_data[tid + s] == target ){	//found target on paired position
				unsigned int p;
				for(p = 0; p<blockDim.x && sdata[tid][p] != -1 ; p++);	//go to end positions list
				sdata[tid][p] = tid + s;				// and add position
			}
		}
		__syncthreads();
	}
	
	// write result for this block to global mem
	if (tid == 0) {
		g_posdata[blockIdx.x] = sdata[0];
	}
}

int main(){
	FILE *file;
    file = fopen("input.txt","r");
	
	
	int *h_data, *d_data;
	int **h_posdata, **d_posdata;
	int n, target;
	
	size_t size, pos_size;
	
	//Read data
    fscanf(file, "%d%", &n);
	
	//Input values
    size = n * sizeof(int);
    h_data = (float*)malloc(size);
    for(i=0 ;i<n; i++) {
		fscanf(file, "%d%", &h_data[i]);
    }
	
	fscanf(file, "%d%", &target);
	
    fclose(file);
	
	pos_size = n * n * sizeof(int);
	h_posdata = (float*)malloc(pos_size);
	
	// copy inputs to device
	cudaMemcpy(d_data, h_data, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_posdata, h_posdata, pos_size, cudaMemcpyHostToDevice);

    int numBlocks = 1;
	dim3 numThreads(n);

	reduce_sum <<< numBlocks, numThreads >>> (d_data, d_posdata, target);

	cudaMemcpy(h_data, d_data, size, cudaMemcpyDeviceToHost);
	cudaMemcpy(h_posdata, d_posdata, pos_size, cudaMemcpyDeviceToHost);

    for(i=0; i<n && h_posdata[0][i] != -1; i++) {
		fscanf(file, "%d%", &h_posdata[0][i]);
    }

	// free device memory
	cudaFree(d_data);
	cudaFree(d_posdata);

	// free host memory
	free(h_data);
	free(h_posdata);

	return 0;
}