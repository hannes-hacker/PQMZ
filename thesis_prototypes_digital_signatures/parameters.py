from Crypto.Hash import SHAKE256, cSHAKE256, TurboSHAKE256, KangarooTwelve

###########################################################################################
### This file holds parameters for different functionality used in the implementations. ###
###########################################################################################

# Sets the hash function utilized in the benchmarks and overall functions of ECDSA and Falcon.
default_hash_function = SHAKE256
XOF_numerical = {SHAKE256: 0, cSHAKE256: 1, TurboSHAKE256: 2, KangarooTwelve: 3}

# Sets the number of iterations for the benchmark creation.
benchmark_iterations = 100

# Utility function to turn the XOF hash function into number.
def hash_numerical():
    return XOF_numerical[default_hash_function]

# Describes the parameter for the countermeasure against time-based side-channel attacks
# by always creating several samples of polynomials to not give away information through rejection sampling.
falcon512_sampling_size = 3
falcon1024_sampling_size = 5