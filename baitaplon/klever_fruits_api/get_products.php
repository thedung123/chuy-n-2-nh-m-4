<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Kết nối database qua file db.php (đang dùng cổng 3308)
include 'db.php';

// 1. Lấy tham số category từ URL. Nếu không có, mặc định lấy 'noi_dia'
$category = isset($_GET['category']) ? $_GET['category'] : 'noi_dia';

// 2. Sử dụng Prepared Statement để lọc sản phẩm theo category an toàn hơn
$sql = "SELECT id, name, price, image_url, category FROM products WHERE category = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $category);
$stmt->execute();
$result = $stmt->get_result();

$products = [];

if ($result && $result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        $products[] = [
            "id" => (int)$row['id'], // Ép kiểu về int để Flutter không bị lỗi dữ liệu
            "name" => $row['name'],
            "price" => (double)$row['price'],
            "image_url" => $row['image_url'],
            "category" => $row['category'],
            "quantity" => 1 
        ];
    }
}

// 3. Trả về kết quả JSON để Flutter AdminScreen nhận dữ liệu
echo json_encode($products);

$stmt->close();
$conn->close();
?>
