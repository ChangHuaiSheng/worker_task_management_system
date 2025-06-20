<?php
// This part of code includes the database connection file
include_once("dbconnect.php");

// This part checks if the request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // This part retrieves the submission ID and updated submission text from the POST request
    $submission_id = $_POST['submission_id'];
    $updated_text = $_POST['updated_text'];

    // This part prepares the SQL statement to update the submission text
    $stmt = $conn->prepare("UPDATE tbl_submissions SET submission_text = ? WHERE id = ?");
    $stmt->bind_param("si", $updated_text, $submission_id); // Bind parameters: string, int

    // This part executes the update query and returns JSON response based on result
    if ($stmt->execute()) {
        echo json_encode(["status" => "success", "message" => "Submission updated"]);
    } else {
        echo json_encode(["status" => "failed", "message" => "Update failed"]);
    }

    // This part closes the prepared statement and database connection
    $stmt->close();
    $conn->close();

} else {
    // This part handles invalid request methods (non-POST)
    echo json_encode(["status" => "failed", "message" => "Invalid request"]);
}
?>
