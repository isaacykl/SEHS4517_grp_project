<?php
/**
 * Get available hotels by region and date range
 */

require_once __DIR__ . '/config.php';

header('Content-Type: application/json');

// Check session
if (!isSessionValid()) {
    http_response_code(401);
    echo json_encode([
        'success' => false,
        'message' => 'Please login to search hotels'
    ]);
    exit;
}

// Get JSON input
$input = json_decode(file_get_contents('php://input'), true);

// Validate input
if (!isset($input['regionId']) || !isset($input['checkInDate']) || !isset($input['checkOutDate'])) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Missing required fields: regionId, checkInDate, checkOutDate'
    ]);
    exit;
}

$regionId = filter_var($input['regionId'], FILTER_VALIDATE_INT);
$checkInDate = sanitizeInput($input['checkInDate']);
$checkOutDate = sanitizeInput($input['checkOutDate']);

// Validate region ID
if ($regionId === false || $regionId <= 0) {
    http_response_code(400);
    echo json_encode([
        'success' => false,
        'message' => 'Invalid region ID'
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
    // Get hotels in region with available rooms
    $sql = "
        SELECT 
            h.hotel_id,
            h.hotel_name,
            h.address,
            COUNT(DISTINCT ri.room_id) as available_rooms
        FROM hotels h
        INNER JOIN room_inventory ri ON h.hotel_id = ri.hotel_id
        WHERE h.region_id = :regionId
        AND ri.room_id NOT IN (
            SELECT b.room_id
            FROM bookings b
            WHERE b.status != 'cancelled'
            AND (
                (b.check_in_date < :checkOutDate AND b.check_out_date > :checkInDate)
            )
        )
        GROUP BY h.hotel_id, h.hotel_name, h.address
        HAVING available_rooms > 0
        ORDER BY h.hotel_name
    ";
    
    $stmt = $pdo->prepare($sql);
    $stmt->execute([
        'regionId' => $regionId,
        'checkInDate' => $checkInDate,
        'checkOutDate' => $checkOutDate
    ]);
    
    $hotels = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $hotels,
        'count' => count($hotels)
    ]);
} catch (PDOException $e) {
    error_log("Database error in get-hotels.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to retrieve hotels'
    ]);
}
?>
