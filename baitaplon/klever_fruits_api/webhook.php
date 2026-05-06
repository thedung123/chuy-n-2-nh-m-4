<?php
// Nhận dữ liệu từ bên trung gian gửi sang
$data = json_decode(file_get_contents('php://input'), true);

// Giả sử dữ liệu trả về có nội dung chuyển khoản là 'description'
$order_id = $data['data']['description']; 

if ($order_id) {
    $conn = new mysqli("localhost", "root", "", "klever_fruits", 3308);
    // Cập nhật trạng thái đơn hàng dựa trên mã đơn
    $sql = "UPDATE orders SET status = 'Thành công' WHERE order_id = '$order_id'";
    $conn->query($sql);
    $conn->close();
}
?>
