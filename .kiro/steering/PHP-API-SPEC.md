# PHP API Specification

## Overview

This document provides the API specifications for all PHP endpoints in the hotel booking system.

**Base URL**: `http://localhost/php/`

**Content-Type**: `application/json` (for all requests and responses)

---

## 1. User Registration

### Endpoint
```
POST /php/register.php
```

### Description
Creates a new user account with validated credentials and hashed password storage.

### Request Headers
```
Content-Type: application/json
```

### Request Body
```json
{
  "lastName": "string",      // Required, user's last name
  "firstName": "string",     // Required, user's first name
  "address": "string",       // Required, mailing address
  "phone": "string",         // Required, 10 digits only
  "email": "string",         // Required, valid email format, must be unique
  "password": "string"       // Required, min 8 chars, 1 uppercase, 1 number
}
```

### Validation Rules
- **lastName**: Required, non-empty string
- **firstName**: Required, non-empty string
- **address**: Required, non-empty string
- **phone**: Required, exactly 10 digits (e.g., "1234567890")
- **email**: Required, valid email format, must be unique in database
- **password**: Required, minimum 8 characters, at least 1 uppercase letter, at least 1 number

### Success Response
**Code**: `201 Created`

```json
{
  "success": true,
  "message": "Registration successful! Redirecting to login..."
}
```

### Error Responses

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "All fields are required"
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Invalid email format"
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Phone must be exactly 10 digits"
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Password must be at least 8 characters with 1 uppercase and 1 number"
}
```

**Code**: `409 Conflict`
```json
{
  "success": false,
  "message": "Email already registered. Please login."
}
```

**Code**: `500 Internal Server Error`
```json
{
  "success": false,
  "message": "Database error occurred. Please try again later."
}
```

### Example Request
```bash
curl -X POST http://localhost/php/register.php \
  -H "Content-Type: application/json" \
  -d '{
    "lastName": "Doe",
    "firstName": "John",
    "address": "123 Main Street, City, State 12345",
    "phone": "1234567890",
    "email": "john.doe@example.com",
    "password": "SecurePass123"
  }'
```

### Database Impact
- Inserts new record into `users` table
- Password is hashed using bcrypt before storage
- Automatically sets `created_at` timestamp

---

## 2. User Login

### Endpoint
```
POST /php/login.php
```

### Description
Authenticates user credentials and creates a PHP session on success.

### Request Headers
```
Content-Type: application/json
```

### Request Body
```json
{
  "email": "string",      // Required, registered email address
  "password": "string"    // Required, user's password
}
```

### Validation Rules
- **email**: Required, valid email format
- **password**: Required, non-empty string

### Success Response
**Code**: `200 OK`

```json
{
  "success": true,
  "message": "Login successful! Redirecting to reservation page...",
  "redirect": "reserve.html"
}
```

### Session Data Created
Upon successful login, the following session variables are set:
```php
$_SESSION['user_id']       // User's database ID
$_SESSION['email']         // User's email
$_SESSION['first_name']    // User's first name
$_SESSION['last_name']     // User's last name
$_SESSION['last_activity'] // Current timestamp
```

### Error Responses

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Email address is required"
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Password is required"
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Invalid email format"
}
```

**Code**: `401 Unauthorized`
```json
{
  "success": false,
  "message": "Invalid email or password"
}
```

**Code**: `500 Internal Server Error`
```json
{
  "success": false,
  "message": "Database error occurred. Please try again later."
}
```

### Example Request
```bash
curl -X POST http://localhost/php/login.php \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "SecurePass123"
  }'
```

### Security Features
- Password verification using `password_verify()`
- Session ID regeneration on successful login (prevents session fixation)
- Generic error message for invalid credentials (prevents user enumeration)

---

## 3. Create Reservation

### Endpoint
```
POST /php/reserve.php
```

### Description
Creates a new room reservation with availability checking and forwards booking data to Node.js server for confirmation.

