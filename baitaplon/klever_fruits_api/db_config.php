<?php
// Dùng 127.0.0.1 sẽ nhanh hơn localhost trong một số môi trường Windows
$host = "127.0.0.1"; 
$user = "root";
$pass = ""; 
$dbname = "klever_fruits"; // Kiểm tra lại tên này trong phpMyAdmin của bạn

$conn = mysqli_connect($host, $user, $pass, $dbname);

if (!$conn) {
    die(json_encode(["error" => "Kết nối thất bại"]));
}
?>