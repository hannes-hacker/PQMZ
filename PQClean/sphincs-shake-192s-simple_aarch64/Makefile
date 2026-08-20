
SOURCES = benchmark.c address.c context_shake.c f1600x2_const.c f1600x2.s fips202x2.c fors.c hash_shake.c hash_shakex2.c merkle.c sign.c thash_shake_simplex2.c utils.c utilsx2.c wots.c ../common/randombytes.c ../common/fips202.c
OBJECTS = benchmark.out

CFLAGS= -O3  -I../common $(EXTRAFLAGS)

all: compile

compile:
	$(CC) $(SOURCES) -g -o $(OBJECTS)

clean:
	$(RM) $(OBJECTS)

