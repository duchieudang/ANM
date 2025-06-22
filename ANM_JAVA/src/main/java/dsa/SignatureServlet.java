package dsa;

import java.io.IOException;
import java.math.BigInteger;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/xuly-dsa")
public class SignatureServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        try {
            // 1. Lấy dữ liệu từ form
            String hamBam = request.getParameter("bam");
            String message = request.getParameter("message");

            BigInteger p = new BigInteger(request.getParameter("p"));
            BigInteger q = new BigInteger(request.getParameter("q"));
            BigInteger g = new BigInteger(request.getParameter("g"));
            BigInteger h = new BigInteger(request.getParameter("h"));
            BigInteger x = new BigInteger(request.getParameter("x"));
            BigInteger y = new BigInteger(request.getParameter("y"));
            BigInteger k = new BigInteger(request.getParameter("k"));

            BigInteger r, s;
            String signatureHash;

            // 2. Phân nhánh xử lý theo bitLength
            if (p.bitLength() > 40 || q.bitLength() > 40) {
                // Dùng DSA "Lớn"
                BigInteger[] signature = DSASignatureLarge.sign(message, p, q, g, x, hamBam);
                r = signature[0];
                s = signature[1];
                signatureHash = DSASignatureLarge.hashMessage(r.toString() + s.toString(), hamBam).toString(16);
            } else {
                // Dùng DSA "Nhỏ"
                BigInteger[] signature = DSASignatureSmall.sign(message, p, q, g, x, k, hamBam);
                r = signature[0];
                s = signature[1];
                signatureHash = DSASignatureSmall.hashSignature(r, s, hamBam);
            }

            // 3. Đẩy dữ liệu sang JSP
            request.setAttribute("bam", hamBam);
            request.setAttribute("message", message);
            request.setAttribute("p", p);
            request.setAttribute("q", q);
            request.setAttribute("g", g);
            request.setAttribute("h", h);
            request.setAttribute("x", x);
            request.setAttribute("y", y);
            request.setAttribute("k", k);
            request.setAttribute("r", r);
            request.setAttribute("s", s);
            request.setAttribute("signatureHash", signatureHash);

            request.getRequestDispatcher("result.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Lỗi xử lý DSA: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
}
