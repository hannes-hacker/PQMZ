from falcon import falcon

###################################################################################################################
### This script determines how often rejection sampling is performed in Falcon's recoverable signature creation.###
###################################################################################################################

iterations = []

for i in range(0, 100):
    privkey = falcon.SecretKey(1024)
    pubkey = falcon.PublicKey(privkey)
    message = b"Hello World!"

    signature = privkey.sign_recoverable(message)
    iterations.append(signature[1])

print(max(iterations))