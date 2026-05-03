<?php
header('Content-Type: application/json');
include 'db.php';

// Lấy dữ liệu từ POST
$user_id = $_POST['user_id'] ?? 1;
$product_id = $_POST['product_id'] ?? 0;
$quantity = (int)($_POST['quantity'] ?? 1);
$action = $_POST['action'] ?? 'add'; // Mặc định là thêm mới (cộng dồn)

if ($product_id == 0) {
    echo json_encode(["status" => "error", "message" => "Sản phẩm không hợp lệ"]);
    exit;
}

// 1. Kiểm tra xem sản phẩm đã tồn tại trong giỏ hàng của user chưa
$check = "SELECT id, quantity FROM cart WHERE user_id = ? AND product_id = ?";
$stmt = $conn->prepare($check);
$stmt->bind_param("ii", $user_id, $product_id);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows > 0) {
    $item = $res->fetch_assoc();
    
    if ($action === 'update') {
        // TRƯỜNG HỢP UPDATE (Dùng cho nút + - trong CartScreen)
        // Ghi đè trực tiếp số lượng mới từ Flutter gửi sang
        $new_qty = $quantity;
    } else {
        // TRƯỜNG HỢP ADD (Dùng khi nhấn mua ở Trang chủ)
        // Cộng dồn số lượng hiện tại với số lượng mới
        $new_qty = $item['quantity'] + $quantity;
    }

    // Thực hiện cập nhật
    $up = "UPDATE cart SET quantity = ? WHERE id = ?";
    $up_stmt = $conn->prepare($up);
    $up_stmt->bind_param("ii", $new_qty, $item['id']);
    
    if ($up_stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Đã cập nhật số lượng"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Lỗi cập nhật: " . $conn->error]);
    }
} else {
    // 2. Nếu chưa có trong giỏ hàng thì thêm mới hoàn toàn
    $ins = "INSERT INTO cart (user_id, product_id, quantity) VALUES (?, ?, ?)";
    $ins_stmt = $conn->prepare($ins);
    $ins_stmt->bind_param("iii", $user_id, $product_id, $quantity);
    
    if ($ins_stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Đã thêm vào giỏ hàng"]);
    } else {
        echo json_encode(["status" => "error", "message" => "Lỗi thêm mới: " . $conn->error]);
    }
}

$conn->close();
?>