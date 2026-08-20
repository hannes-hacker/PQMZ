import Transparent_Prototype_ECDSA, Transparent_Prototype_Falcon, Sprout_Prototype_EdDSA

############################################################
### This script tests the functionality of all prototype ###
############################################################

# Testing of the ECDSA prototype - sign/verify are calling the same library function
# as sign_recoverable/verify_recoverable.
def test_ecdsa():
    keys = Transparent_Prototype_ECDSA.generateKeyPair()
    public_key = keys[0]
    private_key = keys[1]
    signature = private_key.sign(b"Hello World!")
    result = public_key.verify(b"Hello World!", signature)
    recovered_key = private_key.recover(b"Hello World!", signature)
    verify_recovered = (recovered_key[0] == public_key.pubkey) | (recovered_key[1] == public_key.pubkey)
    result = result & verify_recovered

    if result:
        print("ECDSA signing and verification process successful!")
        public_key = private_key.key.verifying_key.to_string()
        print(f"Length of the public key: {len(public_key)}.")
        print(f"Length of the private key: {len(private_key.key.to_string())}.")
        print(f"Length of the signature: {len(signature)}.")
        print("--------------------------------------------------")
    else:
        print("ECDSA signing and verification process unsuccessful!")

# Testing of the Falcon-512 prototype
def test_falcon512():
    keys = Transparent_Prototype_Falcon.generateKeyPair(512)
    public_key = keys[0]
    private_key = keys[1]

    # Testing classic sign/verify features
    signature1 = private_key.sign(b"Hello World!")
    result = public_key.verify(b"Hello World!", signature1)

    # Testing the recoverable features
    signature2 = private_key.sign_recoverable(b"Hello World!")
    result = result & public_key.verify_recoverable(b"Hello World!", signature2, public_key.pubkey)
    recovered_key = private_key.recover(b"Hello World!", signature2)
    verify_recovered = recovered_key == public_key.pubkey
    result = result & verify_recovered

    if result:
        print("Falcon-512 signing and verification process successful!")
        length_pk = 0
        for i in range(0, len(private_key.key.h)):
            length_pk += ((private_key.key.h[i].bit_length() + 7) // 8)
        print(f"Length of the public key: {length_pk}.")

        length_sk = 0
        length_G = 0

        for i in range(0, len(private_key.key.f)):
            length_sk += ((private_key.key.f[i].bit_length() + 7) // 8)
            length_sk += ((private_key.key.g[i].bit_length() + 7) // 8)
            length_sk += ((private_key.key.F[i].bit_length() + 7) // 8)
            length_sk += ((private_key.key.G[i].bit_length() + 7) // 8)
            length_G += ((private_key.key.G[i].bit_length() + 7) // 8)

        print(f"Length of the private key (total): {length_sk}.")
        print(f"Length of the private key (reduced): {length_sk - length_G}.")
        print(f"Length of the signature (classic): {len(signature1)}.")
        print(f"Length of the signature (recover): {len(signature2)}.")
        print("--------------------------------------------------")
    else:
        print("Falcon-512 signing and verification process unsuccessful!")

# Testing of the Falcon-1024 prototype
def test_falcon1024():
    keys = Transparent_Prototype_Falcon.generateKeyPair(1024)
    public_key = keys[0]
    private_key = keys[1]

    # Testing classic sign/verify features
    signature1 = private_key.sign(b"Hello World!")
    result = public_key.verify(b"Hello World!", signature1)

    # Testing the recoverable features
    signature2 = private_key.sign_recoverable(b"Hello World!")
    result = result & public_key.verify_recoverable(b"Hello World!", signature2, public_key.pubkey)
    recovered_key = private_key.recover(b"Hello World!", signature2)
    verify_recovered = recovered_key == public_key.pubkey
    result = result & verify_recovered

    if result:
        print("Falcon-1024 signing and verification process successful!")
        length_pk = 0
        for i in range(0, len(private_key.key.h)):
            length_pk += ((private_key.key.h[i].bit_length() + 7) // 8)
        print(f"Length of the public key: {length_pk}.")

        length_sk = 0
        length_G = 0

        for i in range(0, len(private_key.key.f)):
            length_sk += ((private_key.key.f[i].bit_length() + 7) // 8)
            length_sk += ((private_key.key.g[i].bit_length() + 7) // 8)
            length_sk += ((private_key.key.F[i].bit_length() + 7) // 8)
            length_sk += ((private_key.key.G[i].bit_length() + 7) // 8)
            length_G += ((private_key.key.G[i].bit_length() + 7) // 8)

        print(f"Length of the private key (total): {length_sk}.")
        print(f"Length of the private key (reduced): {length_sk - length_G}.")
        print(f"Length of the signature (classic): {len(signature1)}.")
        print(f"Length of the signature (recover): {len(signature2)}.")
        print("--------------------------------------------------")
    else:
        print("Falcon-1024 signing and verification process unsuccessful!")

# Testing of the EdDSA prototype
def test_eddsa():
    keys = Sprout_Prototype_EdDSA.generateKeyPair()
    public_key = keys[0]
    private_key = keys[1]
    signature = private_key.sign(b"Hello World!")
    result = public_key.verify(b"Hello World!", signature)
    if result:
        print("EdDSA signing and verification process successful!")
        print(f"Length of the public key: {public_key.pubkey.baselen}.")
        print(f"Length of the private key: {private_key.key.baselen}.")
        print(f"Length of the signature: {len(signature)}.")
        print("--------------------------------------------------")        
    else:
        print("EdDSA signing and verification process unsuccessful!")


# Execution of all functionality tests which can be validated by the output in the console
if __name__ == "__main__":
    test_ecdsa()
    test_falcon512()
    test_falcon1024()
    test_eddsa()