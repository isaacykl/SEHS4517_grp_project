<?php
/**
 * Check if user session is valid
 * Returns 200 if valid, 401 if invalid
 */

require_once __DIR__ . '/config.php';

header('Content-Type: application/json');

if (!isSessionValid()) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Session expired or invalid'
    ]);
    exit;
}

// Session is valid
http_response_code(200);
echo json_encode([
    'success' => true,
    'message' => 'Session valid',
    'data' => [
        'userId' => $_SESSION['user_id'],
        'email' => $_SESSION['email']
    ]
]);
?>
