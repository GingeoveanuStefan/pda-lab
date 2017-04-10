#include "mpi.h"
#include <stdio.h>
#include <stdlib.h>

#define MASTER 0
#define MAX_PRIME 80

int isPrime(int n){
	int i;

	if(n == 0 || n == 1) 
		return 0;

	for (i=2; i<n; i++)
		if (n % i == 0)
			return 0;

	return 1;
} 

int main (int argc, char *argv[]) { 
	int numprocs, procid, len;
	char hostname[MPI_MAX_PROCESSOR_NAME];
	int partner, message;
	
	MPI_Status status;
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
	MPI_Comm_rank(MPI_COMM_WORLD,&procid);
	MPI_Get_processor_name(hostname, &len);

	if (procid == MASTER) {
				
		for(int i=1; i<numprocs; i++) {
			message = (MAX_PRIME / numprocs) * (i-1);
			MPI_Send(&message , 1, MPI_INT, i, 1, MPI_COMM_WORLD);
		}
		message = (MAX_PRIME / numprocs) * (numprocs - 1);
		//printf("MASTER START AT %d \n", message);

		for(int i=message; i<= message + (MAX_PRIME / numprocs); i++)
			if(isPrime(i))
				printf("MASTER found number: %d \n", i);
	}

	if (procid != MASTER) {
		partner = MASTER;
		MPI_Recv(&message, 1, MPI_INT, partner, 1, MPI_COMM_WORLD, &status);
		//printf("%d START AT %d \n",procid, message);

		for(int i=message; i< message + (MAX_PRIME / numprocs); i++)
			if(isPrime(i))
				printf("Process %d found number: %d \n",procid, i);
	}

	MPI_Finalize();
}

