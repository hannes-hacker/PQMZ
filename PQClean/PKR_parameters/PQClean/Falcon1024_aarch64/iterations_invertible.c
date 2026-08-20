#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <stdlib.h>
#include <inttypes.h>
#include <math.h>

#include "api.h"

int main(void){

    int num_iterations = 10000;
    int iterations[num_iterations];

    for (int i = 0; i < num_iterations; i++){
        uint8_t *public_key_pkr = calloc(1, PQCLEAN_FALCON1024_AARCH64_CRYPTO_PUBLICKEYBYTES);
        uint8_t *secret_key_pkr = calloc(1, PQCLEAN_FALCON1024_AARCH64_CRYPTO_SECRETKEYBYTES);
        int result_keypair_pkr = PQCLEAN_FALCON1024_AARCH64_crypto_sign_keypair(public_key_pkr, secret_key_pkr);

        uint8_t *signature_pkr = calloc(1, PQCLEAN_FALCON1024_AARCH64_CRYPTO_BYTES_PKR);
        size_t signature_length_pkr;
        uint8_t message_pkr = 1;
        size_t message_length_pkr = sizeof(message_pkr);

        int *counter = calloc(1, 1);
        
        int result_sign_pkr = PQCLEAN_FALCON1024_AARCH64_crypto_sign_signature_pkr(signature_pkr, &signature_length_pkr, &message_pkr, message_length_pkr, secret_key_pkr, counter);

        if ((result_sign_pkr != 0) || (result_keypair_pkr != 0)){
            printf("ERROR!\n");
            break;
        }
        iterations[i] = *counter;
    }

    int maximal_value = -1;
    for (int i = 0; i < num_iterations; i++){
        if (iterations[i] > maximal_value){
            maximal_value = iterations[i];
        }
    }

    printf("The result is: %d.\n", maximal_value);

    return 0;
}

