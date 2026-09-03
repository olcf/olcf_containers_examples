#include <stdio.h>
#define N 1000

__global__
void add(int *a, int *b) {
    int i = blockIdx.x;
    if (i<N) {
        b[i] = 2*a[i];
    }
}

int main() {
    int ha[N], hb[N];

    int *da, *db;
    cudaMalloc((void **)&da, N*sizeof(int));
    cudaMalloc((void **)&db, N*sizeof(int));

    for (int i = 0; i<N; ++i) {
        ha[i] = i;
    }
cudaMemcpy(da, ha, N*sizeof(int), cudaMemcpyHostToDevice);

add<<<N, 1>>>(da, db);

cudaMemcpy(hb, db, N*sizeof(int), cudaMemcpyDeviceToHost);

for (int i = 0; i<N; ++i) {
    if(i+i != hb[i]) {
        printf("Something went wrong in the GPU calculation\n");
    }
}
printf("COMPLETE!");
     cudaFree(da);
     cudaFree(db);

     return 0;
} 


