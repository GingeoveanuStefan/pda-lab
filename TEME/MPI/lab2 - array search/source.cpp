#include "mpi.h"
#include <stdio.h>
#include <math.h>

#define SIZE 8
#define TARGET 5
#define MASTER 0

int main(int argc, char **argv){
	int myid, numprocs;

	int data[SIZE] = {5,2,3,4,5,6,7,8}, target=TARGET;
	int i, x, low, high, myresult=0, result;

	FILE *fp;

	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD, &myid);

	/* broadcast data */
	MPI_Bcast(data, SIZE, MPI_INT, 0, MPI_COMM_WORLD);

	/* add portion of data */
	x = SIZE/numprocs; /* must be an integer */
	low = myid * x;
	high = low + x;

	for(i=low; i<high; i++) {
		if(data[i] == target)
			myresult += i;
	}

	printf("\nI got %d from %d", myresult, myid);

	MPI_Reduce(&myresult, &result, 1, MPI_INT, MPI_MAX, 0, MPI_COMM_WORLD);

	if(0 == myid) {
		printf("\nElement found at position %d.", result);
	}

	MPI_Finalize();
}
