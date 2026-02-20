#include <stdio.h>
#include <mpi.h>

int main (int argc, char *argv[])
{
int rank, size;
MPI_Comm comm;

comm = MPI_COMM_WORLD;
MPI_Init (&argc, &argv);
MPI_Comm_rank (comm, &rank);
MPI_Comm_size (comm, &size);

printf("Hello from rank %d\n", rank);

MPI_Barrier(comm);
MPI_Finalize();
}

