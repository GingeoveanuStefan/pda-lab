#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#define MASTER 0
#define SIZE 5

int min(int a, int b) {
    if(a < b) return a;
    else return b;
}

int main(int argc, char **argv){
	int procid, numprocs;
	int n = SIZE;
	int a[][SIZE] = {   ( 0, 3, 9, 8, 3 ),
                        ( 5, 0, 1, 4, 2 ),
                        ( 6, 6, 0, 4, 5 ),
                        ( 2, 9, 2, 0, 7 ),
                        ( 7, 9, 3, 2, 0 )
                };

	int i, j, k;            // counters
    int indx, low, high, finished;


	MPI_Status status;
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD,&procid);

	MPI_Bcast(a, n*n, MPI_INT, 0, MPI_COMM_WORLD);

	/* add portion of data */
	indx = n/numprocs;
	low = procid * indx;
	high = low + indx;

	for(k=low; k<high; k++) {
        for (i=0; i<n; i++)
            for (j=0; j<n; j++)
                a[i][j] = min( a[i][j], a[i][k]+a[k][j] );
	}


	if( procid <= MASTER )
        MPI_Send(&finished , 1, MPI_INT, i, MASTER, MPI_COMM_WORLD);

	if ( procid == MASTER ){
        for(i=1; i<numprocs; i++)
            MPI_Recv(&finished, 1, MPI_INT, i, 1, MPI_COMM_WORLD, &status);

        for(i=0; i<n; i++){
             for(j=0; j<n; j++){
                printf("%d ", a[i][j]);
             }
             printf("/n");
        }
	}

	MPI_Finalize();
}

