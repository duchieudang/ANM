package dsa;

import java.io.IOException;
import java.math.BigInteger;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/quaylai")
public class QuayLaiDSAServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		 response.setContentType("text/html;charset=UTF-8");
	        request.setCharacterEncoding("UTF-8");
		// Lấy các tham số từ form ẩn
		String bam = request.getParameter("bam");
		String message = request.getParameter("message");

		BigInteger p = new BigInteger(request.getParameter("p"));
		BigInteger q = new BigInteger(request.getParameter("q"));
		BigInteger g = new BigInteger(request.getParameter("g"));
		BigInteger h = new BigInteger(request.getParameter("h"));
		BigInteger x = new BigInteger(request.getParameter("x"));
		BigInteger y = new BigInteger(request.getParameter("y"));
		BigInteger k = new BigInteger(request.getParameter("k"));


		// Đặt lại các giá trị vào request để chuyển tiếp sang trang JSP
		request.setAttribute("bam", bam);
		request.setAttribute("tin", message);
		request.setAttribute("p", p);
		request.setAttribute("q", q);
		request.setAttribute("g", g);
		request.setAttribute("h", h);
		request.setAttribute("x", x);
		request.setAttribute("y", y);
		request.setAttribute("k", k);


		// Chuyển tiếp về lại trang JSP
		request.getRequestDispatcher("index.jsp").forward(request, response);
	}
}
