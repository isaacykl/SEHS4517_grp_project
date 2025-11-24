<?php
/* 
SEHS4517 Web Application Development and Management
Group Project
Submission date: 29 November 2025
Full name: Yun Ka Lok
Student ID: 24056180S
*/
session_start();

$host = 'localhost';
$dbname = 'hotel_booking';
$user = 'root';
$pass = '';

$conn = new mysqli($host, $user, $pass, $dbname);
if ($conn->connect_error) {
    die("Connect fail: " . $conn->connect_error);
}

$error_message = '';
$login_success = false; // Default false

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Get value avoid null
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';

    if ($email === '' || $password === '') {
        $error_message = 'Please input email & password';
    } else {
        $stmt = $conn->prepare("SELECT user_id, password_hash FROM users WHERE email = ? LIMIT 1");
        if ($stmt) {
            $stmt->bind_param("s", $email);
            $stmt->execute();
            // Use store_result/bind_result/fetch enhancing environment compatibility
            $stmt->store_result();

            if ($stmt->num_rows === 1) {
                $stmt->bind_result($user_id, $password_hash);
                $stmt->fetch();

                if (password_verify($password, $password_hash)) {
                    session_regenerate_id(true);
                    $_SESSION['user_id'] = $user_id;
                    $_SESSION['email'] = $email;
                    $login_success = true;
                    // Redirect to reserve.html BEFORE any output
                    header("Location: reserve.html");
                    exit();
                } else {
                    $error_message = 'Wrong Email or Password.';
                }
            } else {
                $error_message = 'Account does not exist.';
            }
            $stmt->close();
        } else {
            $error_message = 'Server busy. Please try again later.';
        }
    }
}

$conn->close();
// If success，exit；failed to HTML
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Login Victoria Hotel</title>
    <link rel="stylesheet" href="login_style.css">
    <script>
        function validateForm() {
            const email = document.getElementById('email').value.trim();
            const password = document.getElementById('password').value;
            if (!email) { alert('Please input Email'); return false; }
            if (!password) { alert('Please input password'); return false; }
            return true;
        }
    </script>
</head>
<body>
    <div class="login-container">
        <?php if (!empty($error_message)): ?>
            <h3>Login Failed</h3>
            <div class="error-message">
                <p><?= htmlspecialchars($error_message) ?></p>
            </div>
        <?php endif; ?>
        <a href="First Page.html"><button>Go Back</button></a>
    </div>
</body>
</html>
