<?php
// Cho phép tất cả các nguồn kết nối (Sửa lỗi image_3f7076.jpg)
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

// Xử lý request OPTIONS từ trình duyệt
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Kết nối DB dùng cổng 3308 (Ảnh image_3f6c96.jpg)
$conn = new mysqli("localhost", "root", "", "klever_fruits", 3308);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Kết nối DB thất bại"]);
    exit;
}

// Nhận dữ liệu từ Flutter
$user_id = $_POST['user_id'] ?? null;
// ... (các dòng nhận dữ liệu khác)

if (!$user_id || $user_id == "null") {
    echo json_encode(["status" => "error", "message" => "ID người dùng bị trống!"]);
    exit;
}

// Thực hiện lệnh INSERT vào bảng orders
$sql = "INSERT INTO orders (user_id, total_amount, status) VALUES ('$user_id', '150000', 'Đang xử lý')";
$conn->query($sql);

echo json_encode(["status" => "success", "message" => "Đặt hàng thành công"]);
?>