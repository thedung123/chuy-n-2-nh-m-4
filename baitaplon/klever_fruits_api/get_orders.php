<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

// 1. Kết nối Database (Lưu ý: Thêm cổng 3308 nếu bạn dùng XAMPP cấu hình riêng)
$servername = "localhost";
$username = "root"; 
$password = ""; 
$dbname = "klever_fruits_db";
$port = 3308; // Khớp với cấu hình db.php của bạn

$conn = new mysqli($servername, $username, $password, $dbname, $port);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Kết nối thất bại: " . $conn->connect_error]));
}

// 2. Nhận user_id (Hỗ trợ cả POST từ App và GET để bạn test thử trên web)
$user_id = $_REQUEST['user_id'] ?? '';

if (empty($user_id)) {
    echo json_encode(["status" => "error", "message" => "Không tìm thấy mã người dùng"]);
    exit();
}

// 3. Truy vấn đơn hàng
// Dùng Prepared Statement để bảo mật và tránh lỗi định dạng chuỗi
$sql = "SELECT id, total_price, status, created_at FROM orders WHERE user_id = ? ORDER BY id DESC";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$orders = [];
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        // Định dạng lại tiền tệ và ngày tháng nếu cần
        $orders[] = [
            "id" => $row['id'],
            "order_code" => "ORD" . str_pad($row['id'], 6, "0", STR_PAD_LEFT),
            "total_price" => number_format($row['total_price'], 0, ',', '.') . "đ",
            "status" => $row['status'],
            "created_at" => date("d/m/Y", strtotime($row['created_at']))
        ];
    }
    echo json_encode([
        "status" => "success", 
        "data" => $orders
    ]);
} else {
    echo json_encode([
        "status" => "success", 
        "data" => [], 
        "message" => "Bạn chưa có đơn hàng nào"
    ]);
}

$stmt->close();
$conn->close();
?>