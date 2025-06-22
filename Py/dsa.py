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
    g = pow(h, (p - 1) // q, p)
    if g <= 1:
        raise ValueError("Không tính được g hợp lệ. Thử h khác.")
    return g


def generate_k(q):
    return random.randint(1, q - 1)


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


# Miller-Rabin primality test
def is_prime(n, k=10):
    if n in (2, 3): return True
    if n <= 1 or n % 2 == 0: return False

    r, s = 0, n - 1
    while s % 2 == 0:
        r += 1
        s //= 2

    for _ in range(k):
        a = random.randrange(2, n - 1)
        x = pow(a, s, n)
        if x in (1, n - 1):
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True
