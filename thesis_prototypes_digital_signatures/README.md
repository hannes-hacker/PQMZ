# Description
This repository represents the implementation and contribution of the section "Falcon-PKR".

The implementation is divided in three areas: Prototypes, Falcon library changes, ECDSA library changes.

We used "Python 3.13.2" and Visual Studio Code (plugins: Python and Pylance by Microsoft) for this implementation. The activation of the virtual environment, which is necessary for the execution,
can be looked up in the Python documentation (https://docs.python.org/3/tutorial/venv.html).

## Prototypes
We created prototypes to show the current functionality of the digital signatures "ECDSA" and "Ed25519"
in the respective Zcash protocols "Transparent" and "Sprout". These are compared with an almost equal
prototype using the Falcon digital signature algorithm.

The Python script "test_function.py" can be executed to check if all the used functionality works correctly.

The Python scripts "test_compare_*.py" can be executed to benchmark the respective prototypes and their functions.

The Python script "iterations_invertible.py" is utilized to determine what is the maximum number of retries during rejection sampling
has to happen for each recoverable signature creation to find a invertible s2 polynomial.

## Contributions
The following contributions were gathered alongside this project to rectify issues that would have
compromised the successful results of this project.

### Falcon library
The included Falcon library "falcon" by Thomas Prest lacks a public key recovery mode.
Therefore, we implemented this mode based on the Falcon specification (https://falcon-sign.info/falcon.pdf). It can be found in "falcon/falcon.py".
The relevant functions which we implemented are:
    - sign_recoverable (line 395)
    - split_and_decompress_signature (line 435)
    - recover (line 447)
    - verify_recoverable (line 468)
    - sign_recoverable_parameter (line 511)

### ECDSA library
The Falcon library uses SHAKE256 for hashing which is included in the PyCryptodome library (and also integrated in the Falcon specification linked above).
We used the different XOF hash algorithms included in PyCryptodome (https://www.pycryptodome.org)
to test the influence on the performance of the Falcon implementation.
These algorithms were: SHAKE256, cSHAKE, TurboSHAKE, KangarooTwelve.

For meaningful comparison, we also needed to use them in the ECDSA libary "python-ecdsa"
but it does usually not accomodate these algorithms. Hence, we included them into the functionality of
the library. The changes can be found in "ecdsa/keys.py" in the lines 6, 30, 460, 696 and 1556.

# Setup
The virtual environment with the necessary libraries should be included in this directory, labelled ".venv".
If it is not possible to execute the scripts because of missing libraries, execute the following commands:
python3 -m venv .venv (Mac/Linux) or python -m venv .venv (Windows)
source .venv/bin/activate
pip install ecdsa
pip install pycryptodome
pip install numpy
--> manually change the "keys.py" file in the venv by "lib/ecdsa/keys.py".