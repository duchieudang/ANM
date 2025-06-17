package dsa;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.SecureRandom;

public class DSASignature {

    // Hàm băm linh hoạt (SHA-1, SHA-256, SHA-512)
    public static BigInteger hashMessage(String message, String algorithm) throws Exception {
        MessageDigest md = MessageDigest.getInstance(algorithm);
        byte[] hashBytes = md.digest(message.getBytes("UTF-8"));
        return new BigInteger(1, hashBytes);
    }

    // Hàm băm SHA từ r và s (nếu vẫn cần dùng)
    public static String hashSignature(BigInteger r, BigInteger s, String algorithm) throws Exception {
        MessageDigest sha = MessageDigest.getInstance(algorithm);
        String input = r.toString() + s.toString();
        byte[] hashBytes = sha.digest(input.getBytes("UTF-8"));

        StringBuilder hexString = new StringBuilder();
        for (byte b : hashBytes) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }

        return hexString.toString();
    }

    // Tính g = h^((p-1)/q) mod p
    public static BigInteger calculateG(BigInteger p, BigInteger q, BigInteger h) {
        return h.modPow(p.subtract(BigInteger.ONE).divide(q), p);
    }

    // Sinh ngẫu nhiên k trong [1, q-1]
    public static BigInteger generateK(BigInteger q) {
        SecureRandom random = new SecureRandom();
        BigInteger k;
        do {
            k = new BigInteger(q.bitLength(), random);
        } while (k.compareTo(BigInteger.ONE) < 0 || k.compareTo(q.subtract(BigInteger.ONE)) > 0);
        return k;
    }

    // Ký DSA
    public static BigInteger[] sign(String message, BigInteger p, BigInteger q, BigInteger g,
                                    BigInteger x, BigInteger k, String hashAlg) throws Exception {
        BigInteger r = g.modPow(k, p).mod(q);
        if (r.equals(BigInteger.ZERO)) {
            throw new IllegalArgumentException("r = 0, chọn k khác.");
        }

        BigInteger h = hashMessage(message, hashAlg);
        BigInteger kInv = k.modInverse(q);
        BigInteger s = (kInv.multiply(h.add(x.multiply(r)))).mod(q);
        if (s.equals(BigInteger.ZERO)) {
            throw new IllegalArgumentException("s = 0, chọn k khác.");
        }

        return new BigInteger[]{r, s};
    }

    // Chứng thực DSA thông thường
    public static boolean verify(String message, BigInteger p, BigInteger q, BigInteger g,
                                 BigInteger y, BigInteger r, BigInteger s, String hashAlg) throws Exception {
        if (r.compareTo(BigInteger.ONE) < 0 || r.compareTo(q.subtract(BigInteger.ONE)) > 0) return false;
        if (s.compareTo(BigInteger.ONE) < 0 || s.compareTo(q.subtract(BigInteger.ONE)) > 0) return false;

        BigInteger w = s.modInverse(q);
        BigInteger h = hashMessage(message, hashAlg);
        BigInteger u1 = h.multiply(w).mod(q);
        BigInteger u2 = r.multiply(w).mod(q);

        BigInteger v = g.modPow(u1, p).multiply(y.modPow(u2, p)).mod(p).mod(q);
        return v.equals(r);
    }

    // Hàm so sánh r
    public static boolean verifyR(String message, BigInteger p, BigInteger q, BigInteger g,
                                  BigInteger x, BigInteger expectedR, BigInteger k, String hashAlg) throws Exception {
        BigInteger actualR = g.modPow(k, p).mod(q);
        return actualR.equals(expectedR);
    }

    // Hàm so sánh s
    public static boolean verifyS(String message, BigInteger q, BigInteger x,
                                  BigInteger expectedR, BigInteger expectedS, BigInteger k, String hashAlg) throws Exception {
        BigInteger h = hashMessage(message, hashAlg);
        BigInteger kInv = k.modInverse(q);
        BigInteger actualS = (kInv.multiply(h.add(x.multiply(expectedR)))).mod(q);
        return actualS.equals(expectedS);
    }

    // MAIN DEMO
    public static void main(String[] args) throws Exception {
        // Tham số DSA mẫu
        BigInteger p = new BigInteger("7879");
        BigInteger q = new BigInteger("101");
        BigInteger h = new BigInteger("2");
        BigInteger g = calculateG(p, q, h);

        if (g.compareTo(BigInteger.ONE) <= 0) throw new Exception("g không hợp lệ, chọn lại h.");

        BigInteger x = new BigInteger("45"); // private key
        BigInteger y = g.modPow(x, p);       // public key
        BigInteger k = generateK(q);         // random k

        String message = "hello DSA";
        String hashAlg = "SHA-512";

        // Ký
        BigInteger[] signature = sign(message, p, q, g, x, k, hashAlg);
        BigInteger r = signature[0];
        BigInteger s = signature[1];

        System.out.println("Chữ ký:");
        System.out.println("r = " + r);
        System.out.println("s = " + s);

        // Kiểm tra chữ ký hợp lệ (cách chuẩn)
        boolean valid = verify(message, p, q, g, y, r, s, hashAlg);
        System.out.println("Chữ ký hợp lệ (thuật toán " + hashAlg + ")? " + valid);

        // So sánh riêng r
        boolean isRValid = verifyR(message, p, q, g, x, r, k, hashAlg);
        System.out.println("So sánh r đúng? " + isRValid);

        // So sánh riêng s
        boolean isSValid = verifyS(message, q, x, r, s, k, hashAlg);
        System.out.println("So sánh s đúng? " + isSValid);
    }
}
