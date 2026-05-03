<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Kết nối cổng 3308
$conn = new mysqli("localhost", "root", "", "klever_fruits", 3308);

if ($conn->connect_error) {
    die(json_encode(["error" => "Kết nối thất bại"]));
}

// Hỗ trợ tiếng Việt cho các trạng thái như "Đang đóng gói"
$conn->set_charset("utf8");

// Quan trọng: DESC để đơn hàng mới nhất hiện lên đầu tiên
$sql = "SELECT * FROM orders ORDER BY created_at DESC";
$result = $conn->query($sql);
$orders = [];

if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $orders[] = $row;
    }
}

echo json_encode($orders);
$conn->close();
?>