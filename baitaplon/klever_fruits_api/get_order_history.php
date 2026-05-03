<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Kết nối tới database klever_fruits cổng 3308
$conn = new mysqli("localhost", "root", "", "klever_fruits", 3308);

// Kiểm tra kết nối database
if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Kết nối thất bại: " . $conn->connect_error]);
    exit;
}

// Thiết lập bảng mã utf8 để hiển thị tiếng Việt không bị lỗi
$conn->set_charset("utf8");

/**
 * Lưu ý: Trong thực tế, bạn nên gửi user_id từ Flutter lên để lọc đúng đơn hàng của người đó.
 * Ví dụ: $user_id = $_GET['user_id'];
 * Ở bước này, tôi sẽ lấy toàn bộ đơn hàng và sắp xếp theo thời gian mới nhất (DESC).
 */

$sql = "SELECT * FROM orders ORDER BY created_at DESC";
$result = $conn->query($sql);

$orders = [];

if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $orders[] = [
            "order_id" => $row['order_id'],
            "total_amount" => $row['total_amount'],
            "status" => $row['status'],
            "created_at" => $row['created_at']
        ];
    }
}

// Trả về dữ liệu dạng JSON cho Flutter
echo json_encode($orders);

$conn->close();
?>