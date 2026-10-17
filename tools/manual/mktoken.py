import sys, json, base64, hmac, hashlib, time, os

key = bytes.fromhex(open(os.environ["SECRET_FILE"]).read().strip())
HASHES = {"HS256": hashlib.sha256, "HS384": hashlib.sha384, "HS512": hashlib.sha512}

def b64(raw):
    return base64.urlsafe_b64encode(raw).rstrip(b"=").decode()

def enc(obj):
    return b64(json.dumps(obj, separators=(",", ":")).encode())

def sign(alg, payload):
    head, body = enc({"alg": alg}), enc(payload)
    sig = hmac.new(key, (head + "." + body).encode(), HASHES[alg]).digest()
    return head + "." + body + "." + b64(sig)

now = int(time.time())
payload = {"sub": "1", "iss": "webservice-class", "aud": ["board-api"], "iat": now, "exp": now + 300}
case = sys.argv[1]
alg = "HS256"

if case == "valid":
    pass
elif case == "alg_hs512":
    alg = "HS512"
elif case == "alg_none":
    print(enc({"alg": "none"}) + "." + enc(payload) + ".")
    sys.exit()
elif case == "iss_wrong":
    payload["iss"] = "other-issuer"
elif case == "aud_wrong":
    payload["aud"] = ["other-api"]
elif case == "iss_missing":
    del payload["iss"]
elif case == "exp_missing":
    del payload["exp"]
elif case == "sub_missing":
    del payload["sub"]
elif case == "sub_nouser":
    payload["sub"] = "999"
elif case == "sub_text":
    payload["sub"] = "abc"
elif case == "sub_leading_zero":
    payload["sub"] = "01"
elif case == "sub_number":
    payload["sub"] = 1
else:
    sys.exit("알 수 없는 케이스: " + case)

print(sign(alg, payload))
