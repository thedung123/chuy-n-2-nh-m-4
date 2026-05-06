<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'db.php'; // Đảm bảo port là 3308

$username = $_POST['username'] ?? '';
$password = $_POST['password'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode(["status" => "error", "message" => "Thiếu thông tin đăng nhập"]);
    exit;
}

// Truy vấn lấy user theo username
$sql = "SELECT * FROM users WHERE username = '$username' LIMIT 1";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $user = $result->fetch_assoc();
    
    // Kiểm tra mật khẩu (Nếu bạn không dùng hash thì so sánh trực tiếp)
    if ($password == $user['password']) {
        echo json_encode([
            "status" => "success",
            "message" => "Đăng nhập thành công!",
            "user" => [
                "id" => $user['id'], // Trả về ID số: 1, 2, 3...
                "full_name" => $user['full_name'],
                "username" => $user['username']
            ]
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Mật khẩu không chính xác"]);
    }
} else {
    echo json_encode(["status" => "error", "message" => "Tài khoản không tồn tại"]);
}

$conn->close();
?>
