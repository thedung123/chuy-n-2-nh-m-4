<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') exit;

// 1. Kết nối Database (Đảm bảo đúng port 3308 như các file trước)
$conn = new mysqli("localhost", "root", "", "klever_fruits", 3308);

if ($conn->connect_error) {
    die(json_encode(["status" => "error", "message" => "Kết nối thất bại"]));
}

// 2. Nhận order_id từ query string (GET)
$order_id = $_GET['order_id'] ?? '';

if (!empty($order_id)) {
    // Sử dụng Prepared Statement để bảo mật và tránh lỗi khi mã đơn hàng có ký tự đặc biệt
    $sql = "SELECT status FROM orders WHERE order_id = ? LIMIT 1";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $order_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($row = $result->fetch_assoc()) {
        // Trả về trạng thái thực tế của đơn hàng (ví dụ: 'Thành công' hoặc 'Đang xử lý')
        echo json_encode([
            "status" => "success",
            "order_status" => $row['status']
        ]);
    } else {
        echo json_encode([
            "status" => "error",
            "message" => "Không tìm thấy đơn hàng"
        ]);
    }
    $stmt->close();
} else {
    echo json_encode([
        "status" => "error",
        "message" => "Thiếu mã đơn hàng order_id"
    ]);
}

$conn->close();
?>