
================================
HOTEL BOOKING SYSTEM - API TESTS
================================

Test Email: test1763851632@example.com
Cookies File: /tmp/test_cookies_1763851632.txt


================================
TEST 1: GET /php/get-regions.php
================================

Description: Retrieve all available regions
Expected: 200 OK with JSON array of regions

Response Body:
{
    "success": true,
    "data": [
        {
            "region_id": 3,
            "region_name": "Airport"
        },
        {
            "region_id": 2,
            "region_name": "Beachfront"
        },
        {
            "region_id": 1,
            "region_name": "Downtown"
        },
        {
            "region_id": 4,
            "region_name": "Suburban"
        }
    ]
}

✓ PASS - Get Regions
  Expected: HTTP 200 | Actual: HTTP 200

================================
TEST 2: POST /php/register.php - New User
================================

Description: Register a new user account
Expected: 201 Created

Response Body:
{
    "success": true,
    "message": "Registration successful! Redirecting to login..."
}

✓ PASS - Register New User
  Expected: HTTP 201 | Actual: HTTP 201

================================
TEST 3: POST /php/register.php - Duplicate Email
================================

Description: Attempt to register with existing email
Expected: 409 Conflict

Response Body:
{
    "success": false,
    "message": "Email already registered. Please login."
}

✓ PASS - Register Duplicate User
  Expected: HTTP 409 | Actual: HTTP 409

================================
TEST 4: POST /php/register.php - Missing Fields
================================

Description: Register with incomplete data
Expected: 400 Bad Request

Response Body:
{
    "success": false,
    "message": "All fields are required"
}

✓ PASS - Register Missing Fields
  Expected: HTTP 400 | Actual: HTTP 400

================================
TEST 5: POST /php/login.php - Valid Login
================================

Description: Login with correct credentials
Expected: 200 OK with session cookie

Response Body:
{
    "success": true,
    "message": "Login successful! Redirecting to reservation page...",
    "redirect": "reserve.html"
}

✓ PASS - Login Valid Credentials
  Expected: HTTP 200 | Actual: HTTP 200

================================
TEST 6: POST /php/login.php - Invalid Login
================================

Description: Login with wrong password
Expected: 401 Unauthorized

Response Body:
{
    "success": false,
    "message": "Invalid email or password"
}

✓ PASS - Login Invalid Credentials
  Expected: HTTP 401 | Actual: HTTP 401

================================
TEST 7: GET /php/check-session.php - With Cookie
================================

Description: Verify session is valid
Expected: 200 OK with user data

Response Body:
{
    "success": true,
    "message": "Session valid",
    "data": {
        "userId": 2,
        "email": "test1763851632@example.com"
    }
}

✓ PASS - Check Session (Authenticated)
  Expected: HTTP 200 | Actual: HTTP 200

================================
TEST 8: GET /php/check-session.php - No Cookie
================================

Description: Check session without authentication
Expected: 401 Unauthorized

Response Body:
{
    "success": false,
    "message": "Session expired or invalid"
}

✓ PASS - Check Session (Unauthenticated)
  Expected: HTTP 401 | Actual: HTTP 401

================================
TEST 9: POST /php/get-hotels.php - With Auth
================================

Description: Search hotels in a region with dates
Expected: 200 OK with hotels array

Response Body:
{
    "success": true,
    "data": [
        {
            "hotel_id": 3,
            "hotel_name": "City Center Suites",
            "address": "789 Commerce Road, Downtown District",
            "available_rooms": 4
        },
        {
            "hotel_id": 1,
            "hotel_name": "Grand Plaza Hotel",
            "address": "123 Main Street, Downtown District",
            "available_rooms": 8
        },
        {
            "hotel_id": 2,
            "hotel_name": "Metropolitan Inn",
            "address": "456 Business Avenue, Downtown District",
            "available_rooms": 6
        }
    ],
    "count": 3
}

