<?php
include_once("dbconnect.php"); // make sure this connects to your DB

if ($_SERVER['REQUEST_METHOD'] === 'POST') {  //check request method if it's POST and retrieve user data from POST request
    $id = $_POST['id'];
    $full_name = $_POST['full_name'];
    $email = $_POST['email'];
    $phone = $_POST['phone'];
    $address = $_POST['address'];

    // prepare SQL statement using placeholder to prevent SQL injection
    $sql = "UPDATE `workers` SET `full_name` = ?, `email` = ?, `phone` = ?, `address` = ? WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ssssi", $full_name, $email, $phone, $address, $id); //bind parameteres to prepare the statement string and integer

    if ($stmt->execute()) { //execute statement to check for success
        $response = array("status" => "success", "message" => "Update successful");
    } else {
        $response = array("status" => "failed", "message" => "Update failed");
    }

    echo json_encode($response); //return JSON response to client
} else {
    echo json_encode(array("status" => "failed", "message" => "Invalid request method"));
}
?>
