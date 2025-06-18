import hashlib
import random

def is_prime(n):
    """Kiểm tra số nguyên tố bằng thuật toán Miller-Rabin cơ bản."""
    if n < 2:
        return False
    if n in (2, 3):
        return True
    if n % 2 == 0:
        return False
    r, s = 0, n - 1
    while s % 2 == 0:
        r += 1
        s //= 2
    for _ in range(5):
        a = random.randrange(2, n - 1)
        x = pow(a, s, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True

def calculate_g(p, q, h):
    """Tính g = h^((p-1)/q) mod p"""
    if not (1 < h < p - 1):
        raise ValueError("h không hợp lệ")
    g = pow(h, (p - 1) // q, p)
    if g <= 1:
        raise ValueError("Không tìm được g hợp lệ")
    return g

def generate_k(q):
    """Sinh số k ngẫu nhiên (0 < k < q)"""
    return random.randint(1, q - 1)

def hash_message(message, hashAlg="SHA-256"):
    """Băm nội dung văn bản với thuật toán được chọn"""
    hashAlg = hashAlg.upper()
    if hashAlg == "SHA-1":
        h = hashlib.sha1()
    elif hashAlg == "SHA-256":
        h = hashlib.sha256()
    elif hashAlg == "SHA-512":
        h = hashlib.sha512()
    else:
        raise ValueError("Thuật toán băm không hỗ trợ!")
    h.update(message.encode("utf-8"))
    return int(h.hexdigest(), 16)

def sign(message, p, q, g, x, k, hashAlg="SHA-256"):
    """Tạo chữ ký DSA (r, s)"""
    H = hash_message(message, hashAlg)
    r = pow(g, k, p) % q
    if r == 0:
        raise ValueError("Không tạo được r hợp lệ. Chọn lại k.")
    try:
        k_inv = pow(k, -1, q)  # Python 3.8+
    except ValueError:
        raise ValueError("Không tìm được k⁻¹ trong mod q")
    s = (k_inv * (H + x * r)) % q
    if s == 0:
        raise ValueError("Không tạo được s hợp lệ. Chọn lại k.")
    return r, s

def verify(message, p, q, g, y, r, s, hashAlg="SHA-256"):
    """Xác thực chữ ký DSA"""
    if not (0 < r < q and 0 < s < q):
        return False
    H = hash_message(message, hashAlg)
    try:
        w = pow(s, -1, q)
    except ValueError:
        return False
    u1 = (H * w) % q
    u2 = (r * w) % q
    v = ((pow(g, u1, p) * pow(y, u2, p)) % p) % q
    return v == r
