<?php
include 'db.php'; // Kết nối tới database klever_fruits

// Câu lệnh SQL tạo bảng orders
$sql = "CREATE TABLE IF NOT EXISTS orders (
    id INT(11) AUTO_INCREMENT PRIMARY KEY,
    user_id INT(11) NOT NULL,          -- ID người mua từ bảng users
    phone VARCHAR(20) NOT NULL,        -- SĐT người nhận (nhập khi thanh toán)
    address TEXT NOT NULL,             -- Địa chỉ nhận hàng (nhập khi thanh toán)
    total_price DECIMAL(10, 2) NOT NULL, -- Tổng tiền
    payment_method VARCHAR(50) NOT NULL, -- 'COD' hoặc 'Chuyển khoản'
    status VARCHAR(50) DEFAULT 'pending', 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success", "message" => "Đã tạo bảng orders thành công!"]);
} else {
    echo json_encode(["status" => "error", "message" => "Lỗi: " . $conn->error]);
}

$conn->close();
?>
