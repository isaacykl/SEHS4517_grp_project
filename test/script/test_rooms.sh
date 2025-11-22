#!/bin/bash

################################################################################
# Get-Rooms.php API Test Script
# Tests room availability endpoint with authentication and various scenarios
################################################################################

BASE_URL="http://localhost/php"
TIMESTAMP=$(date +%s)
TEST_EMAIL="testrooms${TIMESTAMP}@example.com"
COOKIES_FILE="/tmp/test_rooms_cookies_${TIMESTAMP}.txt"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

print_test_header() {
    echo ""
    echo "================================"
    echo -e "${BLUE}$1${NC}"
    echo "================================"
    echo ""
}

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

print_test_header "GET-ROOMS.PHP - API TESTS"

################################################################################
# Setup: Create test user and login
################################################################################
print_test_header "SETUP: Creating test user and logging in"

curl -s -X POST "${BASE_URL}/register.php" \
  -H "Content-Type: application/json" \
  -d "{\"firstName\":\"Test\",\"lastName\":\"Rooms\",\"address\":\"123 Test St\",\"phone\":\"1234567890\",\"email\":\"${TEST_EMAIL}\",\"password\":\"Test123!@#\"}" > /dev/null

curl -s -c "$COOKIES_FILE" \
  -X POST "${BASE_URL}/login.php" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${TEST_EMAIL}\",\"password\":\"Test123!@#\"}" > /dev/null

echo "Test user logged in: $TEST_EMAIL"

################################################################################
# TEST 1: Get rooms without authentication
################################################################################
print_test_header "TEST 1: GET /php/get-rooms.php - No Authentication"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X GET "${BASE_URL}/get-rooms.php?hotelId=1&checkInDate=2025-12-10&checkOutDate=2025-12-15")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result "Get rooms without auth" "401" "$HTTP_CODE" "true"
else
    print_result "Get rooms without auth" "401" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 2: Get rooms with valid parameters
################################################################################
print_test_header "TEST 2: GET /php/get-rooms.php - Valid Request"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X GET "${BASE_URL}/get-rooms.php?hotelId=1&checkInDate=2025-12-10&checkOutDate=2025-12-15")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result "Valid room search" "200" "$HTTP_CODE" "true"
else
    print_result "Valid room search" "200" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 3: Get rooms with missing parameters
################################################################################
print_test_header "TEST 3: GET /php/get-rooms.php - Missing Parameters"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X GET "${BASE_URL}/get-rooms.php?hotelId=1")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Missing parameters" "400" "$HTTP_CODE" "true"
else
    print_result "Missing parameters" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 4: Get rooms with invalid date range
################################################################################
print_test_header "TEST 4: GET /php/get-rooms.php - Invalid Date Range"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X GET "${BASE_URL}/get-rooms.php?hotelId=1&checkInDate=2025-12-15&checkOutDate=2025-12-10")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Invalid date range" "400" "$HTTP_CODE" "true"
else
    print_result "Invalid date range" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 5: Get rooms with invalid hotel ID
################################################################################
print_test_header "TEST 5: GET /php/get-rooms.php - Invalid Hotel ID"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X GET "${BASE_URL}/get-rooms.php?hotelId=99999&checkInDate=2025-12-10&checkOutDate=2025-12-15")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

# This might return 200 with empty array or 404
if [ "$HTTP_CODE" -eq 200 ] || [ "$HTTP_CODE" -eq 404 ]; then
    print_result "Invalid hotel ID" "200 or 404" "$HTTP_CODE" "true"
else
    print_result "Invalid hotel ID" "200 or 404" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 6: Get rooms with past check-in date
################################################################################
print_test_header "TEST 6: GET /php/get-rooms.php - Past Check-in Date"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -b "$COOKIES_FILE" \
  -X GET "${BASE_URL}/get-rooms.php?hotelId=1&checkInDate=2020-01-01&checkOutDate=2020-01-05")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Past check-in date" "400" "$HTTP_CODE" "true"
else
    print_result "Past check-in date" "400" "$HTTP_CODE" "false"
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
