#include "stdio.h"
#include "mpi.h"
#include<unistd.h>

int main(int argc, char **argv)
{
    int rank, root, bcast_data;
    root = 0;

    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    for(int i=0;i<100;i++) {
    if(rank == root) {
	   printf("Iteration %d\n", i);
           bcast_data = 10;
    }

    MPI_Bcast(&bcast_data, 1, MPI_INT, root, MPI_COMM_WORLD);

    printf("Rank %d has bcast_data = %d\n", rank, bcast_data);
    sleep(5);
    }


    MPI_Finalize();
    return 0;
}

