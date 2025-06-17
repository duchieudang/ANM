package dsa;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigInteger;

import javax.servlet.*;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/xtsign")
public class XacThucVanBan extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        try {
            // Lấy dữ liệu từ form
        	 String content = request.getParameter("message2");
        	 String content2 = request.getParameter("vbg");
        	 String hamBam = request.getParameter("bam");
        	 BigInteger p = new BigInteger(request.getParameter("p"));
             BigInteger q = new BigInteger(request.getParameter("q"));
             BigInteger g = new BigInteger(request.getParameter("g"));
             BigInteger x = new BigInteger(request.getParameter("x"));
             BigInteger y = new BigInteger(request.getParameter("y"));
             BigInteger k = new BigInteger(request.getParameter("k"));
             BigInteger r = new BigInteger(request.getParameter("r"));
             BigInteger s = new BigInteger(request.getParameter("s"));
             
             String signatureHash = request.getParameter("signatureHash");
             BigInteger r2 = new BigInteger(request.getParameter("r2"));
             BigInteger s2 = new BigInteger(request.getParameter("s2"));
             // Lấy file
          if(content==null) content=content2;

             // Kiểm tra xác thực chữ ký
             boolean isValid = DSASignature.verify(content, p, q, g, y, r2, s2, hamBam);

             // So sánh riêng r
          // So sánh trực tiếp r và r2, s và s2
             boolean isRMatch = r.equals(r2);
             boolean isSMatch = s.equals(s2);
   
             // Gửi dữ liệu sang JSP
             request.setAttribute("bam", hamBam);
         
             request.setAttribute("message2", content);
             request.setAttribute("message", content2);
             request.setAttribute("r", r.toString());
             request.setAttribute("s", s.toString());
             request.setAttribute("r2", r2.toString());
             request.setAttribute("s2", s2.toString());
             request.setAttribute("p", p.toString());
             request.setAttribute("q", q.toString());
             request.setAttribute("g", g.toString());
             request.setAttribute("x", x.toString());
             request.setAttribute("y", y.toString());
             request.setAttribute("k", k.toString());
             request.setAttribute("signatureHash", signatureHash);
             request.setAttribute("status", isValid ? "Hợp lệ" : "Không hợp lệ");

             // Kết quả xác thực và so sánh r, s
             request.setAttribute("xacThucKetQua", isValid ? "Chữ ký hợp lệ." : "Văn bản đã bị thay đổi.");
             request.setAttribute("rMatch", isRMatch ? "r khớp." : "r không khớp.");
             request.setAttribute("sMatch", isSMatch ? "s khớp." : "s không khớp.");

            request.getRequestDispatcher("result3.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý DSA", e);
        }
    }
}
