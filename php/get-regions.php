<?php
/**
 * Get all regions from database
 */

require_once __DIR__ . '/config.php';

header('Content-Type: application/json');

try {
    $stmt = $pdo->query("SELECT region_id, region_name FROM regions ORDER BY region_name");
    $regions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    http_response_code(200);
    echo json_encode([
        'success' => true,
        'data' => $regions
    ]);
} catch (PDOException $e) {
    error_log("Database error in get-regions.php: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Failed to retrieve regions'
    ]);
}
?>
