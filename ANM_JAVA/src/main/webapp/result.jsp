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

<!-- Thư viện đọc file -->
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.14.305/pdf.min.js"></script>
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.14.305/pdf.worker.min.js"></script>
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script
	src="https://cdnjs.cloudflare.com/ajax/libs/mammoth/1.5.1/mammoth.browser.min.js"></script>
</head>

<body class="bg-light">
	<div class="container">
		<div class="card shadow p-4">
			<h2 class="card-title text-center mb-4">🔐 Kết quả ký và xác
				thực DSA</h2>
			<div class="row">
				<!-- Cột 1 -->
				<div class="col-md-6 border-end">
					<div class="section-title mb-3">🔎 Kết quả ký</div>
					<div class="mb-4">
						<div class="section-title">📄 Văn bản đã ký:</div>
						<textarea readonly class="form-control bg-section border"
							rows="10" style="white-space: pre-wrap;">${message}</textarea>
					</div>
					<div class="mb-4">
						<div class="section-title">✍️ Giá trị chữ ký (r, s):</div>
						<div class="row">
							<div class="col-md-4">
								<div class="bg-section border p-2"
									style="word-break: break-all;">
									<strong>r =</strong> <span>${r}</span>
								</div>
							</div>
							<div class="col-md-4">
								<div class="bg-section border p-2"
									style="word-break: break-all;">
									<strong>s =</strong> <span>${s}</span>
								</div>
							</div>
							<div class="col-md-4">
								<button onclick="downloadRS()"
									class="btn btn-outline-primary w-100">💾 Tải r, s</button>
							</div>
						</div>
					</div>

				</div>

				<!-- Cột 2 -->
				<div class="col-md-6">
					<div class="section-title mb-3">🔎 Xác thực chữ ký</div>
					<form action="xtsign" method="post">
						<!-- Hidden fields -->
						<input type="hidden" name="p" value="${p}"> <input
							type="hidden" name="vbg" value="<c:out value='${message}'/>">
						<input type="hidden" name="q" value="${q}"> <input
							type="hidden" name="g" value="${g}"> <input type="hidden"
							name="h" value="${h}" /> <input type="hidden" name="x"
							value="${x}"> <input type="hidden" name="y" value="${y}">
						<input type="hidden" name="k" value="${k}"> <input
							type="hidden" name="bam" value="${bam}"> <input
							type="hidden" name="r" value="${r}"> <input type="hidden"
							name="s" value="${s}">

						<!-- Nhập r, s -->
						<div class="row mb-3">
							<div class="col-md-4">
								<label for="rInput" class="form-label">🔢 Nhập r</label> <input
									type="text" name="r2" id="rInput" class="form-control"
									value="${empty r2 ? r : r2}" required
									oninput="sanitizeNumber(this)">
							</div>
							<div class="col-md-4">
								<label for="sInput" class="form-label">🔢 Nhập s</label> <input
									type="text" name="s2" id="sInput" class="form-control"
									value="${empty s2 ? s : s2}" required
									oninput="sanitizeNumber(this)">
							</div>
							<div class="col-md-4">
								<label for="rsFile" class="form-label">📄 Tải file chứa
									r, s (.txt)</label> <input type="file" id="rsFile" accept=".txt"
									class="form-control">
							</div>
						</div>

						<!-- Tải nội dung -->
						<div class="mb-3">
							<label class="form-label">📎 Tải file nội dung (.txt,
								.docx, .pdf, .xlsx):</label> <input type="file" class="form-control"
								id="fileInput2" accept=".txt,.docx,.pdf,.xlsx" />
						</div>

						<div class="mb-3">
							<label class="form-label">✏️ Nội dung cần xác thực</label>
							<c:choose>
								<c:when test="${not empty message2}">
									<textarea name="message2" rows="7" class="form-control"
										placeholder="Nhập nội dung cần xác thực..." required>${message2}</textarea>
								</c:when>
								<c:otherwise>
									<textarea name="message2" rows="7" class="form-control"
										placeholder="Nhập nội dung cần xác thực..." required>${message}</textarea>
								</c:otherwise>
							</c:choose>

						</div>

						<!-- Nút xác thực -->
						<div class="d-grid">
							<button type="submit" class="btn btn-success">✅ Xác thực</button>
						</div>
					</form>

					<!-- Kết quả xác thực -->
					<c:if test="${not empty xacThucKetQua}">
						<c:choose>
							<c:when test="${rMatch != 'r khớp.' and sMatch != 's khớp.'}">
								<div class="alert alert-danger text-center mt-3">
									❌ <strong>Giá trị <code>r</code> và <code>s</code> đều
										không đúng!
									</strong>
								</div>
							</c:when>
							<c:when test="${rMatch != 'r khớp.'}">
								<div class="alert alert-danger text-center mt-3">
									❌ <strong>Giá trị <code>r</code> không đúng!
									</strong>
								</div>
							</c:when>
							<c:when test="${sMatch != 's khớp.'}">
								<div class="alert alert-danger text-center mt-3">
									❌ <strong>Giá trị <code>s</code> không đúng!
									</strong>
								</div>
							</c:when>
							<c:when test="${status == 'Hợp lệ'}">
								<div class="alert alert-success text-center mt-3">
									✅ <strong>Chữ ký đã được xác thực thành công.</strong>
								</div>
							</c:when>
							<c:otherwise>
								<div class="alert alert-warning text-center mt-3">
									⚠️ <strong>Văn bản đã bị thay đổi.</strong>
								</div>
							</c:otherwise>
						</c:choose>
					</c:if>

				</div>
			</div>

			<!-- Nút quay lại -->
			<form action="quaylai" method="post">
				<input type="hidden" name="bam" value="${bam}" /> <input
					type="hidden" name="message" value="<c:out value='${message}'/>">
				<input type="hidden" name="p" value="${p}" /> <input type="hidden"
					name="q" value="${q}" /> <input type="hidden" name="g"
					value="${g}" /> <input type="hidden" name="h" value="${h}" /> <input
					type="hidden" name="x" value="${x}" /> <input type="hidden"
					name="y" value="${y}" /> <input type="hidden" name="k"
					value="${k}" />
				<div class="text-center mt-5">
					<button type="submit" class="btn btn-secondary px-4">🔙
						Quay lại</button>
				</div>
			</form>
		</div>
	</div>

	<!-- Script xử lý tải và đọc file -->
	<script>
pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.14.305/pdf.worker.min.js';

document.addEventListener("DOMContentLoaded", function () {
	// Đọc nội dung văn bản từ file
	document.getElementById("fileInput2").addEventListener("change", function () {
		const file = this.files[0];
		if (!file) return;

		const textarea = document.querySelector("textarea[name='message2']"); // ✅ textarea cần hiển thị nội dung
		const reader = new FileReader();
		const ext = file.name.split('.').pop().toLowerCase();

		if (ext === "txt") {
			reader.onload = () => textarea.value = reader.result;
			reader.readAsText(file);
		} else if (ext === "docx") {
			reader.onload = function (event) {
				mammoth.extractRawText({ arrayBuffer: event.target.result })
					.then(result => textarea.value = result.value)
					.catch(() => alert("Không thể đọc file .docx"));
			};
			reader.readAsArrayBuffer(file);
		} else if (ext === "pdf") {
			reader.onload = function (e) {
				const typedarray = new Uint8Array(e.target.result);
				pdfjsLib.getDocument(typedarray).promise.then(pdf => {
					const promises = [];
					for (let i = 1; i <= pdf.numPages; i++) {
						promises.push(pdf.getPage(i).then(page => page.getTextContent()));
					}
					Promise.all(promises).then(pages => {
						const text = pages.map(content =>
							content.items.map(item => item.str).join(' ')
						).join('\n');
						textarea.value = text;
					});
				}).catch(() => alert("Không thể đọc file PDF."));
			};
			reader.readAsArrayBuffer(file);
		} else if (ext === "xlsx") {
			reader.onload = function (e) {
				try {
					const data = new Uint8Array(e.target.result);
					const workbook = XLSX.read(data, { type: 'array' });
					let result = "";
					workbook.SheetNames.forEach(name => {
						const sheet = workbook.Sheets[name];
						result += XLSX.utils.sheet_to_csv(sheet);
					});
					textarea.value = result;
				} catch {
					alert("Không thể đọc file Excel.");
				}
			};
			reader.readAsArrayBuffer(file);
		} else {
			alert("Định dạng không hỗ trợ. Chỉ hỗ trợ .txt, .docx, .pdf, .xlsx");
		}
	});

	// Đọc file chứa r, s
	document.getElementById("rsFile").addEventListener("change", function () {
		const file = this.files[0];
		if (!file) return;

		const reader = new FileReader();
		reader.onload = function (e) {
			const content = e.target.result.trim();
			const lines = content.split(/\r?\n/).map(l => l.trim());
			if (lines.length >= 2) {
				document.getElementById("rInput").value = lines[0].split('=').pop().trim();
				document.getElementById("sInput").value = lines[1].split('=').pop().trim();
			} else {
				alert("File phải chứa r và s theo định dạng: r = ... và s = ...");
			}
		};
		reader.readAsText(file);
	});
});

// Tải file r, s
function downloadRS() {
	const r = "${r}";
	const s = "${s}";
	const content = `r = ${r}\ns = ${s}`;
	const blob = new Blob([content], { type: 'text/plain;charset=utf-8' });
	const link = document.createElement('a');
	link.href = URL.createObjectURL(blob);
	link.download = "chuky_dsa.txt";
	link.click();
}
//Hàm chỉ cho phép nhập chữ số
function sanitizeNumber(input) {
	// Loại bỏ ký tự không phải số
	input.value = input.value.replace(/[^0-9]/g, '');
}

</script>
</body>
</html>
