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
    uint8_t *public_key = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES);
    uint8_t *secret_key = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_SECRETKEYBYTES);
    int result_keypair = PQCLEAN_FALCON512_AARCH64_crypto_sign_keypair(public_key, secret_key);

    uint8_t *signature = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_BYTES);
    size_t signature_length;
    uint8_t message = 1;
    size_t message_length = sizeof(message);
    
    int result_sign = PQCLEAN_FALCON512_AARCH64_crypto_sign_signature(signature, &signature_length, &message, message_length, secret_key);
    int result_verify = PQCLEAN_FALCON512_AARCH64_crypto_sign_verify(signature, signature_length, &message, message_length, public_key);
    

    // Signature/verification process with public-key recovery mode.
    uint8_t *public_key_pkr = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES);
    uint8_t *secret_key_pkr = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_SECRETKEYBYTES);
    int result_keypair_pkr = PQCLEAN_FALCON512_AARCH64_crypto_sign_keypair(public_key_pkr, secret_key_pkr);

    uint8_t *signature_pkr = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_BYTES_PKR);
    size_t signature_length_pkr;
    uint8_t message_pkr = 1;
    size_t message_length_pkr = sizeof(message_pkr);
    
    int result_sign_pkr = PQCLEAN_FALCON512_AARCH64_crypto_sign_signature_pkr(signature_pkr, &signature_length_pkr, &message_pkr, message_length_pkr, secret_key_pkr);
    
    uint8_t *pk_recovered = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES);
    int result_verify_pkr = PQCLEAN_FALCON512_AARCH64_crypto_sign_verify_pkr_recover(signature_pkr, signature_length_pkr, &message_pkr, message_length_pkr, public_key_pkr, pk_recovered);

    // Check if recovered public key is the same as the generated one.
    int result_pk_comparison = 0;
    uint8_t pk_origin[PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES];
    uint8_t pk_recovered2[PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES];
    for(int i = 0; i < PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES; i++){
        pk_origin[i] = *(public_key_pkr + i);
        pk_recovered2[i] = *(pk_recovered + i);

        if (*(public_key_pkr + i) != *(pk_recovered + i)){
            printf("ERROR at index: %d!\n", i);
            result_pk_comparison = -1;
        }
    }

    // If the output is 0 then the operation was successful and -1 if not.
    printf("Result of non-pkr keypair generation process:\t%d\n", result_keypair);
    printf("Result of non-pkr signing process:\t\t%d\n", result_sign);
    printf("Result of non-pkr verification process:\t\t%d\n", result_verify);
    printf("Result of pkr keypair generation process:\t%d\n", result_keypair_pkr);
    printf("Result of pkr signing process:\t\t\t%d\n", result_sign_pkr);
    printf("Result of pkr verification process:\t\t%d\n", result_verify_pkr);
    printf("Result of pkr comparison:\t\t\t%d\n", result_pk_comparison);
    

    /* for (int i = 0; i < 10000; i++){
            // Signature/verification process with public-key recovery mode.
        uint8_t *public_key_pkr = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES);
        uint8_t *secret_key_pkr = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_SECRETKEYBYTES);
        int result_keypair_pkr = PQCLEAN_FALCON512_AARCH64_crypto_sign_keypair(public_key_pkr, secret_key_pkr);

        uint8_t *signature_pkr = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_BYTES_PKR);
        size_t signature_length_pkr;
        uint8_t message_pkr = 1;
        size_t message_length_pkr = sizeof(message_pkr);
        
        int result_sign_pkr = PQCLEAN_FALCON512_AARCH64_crypto_sign_signature_pkr(signature_pkr, &signature_length_pkr, &message_pkr, message_length_pkr, secret_key_pkr);
        
        uint8_t *pk_recovered = calloc(1, PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES);
        int result_verify_pkr = PQCLEAN_FALCON512_AARCH64_crypto_sign_verify_pkr_recover(signature_pkr, signature_length_pkr, &message_pkr, message_length_pkr, pk_recovered);

        // Check if recovered public key is the same as the generated one.
        int result_pk_comparison = 0;
        uint8_t pk_origin[PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES];
        uint8_t pk_recovered2[PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES];
        for(int i = 0; i < PQCLEAN_FALCON512_AARCH64_CRYPTO_PUBLICKEYBYTES; i++){
            pk_origin[i] = *(public_key_pkr + i);
            pk_recovered2[i] = *(pk_recovered + i);

            if (*(public_key_pkr + i) != *(pk_recovered + i)){
                result_pk_comparison = -1;
            }
        }
        if ((result_keypair_pkr + result_sign_pkr + result_verify_pkr + result_pk_comparison) != 0){
            printf("ERROR!\n");
            break;
        }
    } */

    return 0;
}
