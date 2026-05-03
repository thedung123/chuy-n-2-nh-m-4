<?php
include 'db.php';

// Tạm thời fix cứng user_id = 1 cho đến khi bạn làm xong phần lưu User Session
$user_id = $_GET['user_id'] ?? 1; 

$sql = "SELECT c.id as cart_id, p.id as product_id, p.name, p.price, p.image_url, c.quantity 
        FROM cart c 
        JOIN products p ON c.product_id = p.id 
        WHERE c.user_id = ?";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

$cart_items = [];
while($row = $result->fetch_assoc()) {
    $cart_items[] = $row;
}

echo json_encode($cart_items);
$conn->close();
?>