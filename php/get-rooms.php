<?php
/**
 * Get available rooms for a hotel by date range
 */

require_once __DIR__ . '/config.php';

header('Content-Type: application/json');

// Check session
if (!isSessionValid()) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Please login to view rooms'
    ]);
    exit;
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate input
if (!isset($input['hotelId']) || !isset($input['checkInDate']) || !isset($input['checkOutDate'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Missing required fields: hotelId, checkInDate, checkOutDate'
    ]);
    exit;
}

$hotelId = filter_var($input['hotelId'], FILTER_VALIDATE_INT);
$checkInDate = sanitizeInput($input['checkInDate']);
$checkOutDate = sanitizeInput($input['checkOutDate']);

// Validate hotel ID
if ($hotelId === false || $hotelId <= 0) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid hotel ID'
    ]);
    exit;
}

// Validate dates
if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $checkInDate) || !preg_match('/^\d{4}-\d{2}-\d{2}$/', $checkOutDate)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid date format. Use YYYY-MM-DD'
    ]);
    exit;
}

if (strtotime($checkOutDate) <= strtotime($checkInDate)) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Check-out date must be after check-in date'
    ]);
    exit;
}

try {
    // Get available rooms for the hotel
    $sql = "
        SELECT 
            ri.room_id as rm_id,
            ri.room_number,
            rt.room_type_id,
            rt.room_type_name,
            rt.max_occupancy,
            ri.price_per_night
        FROM room_inventory ri
        INNER JOIN room_type rt ON ri.room_type_id = rt.room_type_id
        WHERE ri.hotel_id = :hotelId
        AND ri.room_id NOT IN (
            SELECT b.room_id
            FROM bookings b
            WHERE b.status != 'cancelled'
            AND (
                (b.check_in_date < :checkOutDate AND b.check_out_date > :checkInDate)
            )
        )
        ORDER BY ri.price_per_night, ri.room_number
    ";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        'hotelId' => $hotelId,
        'checkInDate' => $checkInDate,
        'checkOutDate' => $checkOutDate
    ]);
    
    $rooms = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $rooms,
        'count' => count($rooms)
    ]);
} catch (PDOException $e) {
    error_log("Database error in get-rooms.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to retrieve rooms'
    ]);
}
?>
