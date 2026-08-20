from falcon import falcon
from parameters import default_hash_function

####################################################################################################################
### This script represents the prototype of the potential Falcon functionality in Zcash's "Transparent" protocol ###
####################################################################################################################


# Wrapper class for a public key object
class PublicKey:
    def __init__(self, secret_key):
        self.pubkey = secret_key.key.h
        self.privkey = secret_key.key

    # Verification of a Falcon signature
    def verify(self, message, signature):
        result = self.privkey.verify(message, signature, hashfunc=default_hash_function)
        return result

    # Verification of a Falcon signature in public-key recovery mode
    def verify_recoverable(self, message, signature, pubkey):
        result = self.privkey.verify_recoverable(message, signature, pubkey)
        return result

# Wrapper class for a private key object
class PrivateKey:
    def __init__(self, n, polys=None):
        self.key = falcon.SecretKey(n, polys)

    # Creation of a Falcon signature on a message
    def sign(self, message):
        signature = self.key.sign(message, hashfunc=default_hash_function)
        return signature

    # Creation of a Falcon signature on a message in public key recovery mode
    def sign_recoverable(self, message):
        signature = self.key.sign_recoverable(message, hashfunc=default_hash_function)
        return signature

    # Recovery of a public key from a Falcon signature
    def recover(self, message, signature):
        publickey = self.key.recover(message, signature, hashfunc=default_hash_function)
        return publickey

# Generation of a Falcon public and private key pair
def generateKeyPair(n, polys=None):
    private = PrivateKey(n, polys)
    public = PublicKey(private)
    return public, private

