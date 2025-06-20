<?php
// This part of code includes the database connection file
include_once("dbconnect.php");

// This part checks if the HTTP request method is POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // This part retrieves the worker_id from the POST request
    $worker_id = $_POST['worker_id'];

    // This part defines the SQL query to get all submissions by the worker,
    // joining with the tbl_works table to get the task title
    $sql = "SELECT s.id, w.title, s.submission_text, s.submitted_at
            FROM tbl_submissions s
            JOIN tbl_works w ON s.work_id = w.work_id
            WHERE s.worker_id = ?
            ORDER BY s.submitted_at DESC";

    // This part prepares the SQL statement to prevent SQL injection
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $worker_id); // Binds the worker_id as an integer
    $stmt->execute(); // Executes the query

    // This part fetches the results
    $result = $stmt->get_result();
    $submissions = [];

    // This part loops through each row and stores it in the submissions array
    while ($row = $result->fetch_assoc()) {
        $submissions[] = $row;
    }

    // This part returns the submissions as JSON with a success status
    echo json_encode([
        "status" => "success",
        "data" => $submissions
    ]);

    // This part closes the statement and the database connection
    $stmt->close();
    $conn->close();

} else {
    // This part handles non-POST requests with a failure message
    echo json_encode(["status" => "failed", "message" => "Invalid request"]);
}
?>
