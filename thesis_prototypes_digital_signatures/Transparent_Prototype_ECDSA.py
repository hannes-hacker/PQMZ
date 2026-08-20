import ecdsa
from Crypto.Hash import KangarooTwelve
from parameters import default_hash_function

#########################################################################################################
### This script represents the prototype of the ECDSA functionality in Zcash's "Transparent" protocol ###
#########################################################################################################

# Wrapper class for a public key object
class PublicKey:
    def __init__(self, secret_key):
        self.pubkey = secret_key.get_verifying_key()
        self.privkey = secret_key

    # Verification of an ECDSA signature
    def verify(self, message, signature):
        result = self.pubkey.verify(signature, message, hashfunc=default_hash_function)
        return result

    # Verification of an ECDSA signature in public-key recovery mode
    def verify_recoverable(self, message, signature):
        result = self.pubkey.verify(signature, message, hashfunc=default_hash_function)
        return result

# Wrapper class for a private key object
class PrivateKey:
    def __init__(self, n=None, polys=None):
        self.key = ecdsa.SigningKey.generate(ecdsa.SECP256k1) # Parameter "secp256k1" liked used in the Zcash codebase

    # Creation of an ECDSA signature on a message
    def sign(self, message):
        signature = self.key.sign(message, hashfunc=default_hash_function)
        return signature

    # Creation of an ECDSA signature on a message in public key recovery mode
    def sign_recoverable(self, message):
        signature = self.key.sign(message, hashfunc=default_hash_function)
        return signature

    # Recovery of a public key from an ECDSA signature
    def recover(self, message, signature):
        publickey = ecdsa.VerifyingKey.from_public_key_recovery(signature, message, ecdsa.SECP256k1, hashfunc=default_hash_function)
        return publickey

# Generation of an ECDSA public and private key pair
def generateKeyPair():
    private = PrivateKey()
    public = PublicKey(private.key)
    return public, private