### Authentication
**Required**: Yes - Valid PHP session must exist

### Request Headers
```
Content-Type: application/json
Cookie: PHPSESSID=<session_id>
```

### Request Body
```json
{
  "roomId": number,          // Required, room inventory ID
  "checkInDate": "string",   // Required, format: "YYYY-MM-DD"
  "checkOutDate": "string",  // Required, format: "YYYY-MM-DD"
  "adultsCount": number,     // Required, minimum 1
  "childrenCount": number    // Optional, default 0, minimum 0
}
```

### Validation Rules
- **roomId**: Required, must exist in `room_inventory` table
- **checkInDate**: Required, valid date format (YYYY-MM-DD), cannot be in the past
- **checkOutDate**: Required, valid date format (YYYY-MM-DD), must be after checkInDate
- **adultsCount**: Required, minimum 1
- **childrenCount**: Optional, default 0, minimum 0
- **Total guests**: (adultsCount + childrenCount) must not exceed room's max_occupancy
- **Room availability**: Room must not have overlapping confirmed bookings

### Success Response
**Code**: `201 Created`

```json
{
  "success": true,
  "message": "Reservation created successfully!",
  "data": {
    "bookingReference": "BK20251123ABC123",
    "confirmationUrl": "http://localhost:3000/confirmation/BK20251123ABC123"
  }
}
```

### Error Responses

**Code**: `401 Unauthorized`
```json
{
  "success": false,
  "message": "Session expired or invalid. Please login again."
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Missing required field: roomId"
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Invalid date format. Use YYYY-MM-DD"
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Check-in date cannot be in the past"
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Check-out date must be after check-in date"
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "At least one adult is required"
}
```

**Code**: `400 Bad Request`
```json
{
  "success": false,
  "message": "Room capacity exceeded. Maximum occupancy: 4"
}
```

**Code**: `404 Not Found`
```json
{
  "success": false,
  "message": "Room not found"
}
```

**Code**: `409 Conflict`
```json
{
  "success": false,
  "message": "Room is not available for the selected dates"
}
```

**Code**: `500 Internal Server Error`
```json
{
  "success": false,
  "message": "Database error occurred. Please try again later."
}
```

### Example Request
```bash
curl -X POST http://localhost/php/reserve.php \
  -H "Content-Type: application/json" \
  -H "Cookie: PHPSESSID=abc123xyz" \
  -d '{
    "roomId": 5,
    "checkInDate": "2025-12-01",
    "checkOutDate": "2025-12-05",
    "adultsCount": 2,
    "childrenCount": 1
  }'
```

### Database Impact
- Inserts new record into `bookings` table
- Generates unique booking reference (format: BK + YYYYMMDD + 6-char unique ID)
- Calculates total price: (nights × room price per night)
- Sets booking status to 'confirmed'
- Automatically sets `created_at` timestamp

### Integration
After successful booking creation:
1. Booking data is forwarded to Node.js server via HTTP POST to `http://localhost:3000/api/confirmation`
2. Node.js server generates confirmation page
3. Returns confirmation URL to client

### Booking Reference Format
```
BK20251123ABC123
├─ BK: Prefix
├─ 20251123: Date (YYYYMMDD)
└─ ABC123: 6-character unique identifier
```

---

## 4. User Logout

### Endpoint
```
POST /php/logout.php
```

### Description
Destroys the user's PHP session and clears session cookies.

### Authentication
**Required**: No (but typically called when user is logged in)

### Request Headers
```
Content-Type: application/json
Cookie: PHPSESSID=<session_id>
```

### Request Body
None required (can be empty JSON `{}`)

### Success Response
**Code**: `200 OK`

```json
{
  "success": true,
  "message": "Logged out successfully",
  "redirect": "index.html"
}
```

### Error Response

**Code**: `500 Internal Server Error`
```json
{
  "success": false,
  "message": "Logout failed. Please try again."
}
```

