#!/bin/bash

################################################################################
# API Test Script for SEHS4517 Hotel Booking System
# Tests all PHP endpoints with various scenarios
################################################################################

BASE_URL="http://localhost/php"
COOKIES_FILE="/tmp/test_cookies_$(date +%s).txt"
TIMESTAMP=$(date +%s)
TEST_EMAIL="test${TIMESTAMP}@example.com"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to print test header
print_test_header() {
    echo ""
    echo "================================"
    echo -e "${BLUE}$1${NC}"
    echo "================================"
    echo ""
}

# Function to print test result
print_result() {
    local test_name=$1
    local expected_code=$2
    local actual_code=$3
    local pass=$4
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$pass" = "true" ]; then
        echo -e "${GREEN}✓ PASS${NC} - $test_name"
        echo "  Expected: HTTP $expected_code | Actual: HTTP $actual_code"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}✗ FAIL${NC} - $test_name"
        echo "  Expected: HTTP $expected_code | Actual: HTTP $actual_code"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Start testing
print_test_header "HOTEL BOOKING SYSTEM - API TESTS"
echo "Test Email: $TEST_EMAIL"
echo "Cookies File: $COOKIES_FILE"
echo ""

################################################################################
# TEST 1: Get Regions (Public Endpoint)
################################################################################
print_test_header "TEST 1: GET /php/get-regions.php"
echo "Description: Retrieve all available regions"
echo "Expected: 200 OK with JSON array of regions"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "${BASE_URL}/get-regions.php")
HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result "Get Regions" "200" "$HTTP_CODE" "true"
else
    print_result "Get Regions" "200" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 2: Register New User
################################################################################
print_test_header "TEST 2: POST /php/register.php - New User"
echo "Description: Register a new user account"
echo "Expected: 201 Created"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/register.php" \
  -H "Content-Type: application/json" \
  -d "{\"firstName\":\"Test\",\"lastName\":\"User\",\"address\":\"123 Test St\",\"phone\":\"1234567890\",\"email\":\"${TEST_EMAIL}\",\"password\":\"Test123!@#\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 201 ]; then
    print_result "Register New User" "201" "$HTTP_CODE" "true"
else
    print_result "Register New User" "201" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 3: Register Duplicate User
################################################################################
print_test_header "TEST 3: POST /php/register.php - Duplicate Email"
echo "Description: Attempt to register with existing email"
echo "Expected: 409 Conflict"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/register.php" \
  -H "Content-Type: application/json" \
  -d "{\"firstName\":\"Test\",\"lastName\":\"User\",\"address\":\"123 Test St\",\"phone\":\"1234567890\",\"email\":\"${TEST_EMAIL}\",\"password\":\"Test123!@#\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 409 ]; then
    print_result "Register Duplicate User" "409" "$HTTP_CODE" "true"
else
    print_result "Register Duplicate User" "409" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 4: Register with Missing Fields
################################################################################
print_test_header "TEST 4: POST /php/register.php - Missing Fields"
echo "Description: Register with incomplete data"
echo "Expected: 400 Bad Request"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/register.php" \
  -H "Content-Type: application/json" \
  -d '{"email":"incomplete@test.com"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Register Missing Fields" "400" "$HTTP_CODE" "true"
else
    print_result "Register Missing Fields" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 5: Login with Valid Credentials
################################################################################
print_test_header "TEST 5: POST /php/login.php - Valid Login"
echo "Description: Login with correct credentials"
echo "Expected: 200 OK with session cookie"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -c "$COOKIES_FILE" \
  -X POST "${BASE_URL}/login.php" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${TEST_EMAIL}\",\"password\":\"Test123!@#\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result "Login Valid Credentials" "200" "$HTTP_CODE" "true"
else
    print_result "Login Valid Credentials" "200" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 6: Login with Invalid Credentials
################################################################################
print_test_header "TEST 6: POST /php/login.php - Invalid Login"
echo "Description: Login with wrong password"
echo "Expected: 401 Unauthorized"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/login.php" \
  -H "Content-Type: application/json" \
  -d '{"email":"invalid@test.com","password":"wrongpassword"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result "Login Invalid Credentials" "401" "$HTTP_CODE" "true"
else
    print_result "Login Invalid Credentials" "401" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 7: Check Session (Authenticated)
################################################################################
print_test_header "TEST 7: GET /php/check-session.php - With Cookie"
echo "Description: Verify session is valid"
echo "Expected: 200 OK with user data"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X GET "${BASE_URL}/check-session.php")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result "Check Session (Authenticated)" "200" "$HTTP_CODE" "true"
else
    print_result "Check Session (Authenticated)" "200" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 8: Check Session (Unauthenticated)
################################################################################
print_test_header "TEST 8: GET /php/check-session.php - No Cookie"
echo "Description: Check session without authentication"
echo "Expected: 401 Unauthorized"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X GET "${BASE_URL}/check-session.php")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result "Check Session (Unauthenticated)" "401" "$HTTP_CODE" "true"
else
    print_result "Check Session (Unauthenticated)" "401" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 9: Get Hotels (Authenticated)
