
SOURCES = benchmark.c ../common/fips202.c ../common/randombytes.c codec.c common.c fft_tree.c fft.c fpr.c keygen.c ntt_consts.c ntt.c poly_float.c poly_int.c pqclean.c rng.c sampler.c sign.c util.c vrfy.c
OBJECTS = benchmark.out
HEADERS = ntt_consts.h params.h

CFLAGS= -O3  -I../common $(EXTRAFLAGS)

all: compile

compile:
	$(CC) $(SOURCES) -g -o $(OBJECTS)

clean:
	$(RM) $(OBJECTS)

