<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
<head>
<meta charset="UTF-8">
<title>Kết quả DSA</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<style>
.card-title {
	font-size: 1.8rem;
	font-weight: bold;
}

.section-title {
	font-weight: bold;
	font-size: 1.1rem;
	margin-bottom: 8px;
}

.bg-section {
	background-color: #f8f9fa;
	border-radius: 8px;
	padding: 15px;
}
</style>
</head>
<body class="bg-light">
	<div class="container mt-5">
		<div class="card shadow p-4">
			<h2 class="card-title text-center mb-4">🔐 Kết quả ký và xác
				thực DSA</h2>
			<div class="row">
				<!-- Cột 1: Thông tin đã ký -->
				<div class="col-md-6 border-end">
					<div class="mb-4">
						<div class="section-title">📄 Văn bản đã ký:</div>
						<pre class="bg-section border p-3"
							style="max-height: 300px; overflow: auto; white-space: pre-wrap;">${message}</pre>
					</div>

					<div class="mb-4">
						<div class="section-title">✍️ Giá trị chữ ký (r, s):</div>
						<div class="row">
							<div class="col-md-6">
								<div class="bg-section border p-2">
									<strong>r =</strong> ${r}
								</div>
							</div>
							<div class="col-md-6">
								<div class="bg-section border p-2">
									<strong>s =</strong> ${s}
								</div>
							</div>
						</div>
					</div>
				</div>

				<!-- Cột 2: Form xác thực -->
				<div class="col-md-6">
					<div class="section-title mb-3">🔎 Form xác thực chữ ký</div>
					<form action="xtsign" method="post">
						<!-- Hidden fields -->
							<input type="hidden" name="p" value="${p}">
							<input type="hidden" name="vbg" value="${message}">							
						<input type="hidden" name="q" value="${q}">
						<input type="hidden" name="g" value="${g}">
						<input type="hidden" name="x" value="${x}">
						<input type="hidden" name="y" value="${y}">
						<input type="hidden" name="k" value="${k}">
						<input type="hidden" name="bam" value="${bam}">
				<input type="hidden" name="r" value="${r}">
						<input type="hidden" name="s" value="${s}">

						<div class="row mb-3">
    <div class="col-md-6">
        <label for="rInput" class="form-label">🔢 Nhập r</label>
        <input type="number" name="r2" id="rInput" class="form-control"
               value="${empty r2 ? r : r2}" required>
    </div>
    <div class="col-md-6">
        <label for="sInput" class="form-label">🔢 Nhập s</label>
        <input type="number" name="s2" id="sInput" class="form-control"
               value="${empty s2 ? s : s2}" required>
    </div>
</div>



						<div class="mb-3">
							<label for="messageInput" class="form-label">📝 Nhập văn
								bản cần xác thực</label>
							<textarea name="message2" rows="5" id="messageInput"
								class="form-control"
								placeholder="Nhập nội dung cần xác thực ở đây..." required>${message2}</textarea>
						</div>


						<div class="d-grid">
							<button type="submit" class="btn btn-success">✅ Xác thực</button>
						</div>
						<!-- Thông báo kết quả xác thực -->
						

					</form>
						<c:if test="${not empty xacThucKetQua}">
							<c:choose>
								<c:when test="${rMatch != 'r khớp.'}">
									<div class="alert alert-danger text-center">
										❌ <strong>Giá trị <code>r</code> không đúng!
										</strong><br> Vui lòng nhập lại
									</div>
								</c:when>
								<c:when test="${sMatch != 's khớp.'}">
									<div class="alert alert-danger text-center">
										❌ <strong>Giá trị <code>s</code> không đúng!
										</strong><br> Vui lòng nhập lại
									</div>
								</c:when>
								<c:when test="${status == 'Hợp lệ'}">
									<div class="alert alert-success text-center">
										✅ <strong>Chữ ký đã được xác thực thành công.</strong>
									</div>
								</c:when>
								<c:otherwise>
									<div class="alert alert-warning text-center">
										⚠️ <strong>Văn bản đã bị thay đổi.</strong><br> Vui lòng nhập lại
									</div>
								</c:otherwise>
							</c:choose>
						</c:if>
				</div>
			
			</div>

			<!-- Nút quay lại -->
			<div class="text-center mt-5">
				<a href="index.jsp" class="btn btn-secondary px-4">🔙 Quay lại</a>
			</div>
		</div>
	</div>
</body>
</html>
