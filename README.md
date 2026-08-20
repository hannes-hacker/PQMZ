These directories represent the implementation of the paper "PQMZ: Formally Verified Falcon-PKR for Post-Quantum Cryptographic Migration in Zcash".

- "thesis_prototype_secuer_git_ceremony" holds the contents of the Git repositories utilized for the distributed SECUER setup protocol.
- "thesis_prototypes_digital_signatures" holds the source code for the benchmarks and contributions associated with the utilized digital signatures.
- "thesis_falcon_pkr_proof" holds the first machine-checked formalisation of PKR security reduction in EasyCrypt.
- "benchmark_datasets" holds the benchmarking datasets for the ECDSA and Falcon implementation. It also provides scripts to display statistics on them. They can be recreated by utilizing the "thesis_prototypes_digital_signatures/test_compare_*.py" scripts.
- "PQClean" holds the PQClean Falcon implementation for the "aarch64" architecture which we extended to accomodate the Public-Key-Recovery (PKR) mode. It also holds a benchmarking and a functionality testing script.
- "sphincsplus" holds the SPHINCS+ reference implementation for different architectures. For our paper, we utilized the "aarch64" architecture.

We provided a "README.md" in all "thesis" directories to give an overview over content, setup and usage of them.
Other "README.md" are included, e.g. in the SECUER protocol tools, because we utilized already existing repositories.