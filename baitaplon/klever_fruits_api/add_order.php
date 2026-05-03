<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

// 1. Kết nối Database (Dùng đúng cổng 3308 của bạn)
$servername = "localhost";
$username = "root"; 
$password = ""; 
$dbname = "klever_fruits_db";
$port = 3308; 

$conn = new mysqli($servername, $username, $password, $dbname, $port);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Kết nối thất bại"]));
}

// 2. Nhận dữ liệu từ App
$user_id = $_POST['user_id'] ?? '';
$total_price = $_POST['total_price'] ?? '';
$status = "Đang xử lý"; // Trạng thái mặc định khi mới đặt

if (empty($user_id) || empty($total_price)) {
    echo json_encode(["status" => "error", "message" => "Thiếu thông tin đặt hàng"]);
    exit();
}

// 3. Chèn đơn hàng vào bảng 'orders'
// QUAN TRỌNG: Phải lưu user_id để sau này get_orders.php mới lọc được
$sql = "INSERT INTO orders (user_id, total_price, status, created_at) VALUES (?, ?, ?, NOW())";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ids", $user_id, $total_price, $status);

if ($stmt->execute()) {
    $order_id = $conn->insert_id;
    echo json_encode([
        "status" => "success",
        "message" => "Đặt hàng thành công!",
        "order_id" => $order_id
    ]);
} else {
    echo json_encode(["status" => "error", "message" => "Lỗi lưu đơn hàng: " . $conn->error]);
}

$stmt->close();
$conn->close();
?>