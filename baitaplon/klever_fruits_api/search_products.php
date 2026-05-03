<?php
// Cấu hình Header
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// 1. Cấu hình kết nối Database
$host = "127.0.0.1"; // Dùng IP này thay cho localhost để ổn định hơn
$user = "root";
$pass = ""; 
$db   = "klever_fruits"; 
$port = 3308; // THÊM DÒNG NÀY: Vì MySQL của bạn chạy cổng 3308

// THAY ĐỔI DÒNG NÀY: Thêm biến $port vào cuối
$conn = new mysqli($host, $user, $pass, $db, $port);

// Kiểm tra kết nối
if ($conn->connect_error) {
    die(json_encode(["error" => "Kết nối thất bại: " . $conn->connect_error]));
}

// Thiết lập font tiếng Việt
$conn->set_charset("utf8mb4");

// 2. Lấy từ khóa tìm kiếm
$searchTerm = isset($_GET['query']) ? $_GET['query'] : '';

// 3. Thực hiện truy vấn SQL
$sql = "SELECT * FROM products WHERE name LIKE ?";
$stmt = $conn->prepare($sql);
$queryParam = "%" . $searchTerm . "%";
$stmt->bind_param("s", $queryParam);
$stmt->execute();

$result = $stmt->get_result();

$products = [];
while ($row = $result->fetch_assoc()) {
    $row['price'] = (float)$row['price'];
    $products[] = $row;
}

// 4. Trả về kết quả JSON
echo json_encode($products);

$stmt->close();
$conn->close();
?>