<?php
// Include the database connection file
include_once("dbconnect.php");

try {
    // Check if the request method is POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Get the worker ID from the POST request
        $worker_id = $_POST['worker_id'];

        // Prepare a SQL statement to select profile data for the given worker
        $stmt = $conn->prepare("SELECT worker_id, full_name, email, phone, address, image FROM workers WHERE worker_id = ?");
        $stmt->bind_param("i", $worker_id); // Bind the worker_id as an integer
        $stmt->execute(); // Execute the SQL query
        $result = $stmt->get_result(); // Get the result of the query

        // If a matching worker profile is found, return it in the response
        if ($worker = $result->fetch_assoc()) {
            echo json_encode([
                "status" => "success",
                "data" => $worker
            ]);
        } else {
            // If no profile is found, return a failure message
            echo json_encode(["status" => "failed", "message" => "Profile not found"]);
        }

        // Close the prepared statement
        $stmt->close();
    } else {
        // Handle requests that are not POST
        echo json_encode(["status" => "failed", "message" => "Invalid request"]);
    }
} catch (Exception $e) {
    // Catch any exceptions and return an error message
    echo json_encode(["status" => "failed", "message" => $e->getMessage()]);
}

// Close the database connection
$conn->close();
?>
