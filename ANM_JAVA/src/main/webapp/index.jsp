<%@ page contentType="text/html;charset=UTF-8"%>
<html>
<head>
<meta charset="UTF-8">
<title>Chữ ký số DSA</title>
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
	rel="stylesheet">
<style>
	input[readonly] {
		background-color: #e9ecef; /* giống bg-light */
		color: #495057;
	}
</style>

<script>
	function toggleForm() {
		const option = document.querySelector('input[name="signOption"]:checked').value;
		document.getElementById("textForm").style.display = (option === "text") ? "block" : "none";
		document.getElementById("fileForm").style.display = (option === "file") ? "block" : "none";
	}
	window.onload = toggleForm;

	function isPrime(num) {
		if (num < 2) return false;
		if (num === 2) return true;
		if (num % 2 === 0) return false;
		const sqrt = Math.floor(Math.sqrt(num));
		for (let i = 3; i <= sqrt; i += 2) {
			if (num % i === 0) return false;
		}
		return true;
	}

	function randomPrime(min, max) {
		let prime = 0;
		let attempts = 0;
		while (attempts < 10000) {
			const candidate = Math.floor(Math.random() * (max - min + 1)) + min;
			if (isPrime(candidate)) {
				prime = candidate;
				break;
			}
			attempts++;
		}
		return prime;
	}

	function modExp(base, exp, mod) {
		let result = 1;
		base = base % mod;
		while (exp > 0) {
			if (exp % 2 === 1) result = (result * base) % mod;
			base = (base * base) % mod;
			exp = Math.floor(exp / 2);
		}
		return result;
	}

	function generatePQ(minDigits = 6) {
		const min = Math.pow(10, minDigits - 1);
		const max = Math.pow(10, minDigits) * 10;
		let q, p;
		let attempts = 0;

		do {
			q = randomPrime(min, max);
			let found = false;
			for (let k = 2; k <= 10; k++) {
				const candidateP = q * k + 1;
				if (candidateP >= min && candidateP <= max && isPrime(candidateP)) {
					p = candidateP;
					found = true;
					break;
				}
			}
			attempts++;
			if (attempts > 1000) {
				alert("Không tìm được p, q thỏa mãn trong phạm vi cho phép. Vui lòng thử lại.");
				return null;
			}
		} while (!p);

		return { p, q };
	}
	function generatePQ(minDigits = 6) {
		const min = Math.pow(10, minDigits - 1);
		const max = Math.pow(10, minDigits) * 10;
		let q, p;
		let attempts = 0;

		do {
			q = randomPrime(min, max);
			let found = false;
			for (let k = 2; k <= 10; k++) {
				const candidateP = q * k + 1;
				if (candidateP >= min && candidateP <= max && isPrime(candidateP)) {
					p = candidateP;
					found = true;
					break;
				}
			}
			attempts++;
			if (attempts > 1000) {
				alert("Không tìm được p, q thỏa mãn trong phạm vi cho phép. Vui lòng thử lại.");
				return null;
			}
		} while (!p);

		return { p, q };
	}
	function generateXGK(p, q) {
		let x = Math.floor(Math.random() * (q - 1)) + 1;
		let k = Math.floor(Math.random() * (q - 1)) + 1;

		let h, g = 1;
		let attempts = 0;
		do {
			h = Math.floor(Math.random() * (q - 2)) + 2; // h ∈ [2, q-1]
			g = modExp(h, (p - 1) / q, p);
			attempts++;
		} while (g <= 1 && attempts < 1000);

		if (g <= 1) {
			alert("Không thể sinh giá trị g hợp lệ. Vui lòng thử lại.");
			return null;
		}

		return { x, g, k, h };
	}

	function generatePQXGKText() {
		const pq = generatePQ(6);
		if (!pq) return;

		const { p, q } = pq;
		const { x, g, k, h } = generateXGK(p, q);
		const y = modExp(g, x, p);

		document.getElementById("inputPText").value = p;
		document.getElementById("inputQText").value = q;
		document.getElementById("inputXText").value = x;
		document.getElementById("inputGText").value = g;
		document.getElementById("inputKText").value = k;
		document.getElementById("inputYText").value = y;
		document.getElementById("inputHText").value = h;
	}
	function clearTextForm() {
		const ids = [
			"inputPText", "inputQText", "inputXText", "inputHText",
			"inputGText", "inputYText", "inputKText"
		];
		ids.forEach(id => document.getElementById(id).value = '');
		document.querySelector('textarea[name="message"]').value = '';
	}

	function clearFileForm() {
		const ids = [
			"inputPFile", "inputQFile", "inputXFile", "inputHFile",
			"inputGFile", "inputYFile", "inputKFile"
		];
		ids.forEach(id => document.getElementById(id).value = '');
		document.querySelector('input[name="file"]').value = '';
	}

	function generatePQXGKFile() {
		const pq = generatePQ(6);
		if (!pq) return;

		const { p, q } = pq;
		const { x, g, k, h } = generateXGK(p, q);
		const y = modExp(g, x, p);

		document.getElementById("inputPFile").value = p;
		document.getElementById("inputQFile").value = q;
		document.getElementById("inputXFile").value = x;
		document.getElementById("inputGFile").value = g;
		document.getElementById("inputKFile").value = k;
		document.getElementById("inputYFile").value = y;
		document.getElementById("inputHFile").value = h;
	}

	</script>
