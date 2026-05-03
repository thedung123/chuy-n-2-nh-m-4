<?php
header("Access-Control-Allow-Origin: *");
$conn = new mysqli("localhost", "root", "", "klever_fruits", 3308);

$id = $_POST['id'];
$sql = "DELETE FROM products WHERE id = $id";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["status" => "success"]);
} else {
    echo json_encode(["status" => "error"]);
}
$conn->close();
?>