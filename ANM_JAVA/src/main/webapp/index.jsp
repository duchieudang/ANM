<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
<head>
<meta charset="UTF-8">
<title>Kết quả DSA</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
input[readonly] {
	background-color: #e9ecef;
	color: #495057;
}
hr.vertical {
	border-left: 2px solid #dee2e6;
	height: 100%;
	position: absolute;
	left: 50%;
	top: 0;
}
</style>

<!-- Thư viện đọc file -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.14.305/pdf.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.14.305/pdf.worker.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/mammoth/1.5.1/mammoth.browser.min.js"></script>

<script>
pdfjsLib.GlobalWorkerOptions.workerSrc = 'https://cdnjs.cloudflare.com/ajax/libs/pdf.js/2.14.305/pdf.worker.min.js';

document.addEventListener("DOMContentLoaded", function () {
	document.getElementById("fileInput").addEventListener("change", function () {
		const file = this.files[0];
		if (!file) return;
		const textarea = document.querySelector("textarea[name='message']");
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
						const text = pages.map(content => content.items.map(item => item.str).join(' ')).join('\n');
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
});

function handleBitLengthChange() {
	const qBits = parseInt(document.getElementById("bitLengthSelector").value);
	document.getElementById("pBits").value = qBits * 4;
}

function getRandomBigInt(bits) {
	const bytes = Math.ceil(bits / 8);
	const array = new Uint8Array(bytes);
	crypto.getRandomValues(array);
	let hex = [...array].map(b => b.toString(16).padStart(2, '0')).join('');
	return BigInt('0x' + hex);
}

function modPow(base, exp, mod) {
	let result = 1n;
	base %= mod;
	while (exp > 0n) {
		if (exp % 2n === 1n) result = (result * base) % mod;
		exp /= 2n;
		base = (base * base) % mod;
	}
	return result;
}

function isProbablePrime(n, k = 5) {
	if (n < 2n || n % 2n === 0n) return false;
	let d = n - 1n;
	let s = 0n;
	while (d % 2n === 0n) {
		d /= 2n;
		s += 1n;
	}
	for (let i = 0; i < k; i++) {
		let a = 2n + getRandomBigInt(n.toString(2).length) % (n - 4n);
		let x = modPow(a, d, n);
		if (x === 1n || x === n - 1n) continue;
		let continueLoop = false;
		for (let r = 1n; r < s; r++) {
			x = modPow(x, 2n, n);
			if (x === 1n) return false;
			if (x === n - 1n) {
				continueLoop = true;
				break;
			}
		}
		if (!continueLoop) return false;
	}
	return true;
}

function generatePrime(bits) {
	while (true) {
		let p = getRandomBigInt(bits) | 1n;
		if (isProbablePrime(p)) return p;
	}
}

function generateP(q, pBits) {
	while (true) {
		let k = getRandomBigInt(pBits - q.toString(2).length);
		let p = q * k + 1n;
		if (isProbablePrime(p)) return p;
	}
}

function generateG(p, q) {
	const exp = (p - 1n) / q;
	let h;
	while (true) {
		h = getRandomBigInt(64);
		if (h < 10_000_000_000n) continue;
		const g = modPow(h, exp, p);
		if (g !== 1n) return { g, h };
	}
}

function generatePrivateKey(q) {
	return getRandomBigInt(q.toString(2).length - 1) % (q - 1n) + 1n;
}

function generatePublicKey(p, g, x) {
	return modPow(g, x, p);
}

function generateK(q) {
	return getRandomBigInt(q.toString(2).length) % (q - 1n) + 1n;
}

function generateDSAParams() {
	const qBits = parseInt(document.getElementById("bitLengthSelector").value);
	const pBits = parseInt(document.getElementById("pBits").value);
	const q = generatePrime(qBits);
	const p = generateP(q, pBits);
	const { g, h } = generateG(p, q);
	const x = generatePrivateKey(q);
	const y = generatePublicKey(p, g, x);
	const k = generateK(q);

	document.getElementById("inputQText").value = q.toString();
	document.getElementById("inputPText").value = p.toString();
	document.getElementById("inputHText").value = h.toString();
	document.getElementById("inputGText").value = g.toString();
	document.getElementById("inputXText").value = x.toString();
	document.getElementById("inputKText").value = k.toString();
	document.getElementById("inputYText").value = y.toString();
}

function validateAndComputeText() {
	try {
		const p = BigInt(document.getElementById("inputPText").value);
		const q = BigInt(document.getElementById("inputQText").value);
		const h = BigInt(document.getElementById("inputHText").value);
		const g = modPow(h, (p - 1n) / q, p);
		if (g === 1n) {
			alert("Giá trị g không hợp lệ (g = 1). Hãy chọn h khác.");
		} else {
			document.getElementById("inputGText").value = g.toString();
			alert("✅ Các tham số hợp lệ. g đã tính lại.");
		}
	} catch {
		alert("❌ Lỗi định dạng số nguyên lớn.");
	}
}

function clearTextForm() {
	["inputQText", "inputPText", "inputHText", "inputGText", "inputXText", "inputKText", "inputYText"].forEach(id => {
		document.getElementById(id).value = "";
	});
	document.querySelector("textarea[name='message']").value = "";
}
function isPrime(n) {
	n = BigInt(n);
	if (n < 2n) return false;
	if (n === 2n) return true;
	if (n % 2n === 0n) return false;

	const sqrt = BigInt(Math.floor(Math.sqrt(Number(n))));
	for (let i = 3n; i <= sqrt; i += 2n) {
		if (n % i === 0n) return false;
	}
	return true;
}

// Tính lũy thừa modulo: base^exp mod mod
function modExp(base, exp, mod) {
	base = base % mod;
	let result = 1n;
	while (exp > 0n) {
		if (exp % 2n === 1n) result = (result * base) % mod;
		base = (base * base) % mod;
		exp = exp / 2n;
	}
	return result;
}

// Hàm kiểm tra và tính toán g và y từ các giá trị nhập
function validateAndComputeText() {
	const p = BigInt(document.getElementById("inputPText").value);
	const q = BigInt(document.getElementById("inputQText").value);
	const h = BigInt(document.getElementById("inputHText").value);
	const x = BigInt(document.getElementById("inputXText").value);
	const k = BigInt(document.getElementById("inputKText").value);

	// Kiểm tra q là số nguyên tố
	if (!isPrime(q)) {
		alert("q không phải là số nguyên tố.");
		return;
	}

	// Kiểm tra p là số nguyên tố
	if (!isPrime(p)) {
		alert("p không phải là số nguyên tố.");
		return;
	}

	// Kiểm tra q có chia hết p - 1 không
	if ((p - 1n) % q !== 0n) {
		alert("p-1 không chia hết cho q.");
		return;
	}

	// Kiểm tra h thuộc (1, p-1)
	if (!(h > 1n && h < p - 1n)) {
		alert("h phải nằm trong khoảng (1, p - 1).");
		return;
	}

	// Kiểm tra x thuộc (0, q)
	if (!(x > 0n && x < q)) {
		alert("x phải nằm trong khoảng (0, q).");
		return;
	}

	// Kiểm tra k thuộc (0, q)
	if (!(k > 0n && k < q)) {
		alert("k phải nằm trong khoảng (0, q).");
		return;
	}

	// Tính g = h^((p - 1)/q) mod p
	const g = modExp(h, (p - 1n) / q, p);
	if (g <= 1n) {
		alert("Giá trị g không hợp lệ.");
		return;
	}

	// Tính y = g^x mod p
	const y = modExp(g, x, p);

	// Gán kết quả vào form
	document.getElementById("inputGText").value = g.toString();
	document.getElementById("inputYText").value = y.toString();
}


// Hàm chỉ cho phép nhập chữ số
function sanitizeNumber(input) {
	// Loại bỏ ký tự không phải số
	input.value = input.value.replace(/[^0-9]/g, '');
}


</script>
</head>
<body class="bg-light">
	<div class="container">
		<h2 class="text-center mb-4">🔐 Hệ thống ký số DSA</h2>
		<div class="card shadow p-4">
			<form method="post" action="xuly-dsa">
				<div class="row">
					<!-- Cột 1: Tham số DSA -->
					<div class="col-md-6 border-end">
						<h5 class="mb-3">📌 Tham số DSA</h5>
						<input type="hidden" id="pBits" value="640">
						<div class="row">
							<div class="col-md-12 mb-2">
								<label class="form-label">🔢 Chọn độ dài tham số q (bit) và p(q*4):</label>
								<select id="bitLengthSelector" onchange="handleBitLengthChange()" class="form-select">
										<option value="16">16 bit</option>
										<option value="32">32 bit</option>
									<option value="64">64 bit</option>
									<option value="128">128 bit</option>
									<option value="160" selected>160 bit</option>
									<option value="192">192 bit</option>
									<option value="224">256 bit</option>
									<option value="256">512 bit</option>
								</select>
							</div>
							<div class="col-md-6 mb-2">
								<label class="form-label">q (nguyên tố):</label>
								<input type="text" name="q" id="inputQText" class="form-control" value="${q}" oninput="sanitizeNumber(this)">

							</div>
							<div class="col-md-6 mb-2">
								<label class="form-label">p (nguyên tố):</label>
								<input type="text" name="p" id="inputPText" class="form-control" value="${p}" oninput="sanitizeNumber(this)">
							</div>
							<div class="col-md-6 mb-2">
								<label class="form-label">h (1 &lt; h &lt; p-1):</label>
								<input type="text" name="h" id="inputHText" class="form-control" value="${h}" oninput="sanitizeNumber(this)">
							</div>
							<div class="col-md-6 mb-2">
								<label class="form-label">x (0 &lt; x &lt; q):</label>
								<input type="text" name="x" id="inputXText" class="form-control" value="${x}" oninput="sanitizeNumber(this)">
							</div>
							<div class="col-md-6 mb-2">
								<label class="form-label">k (1 &lt; k &lt; q):</label>
								<input type="text" name="k" id="inputKText" class="form-control" value="${k}" oninput="sanitizeNumber(this)">
							</div>
							<div class="col-md-6 mb-2">
								<label class="form-label">g = h<sup>(p−1)/q</sup> mod p:</label>
								<input type="text" name="g" id="inputGText" class="form-control" value="${g}" readonly>
							</div>
							<div class="col-md-12 mb-3">
								<label class="form-label">y = g<sup>x</sup> mod p:</label>
								<input type="text" name="y" id="inputYText" class="form-control" value="${y}" readonly>
							</div>
						</div>
						<div class="row">
							<div class="col-md-4 mb-2">
								<button type="button" class="btn btn-warning w-100" onclick="validateAndComputeText()">🧪 Kiểm tra</button>
							</div>
							<div class="col-md-4 mb-2">
								<button type="button" class="btn btn-primary w-100" onclick="generateDSAParams()">🎲 Ngẫu nhiên</button>
							</div>
							<div class="col-md-4 mb-2">
								<button type="button" class="btn btn-danger w-100" onclick="clearTextForm()">🗑️ Xóa</button>
							</div>
						</div>
					</div>

					<!-- Cột 2: Nội dung cần ký -->
					<div class="col-md-6">
						<h5 class="mb-3">📝 Nội dung & hàm băm</h5>
						<div class="mb-3">
							<label class="form-label">🔗 Chọn hàm băm:</label>
							<select class="form-select" name="bam">
								<option value="MD5" <c:if test="${bam == 'MD5'}">selected</c:if>>MD5</option>
								<option value="SHA-1" <c:if test="${bam == 'SHA-1'}">selected</c:if>>SHA-1</option>
								<option value="SHA-224" <c:if test="${bam == 'SHA-224'}">selected</c:if>>SHA-224</option>
								<option value="SHA-256" <c:if test="${bam == 'SHA-256'}">selected</c:if>>SHA-256</option>
								<option value="SHA-384" <c:if test="${bam == 'SHA-384'}">selected</c:if>>SHA-384</option>
								<option value="SHA-512" <c:if test="${bam == 'SHA-512'}">selected</c:if>>SHA-512</option>
								<option value="SHA3-256" <c:if test="${bam == 'SHA3-256'}">selected</c:if>>SHA3-256</option>
								<option value="SHA3-512" <c:if test="${bam == 'SHA3-512'}">selected</c:if>>SHA3-512</option>
							</select>
						</div>

						<div class="mb-3">
							<label class="form-label">📎 Tải file nội dung (.txt, .docx, .pdf, .xlsx):</label>
							<input type="file" class="form-control" id="fileInput" accept=".txt,.docx,.pdf,.xlsx" />
						</div>

						<div class="mb-3">
							<label class="form-label">✏️ Nội dung cần ký:</label>
							<textarea name="message" rows="7" class="form-control" placeholder="Nhập nội dung cần ký..." required>${tin}</textarea>
						</div>
						<button type="submit" class="btn btn-success w-100">✅ Ký văn bản</button>
					</div>
				</div>
			</form>
		</div>
	</div>
</body>
</html>
