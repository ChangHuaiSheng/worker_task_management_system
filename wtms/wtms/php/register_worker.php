<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *"); // running as chrome app

if (!isset($_POST)) {  //check if POST data is set, return failure if it is not set
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php"); //include database connection

$name = $_POST['name'];  //retrieve registration data from POST request
$email = $_POST['email'];
$password = sha1($_POST['password']);
$phone = $_POST['phone'];
$address = $_POST['address'];

$sqlinsert="INSERT INTO `tbl_users`(`full_name`, `email`, `password`, `phone`, `address`) VALUES ('$name','$email','$password','$phone','$address')";

try{ //try and catch for error
    if ($conn->query($sqlinsert) === TRUE) {
        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    } else {
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }   
}catch (Exception $e) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}
	

function sendJsonResponse($sentArray) //function to send JSON response to client
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>