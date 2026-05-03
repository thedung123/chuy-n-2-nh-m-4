<?php
// 1. Thêm Header CORS
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit;
}

include 'db.php'; 

$input = json_decode(file_get_contents('php://input'), true);

$username  = $_POST['username'] ?? $input['username'] ?? '';
$password  = $_POST['password'] ?? $input['password'] ?? '';
$full_name = $_POST['full_name'] ?? $input['full_name'] ?? '';
$phone     = $_POST['phone'] ?? $input['phone'] ?? '';
$email     = $_POST['email'] ?? $input['email'] ?? '';

if (empty($username) || empty($password)) {
    echo json_encode([
        "status" => "error", 
        "message" => "Vui lòng nhập đầy đủ tài khoản và mật khẩu"
    ]);
    exit;
}

$check_sql = "SELECT id FROM users WHERE username = ?";
$stmt = $conn->prepare($check_sql);
$stmt->bind_param("s", $username);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    echo json_encode(["status" => "error", "message" => "Tên đăng nhập này đã có người sử dụng"]);
} else {
    $insert_sql = "INSERT INTO users (username, password, email, full_name, phone) VALUES (?, ?, ?, ?, ?)";
    $ins_stmt = $conn->prepare($insert_sql);
    $ins_stmt->bind_param("sssss", $username, $password, $email, $full_name, $phone);
    
    if ($ins_stmt->execute()) {
        // --- SỬA TẠI ĐÂY: Lấy ID vừa được tạo tự động trong Database ---
        $new_id = $ins_stmt->insert_id; 

        echo json_encode([
            "status" => "success", 
            "message" => "Đăng ký thành công!",
            "user" => [
                "id" => $new_id, // TRẢ VỀ ID MỚI CHO FLUTTER
                "username" => $username,
                "full_name" => $full_name ?: $username // Nếu full_name trống thì lấy username
            ]
        ]);
    } else {
        echo json_encode(["status" => "error", "message" => "Lỗi hệ thống: " . $conn->error]);
    }
    $ins_stmt->close();
}

$stmt->close();
$conn->close();
?>