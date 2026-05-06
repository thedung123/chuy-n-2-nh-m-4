<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

// Xử lý request OPTIONS cho trình duyệt (CORS)
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Kết nối database klever_fruits cổng 3308
$conn = new mysqli("localhost", "root", "", "klever_fruits", 3308);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Kết nối thất bại: " . $conn->connect_error]);
    exit;
}

// Nhận dữ liệu từ Flutter gửi lên
$order_id = $_POST['order_id'] ?? '';
$new_status = $_POST['status'] ?? '';

// Kiểm tra dữ liệu đầu vào
if (empty($order_id) || empty($new_status)) {
    echo json_encode(["status" => "error", "message" => "Thiếu mã đơn hàng hoặc trạng thái"]);
    exit;
}

// Cập nhật trạng thái đơn hàng trong bảng orders
// Lưu ý: Tên cột phải khớp với database của bạn (order_id và status)
$sql = "UPDATE orders SET status = '$new_status' WHERE order_id = '$order_id'";

if ($conn->query($sql) === TRUE) {
    echo json_encode([
        "status" => "success", 
        "message" => "Đã cập nhật trạng thái đơn hàng thành công",
        "order_id" => $order_id,
        "new_status" => $new_status
    ]);
} else {
    echo json_encode([
        "status" => "error", 
        "message" => "Lỗi khi cập nhật database: " . $conn->error
    ]);
}

$conn->close();
?>
