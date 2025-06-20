<?php
// Include the database connection file
include_once("dbconnect.php");

try {
    // Check if the request method is POST
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        // Retrieve POST data from the client
        $worker_id = $_POST['worker_id'];          // The ID of the worker whose profile is being updated
        $full_name = $_POST['full_name'];          // Updated full name
        $email = $_POST['email'];                  // Updated email address
        $phone = $_POST['phone'];                  // Updated phone number
        $address = $_POST['address'];              // Updated address
        $image = isset($_POST['image']) ? $_POST['image'] : null; // Updated Base64-encoded image

        // If an image is provided, update it along with other details
        if ($image) {
            // Prepare SQL statement to update profile with image
            $stmt = $conn->prepare("UPDATE workers SET full_name = ?, email = ?, phone = ?, address = ?, image = ? WHERE worker_id = ?");
            // Bind the parameters to the SQL statement (s = string, i = integer)
            $stmt->bind_param("sssssi", $full_name, $email, $phone, $address, $image, $worker_id);
        } else {
            // Prepare SQL statement to update profile without changing the image
            $stmt = $conn->prepare("UPDATE workers SET full_name = ?, email = ?, phone = ?, address = ? WHERE worker_id = ?");
            $stmt->bind_param("ssssi", $full_name, $email, $phone, $address, $worker_id);
        }

        // Execute the statement and return a success/failure message
        if ($stmt->execute()) {
            // Update was successful
            echo json_encode(["status" => "success", "message" => "Update successful"]);
        } else {
            // Update failed due to SQL error
            echo json_encode(["status" => "failed", "message" => "Update failed"]);
        }

        // Close the statement to free up resources
        $stmt->close();
    } else {
        // The request was not a POST request
        echo json_encode(["status" => "failed", "message" => "Invalid request method"]);
    }
} catch (Exception $e) {
    // Catch and return any errors that occurred during the process
    echo json_encode(["status" => "failed", "message" => $e->getMessage()]);
}

// Close the database connection
$conn->close();
?>
