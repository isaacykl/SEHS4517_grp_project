# Server-Side Functions blueprint

## Overview
This document summarizes the server-side functions required for the hotel booking reservation system based on the project specification.

## PHP Functions Required: 8

### Core Functions (Required by Specification)

#### 1. User Registration Handler (`register.php`)
- **Purpose**: Process member registration form submission
- **Inputs**: 
  - Last name
  - First name
  - Mailing address
  - Contact phone number
  - Email address
  - Password
- **Processing**:
  - Validate user input
  - Hash password for security
  - Store user data in MySQL `users` table
- **Output**: Success/error response to client

#### 2. Login Authentication Handler (`login.php`)
- **Purpose**: Validate user credentials for system access
- **Inputs**:
  - Email address
  - Password
- **Processing**:
  - Query MySQL database to verify email and password
  - Check if credentials match
  - Create session for authenticated user
- **Output**:
  - If incorrect: 401 Unauthorized error response
  - If correct: 200 OK with redirect to reservation page

#### 3. Reservation Processing Handler (`reserve.php`)
- **Purpose**: Process facility reservation and forward to Node.js server
- **Inputs**:
  - Room ID
  - Check-in date
  - Check-out date
  - Adults count
  - Children count (optional)
- **Processing**:
  - Validate session
  - Check room availability
  - Store reservation information in MySQL `bookings` table
  - Forward reservation data to Node.js/Express server via HTTP request
- **Output**: Trigger Node.js response generation

### Supporting Functions (For Complete Workflow)

#### 4. Session Validation Handler (`check-session.php`)
- **Purpose**: Verify user authentication status
- **Inputs**: PHP session cookie
- **Processing**:
  - Check if session exists and is valid
  - Verify session hasn't expired (30-minute timeout)
- **Output**: User session data or 401 Unauthorized

#### 5. Logout Handler (`logout.php`)
- **Purpose**: Destroy user session and clear authentication
- **Inputs**: PHP session cookie
- **Processing**:
  - Destroy PHP session
  - Clear session cookies
- **Output**: Success response with redirect to homepage

#### 6. Get Regions Handler (`get-regions.php`)
- **Purpose**: Retrieve list of available hotel regions
- **Inputs**: None (public endpoint)
- **Processing**:
  - Query MySQL `regions` table
  - Return all regions sorted alphabetically
- **Output**: JSON array of regions with ID and name

#### 7. Get Hotels Handler (`get-hotels.php`)
- **Purpose**: Search for available hotels by region and dates
- **Inputs**:
  - Region ID
  - Check-in date
  - Check-out date
- **Processing**:
  - Validate session
  - Query hotels with available rooms for date range
  - Exclude hotels with no availability
- **Output**: JSON array of hotels with availability counts

#### 8. Get Rooms Handler (`get-rooms.php`)
- **Purpose**: Retrieve available rooms for a specific hotel
- **Inputs**:
  - Hotel ID
  - Check-in date
  - Check-out date
- **Processing**:
  - Validate session
  - Query room inventory
  - Check availability against bookings
  - Return room details with pricing
- **Output**: JSON array of available rooms with details

## Node.js/Express Functions Required: 1

### 1. Reservation Confirmation Handler (Express route)
- **Purpose**: Generate "thank you" confirmation page
- **Inputs**: 
  - User email address
  - Reservation details (date, time, facility)
- **Processing**:
  - Receive data from PHP reservation handler
  - Format confirmation message
- **Output**: Generate 5th web page showing:
  - "Thank you" message
  - User's email address
  - Reservation information
  - "OK" button to return to homepage

## Total Server-Side Functions: 9
- **PHP**: 8 functions (3 core + 5 supporting)
- **Node.js/Express**: 1 function

## Summary by Category

### Authentication & Session Management (3)
1. `register.php` - User registration
2. `login.php` - User authentication
3. `check-session.php` - Session validation
4. `logout.php` - Session destruction

### Reservation Workflow (4)
1. `get-regions.php` - List regions (public)
2. `get-hotels.php` - Search hotels by region/dates (authenticated)
3. `get-rooms.php` - List rooms for hotel (authenticated)
4. `reserve.php` - Create booking (authenticated)

## Technology Stack
- **Frontend**: HTML5 (XHTML syntax), JavaScript, jQuery
- **Backend**: PHP, Node.js with Express.js
- **Database**: MySQL
- **Web Server**: Apache (for PHP), Node.js server (for Express)
