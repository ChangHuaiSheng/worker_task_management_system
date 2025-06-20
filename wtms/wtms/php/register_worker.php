<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");

if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");

$name = $_POST['name'];
$email = $_POST['email'];
$password = sha1($_POST['password']);
$phone = $_POST['phone'];
$address = $_POST['address'];
$image = isset($_POST['image']) ? $_POST['image'] : null;

$sqlinsert = "INSERT INTO workers (full_name, email, password, phone, address, image)
              VALUES (?, ?, ?, ?, ?, ?)";

try {
    $stmt = $conn->prepare($sqlinsert);
    $stmt->bind_param("ssssss", $name, $email, $password, $phone, $address, $image);

    if ($stmt->execute()) {
        $response = array('status' => 'success', 'data' => null);
    } else {
        $response = array('status' => 'failed', 'data' => null);
    }
    $stmt->close();
    sendJsonResponse($response);
} catch (Exception $e) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>