<script>
	function validateAndComputeText() {
		const p = parseInt(document.getElementById("inputPText").value);
		const q = parseInt(document.getElementById("inputQText").value);
		const h = parseInt(document.getElementById("inputHText").value);
		const x = parseInt(document.getElementById("inputXText").value);
		const k = parseInt(document.getElementById("inputKText").value);

		if (!isPrime(q)) {
			alert("q không phải là số nguyên tố.");
			return;
		}
		if (!isPrime(p)) {
			alert("p không phải là số nguyên tố.");
			return;
		}
		if ((p - 1) % q !== 0) {
			alert("p không thỏa mãn điều kiện p - 1 chia hết cho q.");
			return;
		}
		if (!(h > 1 && h < p - 1)) {
			alert("h phải nằm trong khoảng (1, p-1).");
			return;
		}
		if (!(x > 0 && x < q)) {
			alert("x phải nằm trong khoảng (0, q).");
			return;
		}
		if (!(k > 0 && k < q)) {
			alert("k phải nằm trong khoảng (0, q).");
			return;
		}

		// Tính g
		const g = modExp(h, (p - 1) / q, p);
		if (g <= 1) {
			alert("Giá trị g không hợp lệ (<=1). Vui lòng chọn h khác.");
			return;
		}

		// Tính y
		const y = modExp(g, x, p);

		// Gán vào form
		document.getElementById("inputGText").value = g;
		document.getElementById("inputYText").value = y;
	}

	function validateAndComputeFile() {
		const p = parseInt(document.getElementById("inputPFile").value);
		const q = parseInt(document.getElementById("inputQFile").value);
		const h = parseInt(document.getElementById("inputHFile").value);
		const x = parseInt(document.getElementById("inputXFile").value);
		const k = parseInt(document.getElementById("inputKFile").value);

		if (!isPrime(q)) {
			alert("q không phải là số nguyên tố.");
			return;
		}
		if (!isPrime(p)) {
			alert("p không phải là số nguyên tố.");
			return;
		}
		if ((p - 1) % q !== 0) {
			alert("p không thỏa mãn điều kiện p - 1 chia hết cho q.");
			return;
		}
		if (!(h > 1 && h < p - 1)) {
			alert("h phải nằm trong khoảng (1, p-1).");
			return;
		}
		if (!(x > 0 && x < q)) {
			alert("x phải nằm trong khoảng (0, q).");
			return;
		}
		if (!(k > 0 && k < q)) {
			alert("k phải nằm trong khoảng (0, q).");
			return;
		}

		const g = modExp(h, (p - 1) / q, p);
		if (g <= 1) {
			alert("Giá trị g không hợp lệ (<=1). Vui lòng chọn h khác.");
			return;
		}
		const y = modExp(g, x, p);
		document.getElementById("inputGFile").value = g;
		document.getElementById("inputYFile").value = y;
	}
</script>