✓ PASS - Get Hotels (Authenticated)
  Expected: HTTP 200 | Actual: HTTP 200

================================
TEST 10: POST /php/get-hotels.php - No Auth
================================

Description: Search hotels without authentication
Expected: 401 Unauthorized

Response Body:
{
    "success": false,
    "message": "Please login to search hotels"
}

✓ PASS - Get Hotels (Unauthenticated)
  Expected: HTTP 401 | Actual: HTTP 401

================================
TEST 11: POST /php/get-hotels.php - Invalid Date
================================

Description: Search hotels with check-out before check-in
Expected: 400 Bad Request

Response Body:
{
    "success": false,
    "message": "Check-out date must be after check-in date"
}

✓ PASS - Get Hotels Invalid Date
  Expected: HTTP 400 | Actual: HTTP 400

================================
TEST 12: POST /php/get-rooms.php - With Auth
================================

Description: Get available rooms for a hotel
Expected: 200 OK with rooms array

Response Body:
{
    "success": true,
    "data": [
        {
            "rm_id": 1,
            "room_number": "101",
            "room_type_id": 1,
            "room_type_name": "Single",
            "max_occupancy": 1,
            "price_per_night": "89.99"
        },
        {
            "rm_id": 2,
            "room_number": "102",
            "room_type_id": 1,
            "room_type_name": "Single",
            "max_occupancy": 1,
            "price_per_night": "89.99"
        },
        {
            "rm_id": 3,
            "room_number": "201",
            "room_type_id": 2,
            "room_type_name": "Double",
            "max_occupancy": 2,
            "price_per_night": "129.99"
        },
        {
            "rm_id": 4,
            "room_number": "202",
            "room_type_id": 2,
            "room_type_name": "Double",
            "max_occupancy": 2,
            "price_per_night": "129.99"
        },
        {
            "rm_id": 5,
            "room_number": "301",
            "room_type_id": 3,
            "room_type_name": "Queen",
            "max_occupancy": 2,
            "price_per_night": "149.99"
        },
        {
            "rm_id": 6,
            "room_number": "302",
            "room_type_id": 3,
            "room_type_name": "Queen",
            "max_occupancy": 2,
            "price_per_night": "149.99"
        },
        {
            "rm_id": 7,
            "room_number": "401",
            "room_type_id": 4,
            "room_type_name": "King",
            "max_occupancy": 2,
            "price_per_night": "179.99"
        },
        {
            "rm_id": 8,
            "room_number": "501",
            "room_type_id": 5,
            "room_type_name": "Suite",
            "max_occupancy": 4,
            "price_per_night": "299.99"
        }
    ],
    "count": 8
}

✓ PASS - Get Rooms (Authenticated)
  Expected: HTTP 200 | Actual: HTTP 200

================================
TEST 13: POST /php/get-rooms.php - No Auth
================================

Description: Get rooms without authentication
Expected: 401 Unauthorized

Response Body:
{
    "success": false,
    "message": "Please login to view rooms"
}

✓ PASS - Get Rooms (Unauthenticated)
  Expected: HTTP 401 | Actual: HTTP 401

================================
TEST 14: POST /php/logout.php
================================

Description: Logout and destroy session
Expected: 200 OK

Response Body:
{
    "success": true,
    "message": "Logged out successfully",
    "redirect": "index.html"
}

✓ PASS - Logout
  Expected: HTTP 200 | Actual: HTTP 200

================================
TEST 15: GET /php/check-session.php - After Logout
================================

Description: Verify session is destroyed
Expected: 401 Unauthorized

Response Body:
{
    "success": false,
    "message": "Session expired or invalid"
}

✓ PASS - Check Session After Logout
  Expected: HTTP 401 | Actual: HTTP 401

================================
TEST SUMMARY
================================

Total Tests:  15
Passed:       15
Failed:       0

✓ ALL TESTS PASSED!
