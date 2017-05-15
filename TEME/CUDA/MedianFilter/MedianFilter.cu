#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <cuda.h>

__global__ void MatrixMult(int*** img, int*** med) {
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;
	
	if(row == 0 || col == 0 || row == (blockDim.y-1) || col == (blockDim.x-1) ) {
		med[row][col][0] = img[row][col][0];	//R
		med[row][col][1] = img[row][col][1];	//G
		med[row][col][2] = img[row][col][2];	//B
	}
	else {
		med[row][col][0] = 	( 	//R
			img[row-1][col-1][0] + img[row-1][col][0] + img[row-1][col+1][0] +
			img[row][col-1][0]   + img[row][col][0]   + img[row][col+1][0]   +
			img[row+1][col-1][0] + img[row+1][col][0] + img[row+1][col+1][0] ) / 9;
			
		med[row][col][1] = 	( 	//G
			img[row-1][col-1][1] + img[row-1][col][1] + img[row-1][col+1][1] +
			img[row][col-1][1]   + img[row][col][1]   + img[row][col+1][1]   +
			img[row+1][col-1][1] + img[row+1][col][1] + img[row+1][col+1][1] ) / 9;
			
		med[row][col][2] = 	( 	//B
			img[row-1][col-1][2] + img[row-1][col][2] + img[row-1][col+1][2] +
			img[row][col-1][2]   + img[row][col][2]   + img[row][col+1][2]   +
			img[row+1][col-1][2] + img[row+1][col][2] + img[row+1][col+1][2] ) / 9;
	}
}

int main() {
    FILE *file;
    file = fopen("image.txt","r");

	//img[height][width][pixel]
	
    int height, width;
    int ***img;
    int ***org, ***med;
    int i,j,k;
    size_t size;

	//READ THE IMAGE
    fscanf(file, "%d%", &height);
	fscanf(file, "%d%", &width);
	
    size = height * width * 3 * sizeof(int);
    img = (float*)malloc(size);
    for(i=0 ;i<height; i++) {
        for(j=0; j<width; j++) {
			for(k=0; k<3; k++) {	//RGB
				fscanf(file, "%f%", &img[i][j][k]);
			}
        }
    }
    fclose(file);
	

	
	//Alloc cuda matrices
    cudaMalloc(&org, size);	//original file
    cudaMalloc(&med, size);	//final output file

    cudaMemcpy(org, img, size, cudaMemcpyHostToDevice);
    cudaMemcpy(med, img, size, cudaMemcpyHostToDevice);

    // Invoke kernel
    int numBlocks = 1;
	dim3 numThreads(height, width);
	
	MedianFilter<<<numBlocks, numThreads>>>(org,med);

	
    // COPY RESULT TO HOST
    cudaMemcpy(img, med, size, cudaMemcpyDeviceToHost);
    cudaFree(org);
    cudaFree(med);

    //PRINT RESULT
    for(i=0; i<height; i++){
        for(j=0; j<width;j++){
			for(k=0; k<width;k++){
				printf("%d,", img[i][j][k]);
			}
			printf("   ");
        }
        printf("/n");
    }
	
    free(img);

    return 0;
}