</head>
<body class="bg-light">
	<div class="container mt-5">
		<h2 class="text-center mb-4">Hệ thống ký số DSA</h2>

		<div class="card shadow p-4 mb-4">
			<h5>Chọn hình thức ký:</h5>
			<div class="form-check">
				<input class="form-check-input" type="radio" name="signOption"
					id="optionText" value="text" onclick="toggleForm()" checked>
				<label class="form-check-label" for="optionText">Ký văn bản
					trực tiếp</label>
			</div>
			<div class="form-check">
				<input class="form-check-input" type="radio" name="signOption"
					id="optionFile" value="file" onclick="toggleForm()"> <label
					class="form-check-label" for="optionFile">Ký file Word
					(.docx), PDF (.pdf) hoặc Excel (.xlsx)</label>
			</div>
		</div>

		<!-- Form ký văn bản -->
		<div class="card shadow p-4 mb-4" id="textForm">
			<h5 class="mb-3">Nhập văn bản cần ký:</h5>
			<form action="sign" method="post">
				<div class="row mb-3">
					<div class="row">
						<div class="mb-3">
							<label for="hashFunctionText" class="form-label">Chọn hàm
								băm</label> <select class="form-select" id="hashFunctionText" name="bam">
								<option value="MD5">MD5</option>
								<option value="SHA-1">SHA-1</option>
								<option value="SHA-224">SHA-224</option>
								<option value="SHA-256" selected>SHA-256</option>
								<option value="SHA-384">SHA-384</option>
								<option value="SHA-512">SHA-512</option>
								<option value="SHA3-256">SHA3-256</option>
								<option value="SHA3-512">SHA3-512</option>
							</select>
						</div>

						<div class="col-md-3">
							<label for="inputXText" class="form-label">x (private
								key):</label> <input type="number" name="x" id="inputXText"
								class="form-control" min="1">
						</div>
						<div class="col-md-3">
							<label for="inputQText" class="form-label">Số nguyên tố
								q:</label> <input type="number" name="q" id="inputQText"
								class="form-control" minlength="6" min="0">
						</div>
						<div class="col-md-3">
							<label for="inputPText" class="form-label">Số nguyên tố
								p:</label> <input type="number" name="p" id="inputPText"
								class="form-control" minlength="6" min="0" >
						</div>
						<div class="col-md-3">
							<label for="inputHText" class="form-label">h (tạo g):</label> <input
								type="number" name="h" id="inputHText" class="form-control"
								>
						</div>
					
						<div class="col-md-3">
							<label for="inputKText" class="form-label">k:</label> <input
								type="number" name="k" id="inputKText" class="form-control"
								min="1" >
						</div>
							<div class="col-md-3">
							<label for="inputGText" class="form-label">g:</label> <input
								type="number" name="g" id="inputGText" class="form-control"
								min="1" readonly>
						</div>
						<div class="col-md-3">
							<label for="inputYText" class="form-label">y = g^x mod p:</label>
							<input type="number" name="y" id="inputYText"
								class="form-control" min="1" readonly>
						</div>
					</div>
					<div class="row mt-3">
						<div class="col-md-2">
							<button type="button" class="btn btn-warning w-100"
								onclick="validateAndComputeText()">Kiểm tra & Tính toán</button>
						</div>

						<div class="col-md-2">
							<button type="button" class="btn btn-primary w-100"
								onclick="generatePQXGKText()">Sinh ngẫu nhiên</button>
						</div>
						<div class="col-md-2">
							<button type="button" class="btn btn-danger w-100"
								onclick="clearTextForm()">Xóa tất cả</button>
						</div>


					</div>
				</div>
				<div class="mb-3">
					<textarea name="message" rows="5" class="form-control"
						placeholder="Nhập nội dung cần ký ở đây..." required></textarea>
				</div>
				<button type="submit" class="btn btn-success">Ký văn bản</button>
			</form>
		</div>

		<!-- Form ký file -->
		<div class="card shadow p-4 mb-4" id="fileForm" style="display: none;">
			<h5 class="mb-3">Chọn file cần ký:</h5>
			<form action="upload" method="post" enctype="multipart/form-data">
				<div class="mb-3">
					<label for="hashFunctionText" class="form-label">Chọn hàm
						băm</label> <select class="form-select" id="hashFunctionText" name="bam">
						<option value="MD5">MD5</option>
						<option value="SHA-1">SHA-1</option>
						<option value="SHA-224">SHA-224</option>
						<option value="SHA-256" selected>SHA-256</option>
						<option value="SHA-384">SHA-384</option>
						<option value="SHA-512">SHA-512</option>
						<option value="SHA3-256">SHA3-256</option>
						<option value="SHA3-512">SHA3-512</option>
					</select>
				</div>
				<div class="row mb-3">
					<div class="row">

						<div class="col-md-3">
							<label for="inputXFile" class="form-label">x (private
								key):</label> <input type="number" name="x" id="inputXFile"
								class="form-control" min="1">
						</div>
						<div class="col-md-3">
							<label for="inputQFile" class="form-label">Số nguyên tố
								q:</label> <input type="number" name="q" id="inputQFile"
								class="form-control" minlength="6" min="0">
						</div>
						<div class="col-md-3">
							<label for="inputPFile" class="form-label">Số nguyên tố
								p:</label> <input type="number" name="p" id="inputPFile"
								class="form-control" minlength="6" min="0" >
						</div>

						<div class="col-md-3">
							<label for="inputHFile" class="form-label">h (tạo g):</label> <input
								type="number" name="h" id="inputHFile" class="form-control"
								>
						</div>
					
						<div class="col-md-3">
							<label for="inputKFile" class="form-label">k:</label> <input
								type="number" name="k" id="inputKFile" class="form-control"
								min="1" >
						</div>
							<div class="col-md-3">
							<label for="inputGFile" class="form-label">g:</label> <input
								type="number" name="g" id="inputGFile" class="form-control"
								min="1" readonly>
						</div>
						<div class="col-md-3">
							<label for="inputYFile" class="form-label">y = g^x mod p:</label>
							<input type="number" name="y" id="inputYFile"
								class="form-control" min="1" readonly>
						</div>
					</div>
					<div class="row mt-3">
						<div class="col-md-2">
							<button type="button" class="btn btn-warning w-100"
								onclick="validateAndComputeFile()">Kiểm tra & Tính toán</button>
						</div>

						<div class="col-md-2">
							<button type="button" class="btn btn-primary w-100"
								onclick="generatePQXGKFile()">Sinh ngẫu nhiên</button>
						</div>
						<div class="col-md-2">
							<button type="button" class="btn btn-danger w-100"
								onclick="clearFileForm()">Xóa tất cả</button>
						</div>


					</div>
				</div>
				<div class="mb-3">
					<input type="file" name="file" accept=".docx,.pdf,.xlsx"
						class="form-control" required>
				</div>
				<button type="submit" class="btn btn-success">Ký file</button>
			</form>
		</div>
	</div>
</body>
</html>
