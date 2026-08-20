

SOURCES = benchmark.c ntt.c packing.c poly.c polyvec.c reduce.c rounding.c sign.c symmetric-shake.c __asm_iNTT.S __asm_NTT.S __asm_poly.S ../common/fips202.c ../common/randombytes.c ../common/keccak2x/fips202x2.c ../common/keccak2x/feat.S
OBJECTS = benchmark.out

CFLAGS= -O3  -I../common $(EXTRAFLAGS)

all: compile

compile:
	$(CC) $(SOURCES) -g -o $(OBJECTS)

clean:
	$(RM) $(OBJECTS)


