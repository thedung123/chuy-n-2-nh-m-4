<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json; charset=UTF-8");

// Xử lý request OPTIONS (Preflight) cho trình duyệt
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Kết nối Database cổng 3308
$conn = new mysqli("localhost", "root", "", "klever_fruits", 3308);

if ($conn->connect_error) {
    echo json_encode(["status" => "error", "message" => "Kết nối thất bại: " . $conn->connect_error]);
    exit;
}

// Nhận dữ liệu từ Flutter gửi lên
$id = $_POST['id'] ?? '';
$name = $_POST['name'] ?? '';
$price = $_POST['price'] ?? '';
$image_url = $_POST['image_url'] ?? '';

// Kiểm tra dữ liệu đầu vào cơ bản
if (empty($name) || empty($price)) {
    echo json_encode(["status" => "error", "message" => "Vui lòng nhập tên và giá sản phẩm"]);
    exit;
}

if (!empty($id)) {
    // TRƯỜNG HỢP: SỬA SẢN PHẨM (Có ID)
    $sql = "UPDATE products SET 
            name = '$name', 
            price = '$price', 
            image_url = '$image_url' 
            WHERE id = $id";
            
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Cập nhật sản phẩm thành công"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Lỗi cập nhật: " . $conn->error]);
    }
} else {
    // TRƯỜNG HỢP: THÊM MỚI (ID trống)
    $sql = "INSERT INTO products (name, price, image_url) 
            VALUES ('$name', '$price', '$image_url')";
            
    if ($conn->query($sql) === TRUE) {
        echo json_encode(["status" => "success", "message" => "Thêm sản phẩm mới thành công"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Lỗi thêm mới: " . $conn->error]);
    }
}

$conn->close();
?>
