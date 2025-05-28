<?php
include_once("dbconnect.php");

$work_id = $_POST['work_id'];
$worker_id = $_POST['worker_id'];
$submission_text = $_POST['submission_text'];

$sql = "INSERT INTO tbl_submissions (work_id, worker_id, submission_text) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("iis", $work_id, $worker_id, $submission_text);

if ($stmt->execute()) {
    echo "success";
} else {
    echo "failed";
}

$stmt->close();
$conn->close();
?>