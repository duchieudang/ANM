package dsa;

import java.io.*;
import java.math.BigInteger;

import javax.servlet.*;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import org.apache.poi.xwpf.usermodel.*;
import org.apache.poi.xssf.usermodel.*;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;

@WebServlet("/xtupload")
@MultipartConfig
public class Xacthucupload extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        try {
            String hamBam = request.getParameter("bam");
       	 String content2 = request.getParameter("vbg");
            // Lấy các tham số
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
            Part filePart = request.getPart("file");
            String fileName = filePart.getSubmittedFileName();
            InputStream fileContent = filePart.getInputStream();
            String content = readFileContent(fileName, fileContent);

            // Kiểm tra xác thực chữ ký
            boolean isValid = DSASignature.verify(content, p, q, g, y, r2, s2, hamBam);

            // So sánh riêng r
         // So sánh trực tiếp r và r2, s và s2
            boolean isRMatch = r.equals(r2);
            boolean isSMatch = s.equals(s2);
   

            // Gửi dữ liệu sang JSP
            request.setAttribute("bam", hamBam);
            request.setAttribute("fileName", filePart.getSubmittedFileName());
            request.setAttribute("message", content2);
            request.setAttribute("message2", content);
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

            // Chuyển đến trang kết quả
            request.getRequestDispatcher("result.jsp").forward(request, response);

        } catch (Exception e) {
            throw new ServletException("Lỗi xử lý file hoặc tham số", e);
        }
    }

    private String readFileContent(String fileName, InputStream fileContent) throws Exception {
        String content = "";
        if (fileName.endsWith(".docx")) {
            try (XWPFDocument doc = new XWPFDocument(fileContent)) {
                StringBuilder sb = new StringBuilder();
                for (XWPFParagraph para : doc.getParagraphs()) {
                    sb.append(para.getText()).append("\n");
                }
                content = sb.toString();
            }
        } else if (fileName.endsWith(".pdf")) {
            try (PDDocument pdf = PDDocument.load(fileContent)) {
                PDFTextStripper stripper = new PDFTextStripper();
                content = stripper.getText(pdf);
            }
        } else if (fileName.endsWith(".xlsx")) {
            try (XSSFWorkbook workbook = new XSSFWorkbook(fileContent)) {
                StringBuilder sb = new StringBuilder();
                XSSFSheet sheet = workbook.getSheetAt(0);
                for (int i = sheet.getFirstRowNum(); i <= sheet.getLastRowNum(); i++) {
                    XSSFRow row = sheet.getRow(i);
                    if (row != null) {
                        for (int j = 0; j < row.getLastCellNum(); j++) {
                            if (row.getCell(j) != null) {
                                switch (row.getCell(j).getCellType()) {
                                    case STRING:
                                        sb.append(row.getCell(j).getStringCellValue());
                                        break;
                                    case NUMERIC:
                                        sb.append(row.getCell(j).getNumericCellValue());
                                        break;
                                    case BOOLEAN:
                                        sb.append(row.getCell(j).getBooleanCellValue());
                                        break;
                                    case FORMULA:
                                        sb.append(row.getCell(j).getCellFormula());
                                        break;
                                    default:
                                        sb.append("");
                                }
                                sb.append("\t");
                            }
                        }
                        sb.append("\n");
                    }
                }
                content = sb.toString();
            }
        } else {
            throw new ServletException("Chỉ hỗ trợ file .docx, .pdf hoặc .xlsx");
        }
        return content;
    }
}
