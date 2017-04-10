#include "mpi.h")
#include <stdio.h>
#include <math.h>

#define SIZE 8
#define TARGET 5
#define MASTER 0

int main(int argc, char **argv){
	int myid, numprocs;

	int M1[SIZE] = {(1,2,3),(4,5,6),(7,8,9)};
	int M2[SIZE] = {(9,8,7),(6,5,4),(3,2,1)};
	int target = TARGET;
	int i, j, x, low, high, myresult=0, result;

	//FILE *fp;

	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD, &myid);


	//if(MASTER == myid) {
		/* open input file and intialize data */
	//	if( NULL == (fp = fopen("input.txt", "r")) ) {
	//		printf("\nCan't open the input file.");
	//		MPI_Abort;
	//	} else
		//for(i=0; i<MAXSIZE; i++) {
	//		printf("\nFile opened.");
			//fscanf(fp, "%d", &data[i]);
		//}
	//}



	/* broadcast data */
	MPI_Bcast(M1, SIZE, MPI_INT, 0, MPI_COMM_WORLD);

	/* add portion of data */
	x = SIZE/numprocs; /* must be an integer */
	low = myid * x;
	high = low + x;

	for(i=low; i<high; i++) {
		//if(M1[i] == target)
			//myresult += i;
		for(j=i; j<high; j++)
			printf("\nI got %d from %d", M1[i][j], myid);
	}

	//printf("\nI got %d from %d", myresult, myid);

	/* compute global sum */
	//MPI_Reduce(&myresult, &result, 1, MPI_INT, MPI_MAX, 0, MPI_COMM_WORLD);

	//if(0 == myid) {
	//	printf("\nElement found at position %d.", result);
	//}

	MPI_Finalize();
}