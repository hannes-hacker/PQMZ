from time import perf_counter_ns
from decimal import Decimal, ROUND_FLOOR
from Transparent_Prototype_Falcon import PublicKey, PrivateKey, generateKeyPair
import csv
from Crypto.Hash import SHAKE256, cSHAKE256, TurboSHAKE256, KangarooTwelve
from parameters import hash_numerical, benchmark_iterations
from os.path import exists
from os import remove

######################################################################################
### This script benchmarks the functionality of "Transparent_Prototype_Falcon.py". ###
######################################################################################

file_name = "test_compare_transparent_falcon512.csv"

def write_to_csv(content):
    with open(file_name, "a", newline='') as target:
        writer = csv.writer(target, delimiter=";", lineterminator="\n")
        writer.writerow(content)

def test_generateKeyPair():
    start = perf_counter_ns()
    keys = generateKeyPair(512) # 512-bit Falcon algorithms is used in this project
    end = perf_counter_ns()
    return end - start

def test_sign(keypair):
    private_key = keypair[1]
    start = perf_counter_ns()
    signature = private_key.sign(b"Hello World!")
    end = perf_counter_ns()
    return end - start

def test_sign_recoverable(keypair):
    private_key = keypair[1]
    start = perf_counter_ns()
    signature = private_key.sign_recoverable(b"Hello World!")
    end = perf_counter_ns()
    return end - start


def test_recover(keypair):
    private_key = keypair[1]
    signature = private_key.sign_recoverable(b"Hello World!")
    start = perf_counter_ns()
    public_key = private_key.recover(b"Hello World!", signature)
    end = perf_counter_ns()
    return end - start

def test_verify(keypair):
    public_key = keypair[0]
    private_key = keypair[1]
    signature = private_key.sign(b"Hello World!")
    start = perf_counter_ns()
    result = public_key.verify(b"Hello World!", signature)
    end = perf_counter_ns()
    return end - start

def test_verify_recoverable(keypair):
    public_key = keypair[0]
    private_key = keypair[1]
    signature = private_key.sign_recoverable(b"Hello World!")
    start = perf_counter_ns()
    result = public_key.verify_recoverable(b"Hello World!", signature, public_key.pubkey)
    end = perf_counter_ns()
    return end - start


if __name__ == "__main__":
    keypair_generation_time = 0
    for i in range(0, benchmark_iterations+1):
        new_benchmark = test_generateKeyPair()
        if i != 0:
            new_row = ["keypair_falcon", i, hash_numerical(), new_benchmark]
            write_to_csv(new_row)
        keypair_generation_time += new_benchmark
    keypair_generation_time = keypair_generation_time / (benchmark_iterations * 1000)
    print("test_generateKeyPair(): ",
          float(Decimal(str(keypair_generation_time)).quantize(Decimal(".01"), rounding=ROUND_FLOOR)), " microseconds")

    sign_time = 0
    for i in range(0, benchmark_iterations+1):
        new_benchmark = test_sign(generateKeyPair(512))
        if i != 0:
            new_row = ["sign_falcon", i, hash_numerical(), new_benchmark]
            write_to_csv(new_row)
        sign_time += new_benchmark
    sign_time = sign_time / (benchmark_iterations * 1000)
    print("test_sign(): ",
          float(Decimal(str(sign_time)).quantize(Decimal(".01"), rounding=ROUND_FLOOR)), " microseconds")

    sign_r_time = 0
    for i in range(0, benchmark_iterations+1):
        new_benchmark = test_sign_recoverable(generateKeyPair(512))
        if i != 0:
            new_row = ["signr_falcon", i, hash_numerical(), new_benchmark]
            write_to_csv(new_row)
        sign_r_time += new_benchmark
    sign_r_time = sign_r_time / (benchmark_iterations * 1000)
    print("test_sign_recoverable(): ",
          float(Decimal(str(sign_r_time)).quantize(Decimal(".01"), rounding=ROUND_FLOOR)), " microseconds")

    recover_time = 0
    for i in range(0, benchmark_iterations+1):
        new_benchmark = test_recover(generateKeyPair(512))
        if i != 0:
            new_row = ["recover_falcon", i, hash_numerical(), new_benchmark]
            write_to_csv(new_row)
        recover_time += new_benchmark
    recover_time = recover_time / (benchmark_iterations * 1000)
    print("test_recover(): ",
          float(Decimal(str(recover_time)).quantize(Decimal(".01"), rounding=ROUND_FLOOR)), " microseconds")

    verify_time = 0
    for i in range(0, benchmark_iterations+1):
        new_benchmark = test_verify(generateKeyPair(512))
        if i != 0:
            new_row = ["verify_falcon", i, hash_numerical(), new_benchmark]
            write_to_csv(new_row)
        verify_time += new_benchmark
    verify_time = verify_time / (benchmark_iterations * 1000)
    print("test_verify(): ",
          float(Decimal(str(verify_time)).quantize(Decimal(".01"), rounding=ROUND_FLOOR)), " microseconds")

    verify_r_time = 0
    for i in range(0, benchmark_iterations+1):
        new_benchmark = test_verify_recoverable(generateKeyPair(512))
        if i != 0:
            new_row = ["verifyr_falcon", i, hash_numerical(), new_benchmark]
            write_to_csv(new_row)
        verify_r_time += new_benchmark
    verify_r_time = verify_r_time / (benchmark_iterations * 1000)
    print("test_verify_recoverable(): ",
          float(Decimal(str(verify_r_time)).quantize(Decimal(".01"), rounding=ROUND_FLOOR)), " microseconds")