### Example Request
```bash
curl -X POST http://localhost/php/logout.php \
  -H "Content-Type: application/json" \
  -H "Cookie: PHPSESSID=abc123xyz"
```

### Session Impact
- Unsets all session variables (`$_SESSION = array()`)
- Deletes session cookie from browser
- Destroys session data on server (`session_destroy()`)

---

## 5. Database Configuration

### File
```
/php/config.php
```

### Description
Shared configuration file that establishes database connection and provides utility functions. This file is included by all other PHP scripts.

### Database Connection
```php
PDO Connection:
- Host: localhost
- Database: hotel_booking
- User: root
- Password: (empty)
- Charset: utf8mb4
```

### Utility Functions

#### `isSessionValid()`
```php
bool isSessionValid()
```
Validates if user session is active and not expired (30-minute timeout).

**Returns**: `true` if session is valid, `false` otherwise

**Side Effects**: Updates `$_SESSION['last_activity']` timestamp if valid

#### `sanitizeOutput()`
```php
string sanitizeOutput(string $data)
```
Sanitizes data for safe HTML output (prevents XSS attacks).

**Parameters**: 
- `$data`: String to sanitize

**Returns**: Sanitized string with HTML special characters encoded

#### `sanitizeInput()`
```php
string sanitizeInput(string $data)
```
Validates and sanitizes user input data.

**Parameters**: 
- `$data`: String to sanitize

**Returns**: Trimmed, stripped, and HTML-encoded string

### Session Configuration
- **Timeout**: 1800 seconds (30 minutes)
- **Cookie Lifetime**: 1800 seconds
- **Auto-start**: Yes (if not already started)

### Error Handling
- **Development Mode**: Errors displayed (`display_errors = 1`)
- **Production Mode**: Errors logged, not displayed (uncomment in config)

---

## Common Error Codes Summary

| HTTP Code | Meaning | Common Scenarios |
|-----------|---------|------------------|
| `200` | OK | Successful login, logout |
| `201` | Created | Successful registration, reservation |
| `400` | Bad Request | Invalid input, missing fields, validation errors |
| `401` | Unauthorized | Invalid credentials, expired session |
| `404` | Not Found | Room not found |
| `405` | Method Not Allowed | Wrong HTTP method (e.g., GET instead of POST) |
| `409` | Conflict | Duplicate email, room unavailable |
| `500` | Internal Server Error | Database errors, server configuration issues |

---

## Security Features

### Password Security
- Passwords hashed using `PASSWORD_BCRYPT` algorithm
- Password verification using `password_verify()`
- Minimum password strength requirements enforced

### SQL Injection Prevention
- All database queries use prepared statements with parameterized queries
- No string concatenation for SQL queries

### XSS Prevention
- All user input sanitized with `htmlspecialchars()`
- Output encoding applied before display

### Session Security
- Session ID regeneration on login (prevents session fixation)
- 30-minute session timeout on inactivity
- Session validation on protected endpoints

### Input Validation
- Server-side validation for all inputs
- Type checking and format validation
- Email format validation
- Phone number format validation (10 digits)

---

## Testing Endpoints

### Test Database Connection
```bash
curl http://localhost/test-connection.php
```

### Test Registration
```bash
curl -X POST http://localhost/php/register.php \
  -H "Content-Type: application/json" \
  -d '{"lastName":"Test","firstName":"User","address":"123 Test St","phone":"1234567890","email":"test@test.com","password":"TestPass123"}'
```

### Test Login
```bash
curl -X POST http://localhost/php/login.php \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"TestPass123"}'
```

---

## Notes

1. All endpoints return JSON responses
2. All POST endpoints require `Content-Type: application/json` header
3. Session-protected endpoints require valid `PHPSESSID` cookie
4. Timestamps are stored in UTC timezone
5. Date formats use ISO 8601 standard (YYYY-MM-DD)
6. Booking references are unique and generated server-side
7. Room availability is checked for overlapping date ranges
8. Node.js server must be running on port 3000 for reservation confirmations
