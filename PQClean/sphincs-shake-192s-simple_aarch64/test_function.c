#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <stdlib.h>
#include <inttypes.h>
#include <math.h>

#include "api.h"

// This script tests the core functionality of "Falcon-512" of the PQClean implementation.


int main(void) {

    // Classical signature/verification process.
    uint8_t *public_key = calloc(1, PQCLEAN_SPHINCSSHAKE192SSIMPLE_AARCH64_CRYPTO_PUBLICKEYBYTES);
    uint8_t *secret_key = calloc(1, PQCLEAN_SPHINCSSHAKE192SSIMPLE_AARCH64_CRYPTO_SECRETKEYBYTES);

    int result_keypair = PQCLEAN_SPHINCSSHAKE192SSIMPLE_AARCH64_crypto_sign_keypair(public_key, secret_key);

    uint8_t *signature = calloc(1, PQCLEAN_SPHINCSSHAKE192SSIMPLE_AARCH64_CRYPTO_BYTES);
    size_t signature_length;
    uint8_t message = 1;
    size_t message_length = sizeof(message);
    
    int result_sign = PQCLEAN_SPHINCSSHAKE192SSIMPLE_AARCH64_crypto_sign_signature(signature, &signature_length, &message, message_length, secret_key);
    int result_verify = PQCLEAN_SPHINCSSHAKE192SSIMPLE_AARCH64_crypto_sign_verify(signature, signature_length, &message, message_length, public_key);
    

    // If the output is 0 then the operation was successful and -1 if not.
    printf("Result of non-pkr keypair generation process:\t%d\n", result_keypair);
    printf("Result of non-pkr signing process:\t\t%d\n", result_sign);
    printf("Result of non-pkr verification process:\t\t%d\n", result_verify);

    return 0;
}
