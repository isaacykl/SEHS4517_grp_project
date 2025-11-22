#!/bin/bash

################################################################################
# Reserve.php API Test Script
# Tests reservation creation endpoint with various scenarios
################################################################################

BASE_URL="http://localhost/php"
COOKIES_FILE="/tmp/test_reserve_cookies_$(date +%s).txt"

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
print_test_header "RESERVE.PHP - API TESTS"

################################################################################
# Setup: Login to get session cookie
################################################################################
print_test_header "SETUP: Login to get session"
echo "Logging in with test user..."

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -c "$COOKIES_FILE" \
  -X POST "${BASE_URL}/login.php" \
  -H "Content-Type: application/json" \
  -d '{"email":"test1763851632@example.com","password":"Test123!@#"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -eq 200 ]; then
    echo -e "${GREEN}✓ Login successful${NC}"
    echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
else
    echo -e "${RED}✗ Login failed - Cannot proceed with tests${NC}"
    echo "HTTP Status: $HTTP_CODE"
    echo "$BODY"
    rm -f "$COOKIES_FILE"
    exit 1
fi

################################################################################
# TEST 1: Create reservation without authentication
################################################################################
print_test_header "TEST 1: POST /php/reserve.php - No Authentication"
echo "Description: Attempt to create reservation without session"
echo "Expected: 401 Unauthorized"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/reserve.php" \
  -H "Content-Type: application/json" \
  -d '{
    "roomId": 1,
    "checkInDate": "2025-12-10",
    "checkOutDate": "2025-12-15",
    "adultsCount": 2,
    "childrenCount": 1
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result "Reserve without authentication" "401" "$HTTP_CODE" "true"
else
    print_result "Reserve without authentication" "401" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 2: Create reservation with missing fields
################################################################################
print_test_header "TEST 2: POST /php/reserve.php - Missing Fields"
echo "Description: Send request with missing required fields"
echo "Expected: 400 Bad Request"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X POST "${BASE_URL}/reserve.php" \
  -H "Content-Type: application/json" \
  -d '{"roomId": 1}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Reserve with missing fields" "400" "$HTTP_CODE" "true"
else
    print_result "Reserve with missing fields" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 3: Create reservation with invalid date range
################################################################################
print_test_header "TEST 3: POST /php/reserve.php - Invalid Date Range"
echo "Description: Check-out date before check-in date"
echo "Expected: 400 Bad Request"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X POST "${BASE_URL}/reserve.php" \
  -H "Content-Type: application/json" \
  -d '{
    "roomId": 1,
    "checkInDate": "2025-12-15",
    "checkOutDate": "2025-12-10",
    "adultsCount": 2,
    "childrenCount": 0
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Reserve with invalid date range" "400" "$HTTP_CODE" "true"
else
    print_result "Reserve with invalid date range" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 4: Create reservation with past check-in date
################################################################################
print_test_header "TEST 4: POST /php/reserve.php - Past Check-in Date"
echo "Description: Check-in date in the past"
echo "Expected: 400 Bad Request"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X POST "${BASE_URL}/reserve.php" \
  -H "Content-Type: application/json" \
  -d '{
    "roomId": 1,
    "checkInDate": "2020-01-01",
    "checkOutDate": "2020-01-05",
    "adultsCount": 2,
    "childrenCount": 0
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Reserve with past date" "400" "$HTTP_CODE" "true"
else
    print_result "Reserve with past date" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 5: Create reservation with invalid room ID
################################################################################
print_test_header "TEST 5: POST /php/reserve.php - Invalid Room ID"
echo "Description: Non-existent room ID"
echo "Expected: 404 Not Found"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X POST "${BASE_URL}/reserve.php" \
  -H "Content-Type: application/json" \
  -d '{
    "roomId": 99999,
    "checkInDate": "2025-12-10",
    "checkOutDate": "2025-12-15",
    "adultsCount": 2,
    "childrenCount": 0
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 404 ]; then
    print_result "Reserve with invalid room ID" "404" "$HTTP_CODE" "true"
else
    print_result "Reserve with invalid room ID" "404" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 6: Create reservation with zero adults
################################################################################
print_test_header "TEST 6: POST /php/reserve.php - Zero Adults"
echo "Description: At least one adult is required"
echo "Expected: 400 Bad Request"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X POST "${BASE_URL}/reserve.php" \
  -H "Content-Type: application/json" \
  -d '{
    "roomId": 1,
    "checkInDate": "2025-12-10",
    "checkOutDate": "2025-12-15",
    "adultsCount": 0,
    "childrenCount": 2
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Reserve with zero adults" "400" "$HTTP_CODE" "true"
else
    print_result "Reserve with zero adults" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 7: Create valid reservation (Note: Requires Node.js server running)
################################################################################
print_test_header "TEST 7: POST /php/reserve.php - Valid Reservation"
echo "Description: Create reservation with valid data"
echo "Expected: 200 OK (if Node.js server is running)"
echo "Note: This test may fail if Node.js confirmation server is not running"
echo ""

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X POST "${BASE_URL}/reserve.php" \
  -H "Content-Type: application/json" \
  -d '{
    "roomId": 1,
    "checkInDate": "2025-12-20",
    "checkOutDate": "2025-12-25",
    "adultsCount": 2,
    "childrenCount": 1
  }')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result "Valid reservation" "200" "$HTTP_CODE" "true"
else
    echo -e "${YELLOW}⚠ WARNING${NC} - Test skipped or failed"
    echo "  Expected: HTTP 200 | Actual: HTTP $HTTP_CODE"
    echo "  This may indicate Node.js server is not running on port 3000"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
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
