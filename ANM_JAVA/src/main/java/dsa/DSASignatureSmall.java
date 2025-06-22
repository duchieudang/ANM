package dsa;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.SecureRandom;

public class DSASignatureSmall {

    // Băm thông điệp thành BigInteger
    public static BigInteger hashMessage(String message, String algorithm) throws Exception {
        MessageDigest md = MessageDigest.getInstance(algorithm);
        byte[] hashBytes = md.digest(message.getBytes("UTF-8"));
        return new BigInteger(1, hashBytes);
    }

    // Băm chữ ký (r, s) thành chuỗi hex (chuẩn SHA dùng để hiển thị)
    public static String hashSignature(BigInteger r, BigInteger s, String algorithm) throws Exception {
        MessageDigest md = MessageDigest.getInstance(algorithm);
        String input = r.toString() + s.toString();
        byte[] hashBytes = md.digest(input.getBytes("UTF-8"));

        StringBuilder hexString = new StringBuilder();
        for (byte b : hashBytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }

        return hexString.toString();
    }

    // Tính g = h^((p−1)/q) mod p
    public static BigInteger calculateG(BigInteger p, BigInteger q, BigInteger h) {
        return h.modPow(p.subtract(BigInteger.ONE).divide(q), p);
    }

    // Sinh số ngẫu nhiên k ∈ [1, q−1]
    public static BigInteger generateK(BigInteger q) {
        SecureRandom random = new SecureRandom();
        BigInteger k;
        do {
            k = new BigInteger(q.bitLength(), random);
        } while (k.compareTo(BigInteger.ONE) < 0 || k.compareTo(q) >= 0);
        return k;
    }

    // Ký thông điệp
    public static BigInteger[] sign(String message, BigInteger p, BigInteger q, BigInteger g,
                                    BigInteger x, BigInteger k, String hashAlg) throws Exception {
        BigInteger r = g.modPow(k, p).mod(q);
        if (r.equals(BigInteger.ZERO)) throw new IllegalArgumentException("r = 0, chọn k khác");

        BigInteger h = hashMessage(message, hashAlg);
        BigInteger kInv = k.modInverse(q);
        BigInteger s = kInv.multiply(h.add(x.multiply(r))).mod(q);
        if (s.equals(BigInteger.ZERO)) throw new IllegalArgumentException("s = 0, chọn k khác");

        return new BigInteger[]{r, s};
    }

    // Xác thực chữ ký
    public static boolean verify(String message, BigInteger p, BigInteger q, BigInteger g,
                                 BigInteger y, BigInteger r, BigInteger s, String hashAlg) throws Exception {
        if (r.compareTo(BigInteger.ONE) < 0 || r.compareTo(q) >= 0) return false;
        if (s.compareTo(BigInteger.ONE) < 0 || s.compareTo(q) >= 0) return false;

        BigInteger w = s.modInverse(q);
        BigInteger h = hashMessage(message, hashAlg);
        BigInteger u1 = h.multiply(w).mod(q);
        BigInteger u2 = r.multiply(w).mod(q);

        BigInteger v = g.modPow(u1, p).multiply(y.modPow(u2, p)).mod(p).mod(q);
        return v.equals(r);
    }

    // Demo nhanh
    public static void main(String[] args) throws Exception {
        // DSA nhỏ (~<32 bit)
        BigInteger p = new BigInteger("7879");
        BigInteger q = new BigInteger("101");
        BigInteger h = new BigInteger("2");

        BigInteger g = calculateG(p, q, h);
        BigInteger x = new BigInteger("45"); // private key
        BigInteger y = g.modPow(x, p);       // public key
        BigInteger k = generateK(q);         // số k ngẫu nhiên

        String message = "Hello DSA small";
        String hashAlg = "SHA-256";

        BigInteger[] sig = sign(message, p, q, g, x, k, hashAlg);
        System.out.println("r = " + sig[0]);
        System.out.println("s = " + sig[1]);

        boolean valid = verify(message, p, q, g, y, sig[0], sig[1], hashAlg);
        System.out.println("✅ Chữ ký hợp lệ? " + valid);

        String sigHash = hashSignature(sig[0], sig[1], hashAlg);
        System.out.println("🔐 Hash chữ ký: " + sigHash);
    }
}
