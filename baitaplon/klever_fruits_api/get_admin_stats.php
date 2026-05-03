<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

$conn = new mysqli("localhost", "root", "", "klever_fruits", 3308); // Cổng 3308

// Tính tổng doanh thu từ bảng orders
$revenue = $conn->query("SELECT SUM(total_amount) as total FROM orders")->fetch_assoc()['total'] ?? 0;
// Đếm số đơn hàng
$orders = $conn->query("SELECT COUNT(*) as total FROM orders")->fetch_assoc()['total'] ?? 0;
// Đếm số sản phẩm
$products = $conn->query("SELECT COUNT(*) as total FROM products")->fetch_assoc()['total'] ?? 0;
// Đếm số khách hàng
$customers = $conn->query("SELECT COUNT(*) as total FROM users")->fetch_assoc()['total'] ?? 0;

echo json_encode([
    "revenue" => number_format($revenue, 0, ',', '.') . "đ",
    "orders" => $orders,
    "products" => $products,
    "customers" => $customers
]);

$conn->close();
?>