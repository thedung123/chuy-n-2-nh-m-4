<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Content-Type: application/json; charset=UTF-8");

$host = "127.0.0.1"; // Dùng IP local thay vì localhost để ổn định hơn
$user = "root";
$pass = "";
$db   = "klever_fruits"; 
$port = 3308; // Khớp với cổng MySQL trong XAMPP của bạn

// Khởi tạo kết nối có kèm cổng
$conn = new mysqli("localhost", "root", "", "klever_fruits", 3308);

if ($conn->connect_error) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Kết nối Database thất bại: " . $conn->connect_error]);
    exit;
}
?>
