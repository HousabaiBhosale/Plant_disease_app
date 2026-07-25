<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, OPTIONS');
header('Access-Control-Allow-Headers: *');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

$input = json_decode(file_get_contents('php://input'), true) ?: $_POST;

$lat = $input['latitude'] ?? '15.36472';
$lng = $input['longitude'] ?? '75.12452';
$city = $input['city'] ?? 'Bagalkot';
$state = $input['state'] ?? 'Karnataka';
$country = $input['country'] ?? 'India';

$logFile = __DIR__ . '/locations_log.json';
$existing = [];
if (file_exists($logFile)) {
    $existing = json_decode(file_get_contents($logFile), true) ?: [];
}

// Update or append
$existing[] = [
    'time' => date('Y-m-d H:i:s'),
    'latitude' => $lat,
    'longitude' => $lng,
    'city' => $city,
    'state' => $state,
    'country' => $country
];
file_put_contents($logFile, json_encode($existing, JSON_PRETTY_PRINT));

echo json_encode([
    'status' => 'success',
    'message' => 'Location saved successfully',
    'location' => "$city, $state",
    'coordinates' => "Lat: $lat, Long: $lng"
]);
