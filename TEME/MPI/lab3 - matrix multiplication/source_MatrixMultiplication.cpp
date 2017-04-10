#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define MASTER 0

int **alloc_matrix(int rows, int cols) {
    int **mat = (int **)malloc(rows * sizeof(int*));

    for(int i = 0; i < rows; i++)
        mat[i] = (int *)malloc(cols * sizeof(int));

    return mat;
}


int main(int argc, char **argv){
	int procid, numprocs;
	int **a, **b, **r;      // matrices
	int i, j, k;            // counters
    int m = 5, n = 2, p = 4;
    int taskSize, taskLines, lineCounter, numLines;

	MPI_Status status;
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD,&procid);

	if(procid == MASTER){     /* Matrix TEST data initialization */
        int m = 3, n = 2, p = 4;
        /* Allocate data per matrix*/
        a = alloc_matrix(m, n);
        b = alloc_matrix(n, p);
        r = alloc_matrix(m, p);
        /* Fill matrices with some random values */
        srand(time(NULL));
        for(i = 0; i < m; i++)
            for(int j = 0; j < n; j++)
                a[i][j] = rand() % 10;

        for(i = 0; i < n; i++)
            for(int j = 0; j < p; j++)
                b[i][j] = rand() % 10;
	}

    if(procid == MASTER){    /* MASTER process */
        taskSize = (n + ((numprocs-1) / 2 )) / (numprocs-1);    // maximum tasks per process
        lineCounter = 0;
        for(i=1; i<numprocs; i++) {
            numLines = 0;               // per process
            while(numLines < taskSize && lineCounter < m) {
                numLines++;
                lineCounter++;
            }
            MPI_Send(&lineCounter , 1, MPI_INT, i, 1, MPI_COMM_WORLD);
            MPI_Send(&taskLines , 1, MPI_INT, i, 1, MPI_COMM_WORLD);
            MPI_Send(&(a[lineCounter-taskLines][0]) , taskLines*n, MPI_INT, i, 1, MPI_COMM_WORLD);
            MPI_Send(&(b[0][0]), n*p, MPI_INT, i, 1, MPI_COMM_WORLD);
        }

        //receive result matrix
        for(i=1; i<numprocs; i++) {
            MPI_Recv(&taskLines, 1, MPI_INT, i, 1, MPI_COMM_WORLD, &status);
            MPI_Recv(&(r[lineCounter-numLines][0]), taskLines*p, MPI_INT, MASTER, 1, MPI_COMM_WORLD, &status);
        }

        // print result matrix
        for(i=0; i<m; i++) {
            for(j=0; j<p; j++)
                printf(" %d ", r[i][j]);
            printf("\n");
        }
    }

    if(procid != MASTER) {
        MPI_Recv(&lineCounter, 1, MPI_INT, MASTER, 1, MPI_COMM_WORLD, &status);     //end at
        MPI_Recv(&taskLines, 1, MPI_INT, MASTER, 1, MPI_COMM_WORLD, &status);
        MPI_Recv(&(a[lineCounter-numLines][0]), taskLines*n, MPI_INT, MASTER, 1, MPI_COMM_WORLD, &status);
        MPI_Recv(&(b[0][0]), n*p, MPI_INT, MASTER, 1, MPI_COMM_WORLD, &status);

        for(i=lineCounter-taskLines; i<lineCounter; i++)
            for(j=0; j<p; j++)
                for(k = 0; k < n; ++k)
                    r[i][j] += a[i][k] * b[k][j];

        MPI_Send(&taskLines , 1, MPI_INT, i, MASTER, MPI_COMM_WORLD);
        MPI_Send(&(r[lineCounter-taskLines][0]) , taskLines*p, MPI_INT, MASTER, 1, MPI_COMM_WORLD);
    }

	MPI_Finalize();
}
