package dsa;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.SecureRandom;

public class DSASignatureLarge {
    private static final SecureRandom random = new SecureRandom();

    // Biến toàn cục để truy xuất trong main
    public static BigInteger h;
    public static BigInteger k;

    public static BigInteger generatePrime(int bitLength) {
        return BigInteger.probablePrime(bitLength, random);
    }

    public static BigInteger generateP(BigInteger q, int pBitLength) {
        BigInteger kTemp, p;
        int certainty = 64;
        while (true) {
            kTemp = new BigInteger(pBitLength - q.bitLength(), random);
            p = q.multiply(kTemp).add(BigInteger.ONE);
            if (p.isProbablePrime(certainty)) return p;
        }
    }

    public static BigInteger generateG(BigInteger p, BigInteger q) {
        BigInteger exp = p.subtract(BigInteger.ONE).divide(q);

        while (true) {
            // Random h có ít nhất 11 chữ số (tức >= 10^10)
            h = new BigInteger(64, random); // 64-bit cho h là đủ > 10 chữ số
            if (h.compareTo(new BigInteger("10000000000")) < 0) continue; // bỏ nếu nhỏ hơn 10 chữ số

            BigInteger g = h.modPow(exp, p);
            if (!g.equals(BigInteger.ONE)) {
                return g;
            }
        }
    }


    public static BigInteger generatePrivateKey(BigInteger q) {
        return new BigInteger(q.bitLength() - 1, random).mod(q.subtract(BigInteger.ONE)).add(BigInteger.ONE);
    }

    public static BigInteger generatePublicKey(BigInteger p, BigInteger g, BigInteger x) {
        return g.modPow(x, p);
    }

    public static BigInteger hashMessage(String message, String algorithm) throws Exception {
        MessageDigest md = MessageDigest.getInstance(algorithm);
        byte[] hashBytes = md.digest(message.getBytes("UTF-8"));
        return new BigInteger(1, hashBytes);
    }

    public static BigInteger[] sign(String message, BigInteger p, BigInteger q, BigInteger g, BigInteger x, String hashAlgorithm) throws Exception {
        BigInteger r, s;
        BigInteger H = hashMessage(message, hashAlgorithm).mod(q);

        do {
            do {
                k = new BigInteger(q.bitLength(), random).mod(q.subtract(BigInteger.ONE)).add(BigInteger.ONE); // Lưu k toàn cục
                r = g.modPow(k, p).mod(q);
            } while (r.equals(BigInteger.ZERO));

            BigInteger kInv = k.modInverse(q);
            s = kInv.multiply(H.add(x.multiply(r))).mod(q);
        } while (s.equals(BigInteger.ZERO));

        return new BigInteger[]{r, s};
    }

    public static boolean verify(String message, BigInteger p, BigInteger q, BigInteger g, BigInteger y,
                                 BigInteger r, BigInteger s, String hashAlgorithm) throws Exception {
        if (r.compareTo(BigInteger.ZERO) <= 0 || r.compareTo(q) >= 0) return false;
        if (s.compareTo(BigInteger.ZERO) <= 0 || s.compareTo(q) >= 0) return false;

        BigInteger H = hashMessage(message, hashAlgorithm).mod(q);
        BigInteger w = s.modInverse(q);
        BigInteger u1 = H.multiply(w).mod(q);
        BigInteger u2 = r.multiply(w).mod(q);

        BigInteger v = g.modPow(u1, p).multiply(y.modPow(u2, p)).mod(p).mod(q);

        return v.equals(r);
    }

    public static void main(String[] args) throws Exception {
        for(int i=1;i<3;i++)
        {
    	int qBits = 192;
        
        int pBits = 384;

       
        BigInteger q = generatePrime(qBits);
        BigInteger p = generateP(q, pBits);
        BigInteger g = generateG(p, q);
        BigInteger x = generatePrivateKey(q);
        BigInteger y = generatePublicKey(p, g, x);

        String message = "Thông điệp cực kỳ quan trọng cần được bảo vệ!";
        String hashAlg = "SHA-256";

        BigInteger[] sig = sign(message, p, q, g, x, hashAlg);
        BigInteger r = sig[0], s = sig[1];

        System.out.println("q: " + q);
        System.out.println("p: " + p);
        System.out.println("g: " + g);
        System.out.println("x: " + x);
        System.out.println("y: " + y);
        System.out.println("h: " + h); // In h
        System.out.println("k: " + k); // In k

        }
    }
}
