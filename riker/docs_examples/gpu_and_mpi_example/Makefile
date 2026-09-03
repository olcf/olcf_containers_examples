COMP   = mpicxx

CFLAGS = -fopenmp

INCLUDES  = -I/usr/local/cuda/include
LIBRARIES = -L/usr/local/cuda/lib64 -lcudart

hello_jobstep: hello_jobstep.o
	${COMP} ${CFLAGS} ${LIBRARIES} hello_jobstep.o -o hello_jobstep

hello_jobstep.o: hello_jobstep.cpp
	${COMP} ${CFLAGS} ${INCLUDES} -c hello_jobstep.cpp

.PHONY: clean

clean:
	rm -f hello_jobstep *.o 

