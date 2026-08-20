
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <stdlib.h>
#include <inttypes.h>
#include <math.h>

#include "api.h"
#include "../parameters.h"


#define FP_EXP (6)
#define FP_MULT (1000000LL)

// Prints the header of the output table.
static void print_output_table_header_row(void) {
    char* bench_str = "Benchmark";     /* left justified */
    char* min_str = "    Min(us)    "; /* center alignment */
    char* avg_str = "    Avg(us)    ";
    char* max_str = "    Max(us)    ";
    printf("%-30s,%-15s,%-15s,%-15s\n", bench_str, min_str, avg_str, max_str);
    printf("\n");
}

// Gets the system time.
static int64_t gettime_i64(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (int64_t)tv.tv_usec + (int64_t)tv.tv_sec * 1000000LL;
}

// Formats fixed point number.
static void print_number(const int64_t x) {
    int64_t x_abs, y;
    int c, i, rounding, g; /* g = integer part size, c = fractional part size */
    size_t ptr;
    char buffer[30];

    if (x == INT64_MIN) {
        /* Prevent UB. */
        printf("ERR");
        return;
    }
    x_abs = x < 0 ? -x : x;

    /* Determine how many decimals we want to show (more than FP_EXP makes no
     * sense). */
    y = x_abs;
    c = 0;
    while (y > 0LL && y < 100LL * FP_MULT && c < FP_EXP) {
        y *= 10LL;
        c++;
    }

    /* Round to 'c' decimals. */
    y = x_abs;
    rounding = 0;
    for (i = c; i < FP_EXP; ++i) {
        rounding = (y % 10) >= 5;
        y /= 10;
    }
    y += rounding;

    /* Formats and prints the number. */
    ptr = sizeof(buffer) - 1;
    buffer[ptr] = 0;
    g = 0;
    if (c != 0) { /* non zero fractional part */
        for (i = 0; i < c; ++i) {
            buffer[--ptr] = '0' + (y % 10);
            y /= 10;
        }
    } else if (c == 0) { /* fractional part is 0 */
        buffer[--ptr] = '0'; 
    }
    buffer[--ptr] = '.';
    do {
        buffer[--ptr] = '0' + (y % 10);
        y /= 10;
        g++;
    } while (y != 0);
    if (x < 0) {
        buffer[--ptr] = '-';
        g++;
    }
    printf("%5.*s", g, &buffer[ptr]); /* Prints integer part */
    printf("%-*s", FP_EXP, &buffer[ptr + g]); /* Prints fractional part */
}


int main(void) {

    // Sets the sample size of the benchmarks.
    int iterations = BENCHMARK_ITERATIONS;
    int count = BENCHMARK_COUNT;

    // Initializes counting/calculation values for the key generation.
    int64_t min = INT64_MAX;
    int64_t sum = 0;
    int64_t max = 0;

    // Aggregates values of key generation samples.
    for (int i = 0; i < count; i++) {
        int64_t begin, total;
        uint8_t *pk1 = calloc(1, PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_CRYPTO_PUBLICKEYBYTES);
        uint8_t *sk1 = calloc(1, PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_CRYPTO_SECRETKEYBYTES);
        PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_crypto_sign_keypair(pk1, sk1);
        begin = gettime_i64();
        for (int j = 0; j < iterations; j++){
            PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_crypto_sign_keypair(pk1, sk1);
        }
        total = gettime_i64() - begin;
        if (total < min) {
            min = total;
        }
        if (total > max) {
            max = total;
        }
        sum += total;
    }
    
    /* ',' is used as a column delimiter */
    print_output_table_header_row();

    // Adds the benchmark output for the key generation to the output table.
    printf("%-30s, ", "keypair");
    print_number(min * FP_MULT / iterations);
    printf("   , ");
    print_number(((sum * FP_MULT) / count) / iterations);
    printf("   , ");
    print_number(max * FP_MULT / iterations);
    printf("\n");

    // Initializes counting/calculation values for the non-pkr signing process.
    int64_t min_sign = INT64_MAX;
    int64_t sum_sign = 0;
    int64_t max_sign = 0;

    // Initializes counting/calculation values for the non-pkr verification process.
    int64_t min_verify = INT64_MAX;
    int64_t sum_verify = 0;
    int64_t max_verify = 0;

    // Aggregates values of non-pkr signature and verification samples.
    for (int i = 0; i < count; i++) {
        int64_t begin, total_sign, total_verify;
        uint8_t *pk2 = calloc(1, PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_CRYPTO_PUBLICKEYBYTES);
        uint8_t *sk2 = calloc(1, PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_CRYPTO_SECRETKEYBYTES);
        PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_crypto_sign_keypair(pk2, sk2);
        uint8_t *sig = calloc(1, PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_CRYPTO_BYTES);
        size_t siglen;
        uint8_t m = 1;
        size_t mlen = sizeof(m);
        PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_crypto_sign_signature(sig, &siglen, &m, mlen, sk2);
        begin = gettime_i64();
        for (int j = 0; j < iterations; j++){
            PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_crypto_sign_signature(sig, &siglen, &m, mlen, sk2);
        }
        total_sign = gettime_i64() - begin;
        if (total_sign < min_sign) {
            min_sign = total_sign;
        }
        if (total_sign > max_sign) {
            max_sign = total_sign;
        }
        sum_sign += total_sign;

        PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_crypto_sign_verify(sig, siglen, &m, mlen, pk2);
        begin = gettime_i64();
        for (int j = 0; j < iterations; j++){
            PQCLEAN_SPHINCSSHAKE128SSIMPLE_AARCH64_crypto_sign_verify(sig, siglen, &m, mlen, pk2);
        }
        total_verify = gettime_i64() - begin;
        if (total_verify < min_verify) {
            min_verify = total_verify;
        }
        if (total_verify > max_verify) {
            max_verify = total_verify;
        }
        sum_verify += total_verify;
    }

    // Adds the benchmark output for the non-pkr signing process to the output table.
    printf("%-30s, ", "sign");
    print_number(min_sign * FP_MULT / iterations);
    printf("   , ");
    print_number(((sum_sign * FP_MULT) / count) / iterations);
    printf("   , ");
    print_number(max_sign * FP_MULT / iterations);
    printf("\n");

    // Adds the benchmark output for the non-pkr verification process to the output table.
    printf("%-30s, ", "verify");
    print_number(min_verify * FP_MULT / iterations);
    printf("   , ");
    print_number(((sum_verify * FP_MULT) / count) / iterations);
    printf("   , ");
    print_number(max_verify * FP_MULT / iterations);
    printf("\n");

    return 0;
}