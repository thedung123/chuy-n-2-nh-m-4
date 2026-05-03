<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Gọi file kết nối database của bạn (db.php hoặc db_config.php)
include_once 'db.php'; 

// Lấy user_id từ Flutter gửi lên
$user_id = isset($_POST['user_id']) ? $_POST['user_id'] : null;

if ($user_id) {
    // Thay 'cart' bằng tên bảng giỏ hàng của bạn nếu khác
    $sql = "DELETE FROM cart WHERE user_id = '$user_id'";
    
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Xóa thành công"]);
    } else {
        echo json_encode(["status" => "error", "message" => $conn->error]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Thiếu user_id"]);
}

$conn->close();
?>