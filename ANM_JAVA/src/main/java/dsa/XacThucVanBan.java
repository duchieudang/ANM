package dsa;

import java.io.IOException;
import java.math.BigInteger;
import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/xtsign")
public class XacThucVanBan extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        try {
            // ======= 1. Lấy dữ liệu từ form =======
            String content = request.getParameter("message2");
            String content2 = request.getParameter("vbg");
            if (content == null || content.trim().isEmpty()) content = content2;

            String hamBam = request.getParameter("bam");
            BigInteger p = new BigInteger(request.getParameter("p"));
            BigInteger q = new BigInteger(request.getParameter("q"));
            BigInteger g = new BigInteger(request.getParameter("g"));
            BigInteger h = new BigInteger(request.getParameter("h"));
            BigInteger x = new BigInteger(request.getParameter("x"));
            BigInteger y = new BigInteger(request.getParameter("y"));
            BigInteger k = new BigInteger(request.getParameter("k"));
            BigInteger r = new BigInteger(request.getParameter("r"));
            BigInteger s = new BigInteger(request.getParameter("s"));
            BigInteger r2 = new BigInteger(request.getParameter("r2"));
            System.out.println(r2);
            BigInteger s2 = new BigInteger(request.getParameter("s2"));
            String signatureHash = request.getParameter("signatureHash");

            // ======= 2. Chọn phiên bản xác thực phù hợp (small / large) =======
            boolean isValid;
            if (p.bitLength() > 40 || q.bitLength() > 40) {
                // Xác thực bằng phiên bản "Lớn"
                isValid = DSASignatureLarge.verify(content, p, q, g, y, r2, s2, hamBam);
                System.out.println(isValid);
            } else {
                // Xác thực bằng phiên bản "Nhỏ"
                isValid = DSASignatureSmall.verify(content, p, q, g, y, r2, s2, hamBam);
            }

            // ======= 3. So sánh thủ công r, s =======
            boolean isRMatch = r.equals(r2);
            boolean isSMatch = s.equals(s2);

            // ======= 4. Gửi dữ liệu sang JSP =======
            request.setAttribute("bam", hamBam);
            request.setAttribute("message2", content);
            request.setAttribute("message", content2);
            request.setAttribute("p", p.toString());
            request.setAttribute("q", q.toString());
            request.setAttribute("g", g.toString());
            request.setAttribute("h", h.toString());
            request.setAttribute("x", x.toString());
            request.setAttribute("y", y.toString());
            request.setAttribute("k", k.toString());
            request.setAttribute("r", r.toString());
            request.setAttribute("s", s.toString());
            request.setAttribute("r2", r2.toString());
            request.setAttribute("s2", s2.toString());
            request.setAttribute("signatureHash", signatureHash);

            request.setAttribute("status", isValid ? "Hợp lệ" : "Không hợp lệ");
            request.setAttribute("xacThucKetQua", isValid ? "Chữ ký hợp lệ." : "Văn bản đã bị thay đổi hoặc sai chữ ký.");
            request.setAttribute("rMatch", isRMatch ? "r khớp." : "r không khớp.");
            request.setAttribute("sMatch", isSMatch ? "s khớp." : "s không khớp.");


            request.getRequestDispatcher("result.jsp").forward(request, response);

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Lỗi xử lý DSA: " + e.getMessage());
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
}
