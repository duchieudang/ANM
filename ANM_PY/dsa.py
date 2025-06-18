import hashlib
import random

def hash_message(message, hashAlg="SHA-256"):
    hashAlg = hashAlg.upper()
    if hashAlg == "SHA-1":
        h = hashlib.sha1()
    elif hashAlg == "SHA-256":
        h = hashlib.sha256()
    elif hashAlg == "SHA-384":
        h = hashlib.sha384()
    elif hashAlg == "SHA-512":
        h = hashlib.sha512()
    else:
        raise ValueError("Thuật toán băm không hợp lệ.")
    
    h.update(message.encode('utf-8'))
    return int(h.hexdigest(), 16)

def calculate_g(p, q, h):
    return pow(h, (p - 1) // q, p)

def generate_k(q):
    while True:
        k = random.randint(1, q - 1)
        if 1 <= k < q:
            return k

def modinv(a, m):
    g, x, _ = extended_gcd(a, m)
    if g != 1:
        raise Exception("Không tìm được nghịch đảo modular")
    return x % m

def extended_gcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = extended_gcd(b % a, a)
        return (g, x - (b // a) * y, y)

def sign(message, p, q, g, x, k, hashAlg="SHA-256"):
    r = pow(g, k, p) % q
    if r == 0:
        raise ValueError("r = 0, chọn k khác.")
    h = hash_message(message, hashAlg)
    k_inv = modinv(k, q)
    s = (k_inv * (h + x * r)) % q
    if s == 0:
        raise ValueError("s = 0, chọn k khác.")
    return (r, s)

def verify(message, p, q, g, y, r, s, hashAlg="SHA-256"):
    if not (0 < r < q) or not (0 < s < q):
        return False
    w = modinv(s, q)
    h = hash_message(message, hashAlg)
    u1 = (h * w) % q
    u2 = (r * w) % q
    v = ((pow(g, u1, p) * pow(y, u2, p)) % p) % q
    return v == r

def is_prime(n):
    if n < 2: return False
    for i in range(2, int(n ** 0.5) + 1):
        if n % i == 0: return False
    return True
