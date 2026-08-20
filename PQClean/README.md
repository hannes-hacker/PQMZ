# Description
This repository represents the implementation and contribution based on the Falcon implementation of the PQClean project.

We extracted the Falcon code for the "aarch64" architecture out of the GitHub repository (https://github.com/PQClean/PQClean)
and extended it to accomodate the Public-Key-Recovery (PKR) mode, a benchmarking script (inspired by the "libsecp256k1" implementation (https://github.com/bitcoin-core/secp256k1)
we compared it to in the paper) and a basic functionality test.

## Scripts
The benchmarking script is located under "PQClean/Falcon*_aarch/benchmark.c".
The functionality test script is located under "test_function.c"
The counting of the maximum amount of rejected samples during recoverable signature creation is done by "iterations_invertible.c"
to be used as a parameter for the countermeasure against time-based side-channel attacks (param.h: variable PKR_SIG_SAMPLES for Falcon implementations in PKR_parameters (directory)),

## Contributions
We implemented the Public-Key-Recovery (PKR) mode where we had to make adjustments in the code.
Those adjustments are pointed out in the following and can be looked at in detail in the code.

- PQClean/Falcon*_aarch/api.h
    - line 10: PQCLEAN_FALCON512_AARCH64_CRYPTO_BYTES_PKR
    - line 15: PQCLEAN_FALCONPADDED512_AARCH64_CRYPTO_BYTES_PKR
    - line 42: PQCLEAN_FALCON512_AARCH64_crypto_sign_signature_pkr
    - line 68: PQCLEAN_FALCON512_AARCH64_crypto_sign_verify_pkr_recover

- PQClean/Falcon*_aarch/inner.h
    - line 139: "Note that all additions with suffix "_pkr" are made by us."
    - line 168: PQCLEAN_FALCON512_AARCH64_comp_encode_pkr
    - line 177: PQCLEAN_FALCON512_AARCH64_comp_decode_pkr
    - line 801: PQCLEAN_FALCON512_AARCH64_sign_dyn_pkr

- PQClean/Falcon*_aarch/codec.c
    - line 386: PQCLEAN_FALCON512_AARCH64_comp_encode_pkr
    - line 545: PQCLEAN_FALCON512_AARCH64_comp_decode_pkr

- PQClean/Falcon*_aarch/pqclean.c
    - line 211: do_sign_pkr
    - line 385: do_verify_pkr_recover
    - line 491: PQCLEAN_FALCON512_AARCH64_crypto_sign_verify_pkr_recover
    - line 506: PQCLEAN_FALCON512_AARCH64_crypto_sign_signature_pkr

- PQClean/Falcon*_aarch/sign.c
    - line 955: do_sign_dyn_pkr
    - line 1144: PQCLEAN_FALCON512_AARCH64_sign_dyn_pkr

--> also adjusted the Falcon1024 in an according way

# Setup
For executing the scripts we added a Makefile which can be utilized as following:
    - install "make"
    - install "gcc"
    - change the first filename of "SOURCES"/"OBJECTS" to either "test_function.c"/"test_function.out" or "benchmark.c"/"benchmark.out" or 
    - change directory in the terminal to "PQClean/*_aarch64"
    - type "make" into the terminal
    - type "./benchmark_falcon.out" or "./test_function.out" into the terminal (depending on what file you created through the Makefile)

--> for Falcon512 and Falcon1024 we added a parameterized (PKR_SIG_SAMPLES in params.h) countermeasure against time-based side-channel attacks through rejection sampling
--> therefore the "PQClean/PKR_parameters/PQClean" can be utilized above
--> "PQClean/Falcon*" implementations are not using this countermeasure.