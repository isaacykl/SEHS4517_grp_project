<?php
$servername = "localhost";
$db_username = "root";
$db_password = "";
$dbname = "mydatabase";

$conn = new mysqli($servername, $db_username, $db_password, $dbname);

if ($conn->connect_error) {
    die("Connect fail: " . $conn->connect_error);
}

$email = $_POST['email'];
$password = $_POST['password'];

// Avoid SQL insert
$stmt = $conn->prepare("SELECT password FROM users WHERE email = ?");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows > 0) {
    $row = $result->fetch_assoc();
    // Check password correct or incorrect
           // Login Success
        header("Location: reserve.html");
        exit();
    } else {
        // email or password wrong
        echo '<h2>Sorry, login failed!</h2>
              <p>Wrong email or password.</p>
              index.htmlGo Back</a>';
    }


$stmt->close();
$conn->close();
?>