################################################################################
print_test_header "TEST 9: POST /php/get-hotels.php - With Auth"
echo "Description: Search hotels in a region with dates"
echo "Expected: 200 OK with hotels array"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X POST "${BASE_URL}/get-hotels.php" \
  -H "Content-Type: application/json" \
  -d '{"regionId":1,"checkInDate":"2025-12-01","checkOutDate":"2025-12-05"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result "Get Hotels (Authenticated)" "200" "$HTTP_CODE" "true"
else
    print_result "Get Hotels (Authenticated)" "200" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 10: Get Hotels (Unauthenticated)
################################################################################
print_test_header "TEST 10: POST /php/get-hotels.php - No Auth"
echo "Description: Search hotels without authentication"
echo "Expected: 401 Unauthorized"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/get-hotels.php" \
  -H "Content-Type: application/json" \
  -d '{"regionId":1,"checkInDate":"2025-12-01","checkOutDate":"2025-12-05"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result "Get Hotels (Unauthenticated)" "401" "$HTTP_CODE" "true"
else
    print_result "Get Hotels (Unauthenticated)" "401" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 11: Get Hotels with Invalid Data
################################################################################
print_test_header "TEST 11: POST /php/get-hotels.php - Invalid Date"
echo "Description: Search hotels with check-out before check-in"
echo "Expected: 400 Bad Request"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X POST "${BASE_URL}/get-hotels.php" \
  -H "Content-Type: application/json" \
  -d '{"regionId":1,"checkInDate":"2025-12-05","checkOutDate":"2025-12-01"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Get Hotels Invalid Date" "400" "$HTTP_CODE" "true"
else
    print_result "Get Hotels Invalid Date" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 12: Get Rooms (Authenticated)
################################################################################
print_test_header "TEST 12: POST /php/get-rooms.php - With Auth"
echo "Description: Get available rooms for a hotel"
echo "Expected: 200 OK with rooms array"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X POST "${BASE_URL}/get-rooms.php" \
  -H "Content-Type: application/json" \
  -d '{"hotelId":1,"checkInDate":"2025-12-01","checkOutDate":"2025-12-05"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result "Get Rooms (Authenticated)" "200" "$HTTP_CODE" "true"
else
    print_result "Get Rooms (Authenticated)" "200" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 13: Get Rooms (Unauthenticated)
################################################################################
print_test_header "TEST 13: POST /php/get-rooms.php - No Auth"
echo "Description: Get rooms without authentication"
echo "Expected: 401 Unauthorized"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/get-rooms.php" \
  -H "Content-Type: application/json" \
  -d '{"hotelId":1,"checkInDate":"2025-12-01","checkOutDate":"2025-12-05"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result "Get Rooms (Unauthenticated)" "401" "$HTTP_CODE" "true"
else
    print_result "Get Rooms (Unauthenticated)" "401" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 14: Logout
################################################################################
print_test_header "TEST 14: POST /php/logout.php"
echo "Description: Logout and destroy session"
echo "Expected: 200 OK"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X POST "${BASE_URL}/logout.php")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result "Logout" "200" "$HTTP_CODE" "true"
else
    print_result "Logout" "200" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 15: Check Session After Logout
################################################################################
print_test_header "TEST 15: GET /php/check-session.php - After Logout"
echo "Description: Verify session is destroyed"
echo "Expected: 401 Unauthorized"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X GET "${BASE_URL}/check-session.php")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result "Check Session After Logout" "401" "$HTTP_CODE" "true"
else
    print_result "Check Session After Logout" "401" "$HTTP_CODE" "false"
fi

################################################################################
# Clean up
################################################################################
rm -f "$COOKIES_FILE"

################################################################################
# Test Summary
################################################################################
print_test_header "TEST SUMMARY"

echo -e "Total Tests:  ${BLUE}${TOTAL_TESTS}${NC}"
echo -e "Passed:       ${GREEN}${PASSED_TESTS}${NC}"
echo -e "Failed:       ${RED}${FAILED_TESTS}${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ ALL TESTS PASSED!${NC}"
    exit 0
else
    PASS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo -e "${YELLOW}⚠ Pass Rate: ${PASS_RATE}%${NC}"
    exit 1
fi
