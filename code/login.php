<!--SEHS4517 Web Application Development and Management
// Group Projrct
// Submission date: 29 November 2025
// Full name: Yun Ka Lok
// Student ID: 24056180S
-->

<?php
$host = 'localhost';
$dbname = 'hotel_booking';
$user = 'root';
$pass= '';

$conn = new mysqli($host, $user, $pass, $dbname);

if ($conn->connect_error) {
    die("Connect fail: " . $conn->connect_error);
}

$email = $_POST['email'];
$password = $_POST['password'];

// Use prepared statement avoid SQL injection

$stmt = $conn->prepare("SELECT user_id, password_hash FROM users WHERE email = ? LIMIT 1");
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    if (password_verify($password, $row['password_hash'])) {
        // success: start session etc.
    } else {
        // invalid credentials
    }
} else {
    // user not found
}

$stmt->close();
$conn->close();
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login Hotel</title>
    <link rel="stylesheet" href="login_style.css">
</head>
<body>
    <div class="login-container">
        <?php session_start();
        $login_success = false; ?>  <!--Identify and avoid not identify error message -->
        
        <?php if ($login_success): ?>
            <!-- Login success redirect -->
            <?php header("Location: reserve.html"); exit(); ?>
        <?php else: ?>
            <h3>Sorry, login failed!</h3>
            <form action="login.php" method="POST" onsubmit="return validateForm()">
            </form>
            <!-- Login failed error message -->
            <div class="error-message">
                <p>Wrong email or password.</p>
                <a href="First Page.html"><button>Go Back</button></a>
            </div>
        <?php endif; ?>
    </div>
</body>
</html>