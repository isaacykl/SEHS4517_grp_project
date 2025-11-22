#!/bin/bash

################################################################################
# Login.php API Test Script
# Tests user authentication endpoint with various scenarios
################################################################################

BASE_URL="http://localhost/php"
TIMESTAMP=$(date +%s)
TEST_EMAIL="testlogin${TIMESTAMP}@example.com"
COOKIES_FILE="/tmp/test_login_cookies_${TIMESTAMP}.txt"

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

print_test_header "LOGIN.PHP - API TESTS"

################################################################################
# Setup: Create test user
################################################################################
print_test_header "SETUP: Creating test user"

curl -s -X POST "${BASE_URL}/register.php" \
  -H "Content-Type: application/json" \
  -d "{\"firstName\":\"Test\",\"lastName\":\"Login\",\"address\":\"123 Test St\",\"phone\":\"1234567890\",\"email\":\"${TEST_EMAIL}\",\"password\":\"Test123!@#\"}" > /dev/null

echo "Test user created: $TEST_EMAIL"

################################################################################
# TEST 1: Login with valid credentials
################################################################################
print_test_header "TEST 1: POST /php/login.php - Valid Credentials"

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
    print_result "Valid login" "200" "$HTTP_CODE" "true"
else
    print_result "Valid login" "200" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 2: Login with wrong password
################################################################################
print_test_header "TEST 2: POST /php/login.php - Wrong Password"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/login.php" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${TEST_EMAIL}\",\"password\":\"WrongPassword123\"}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result "Wrong password" "401" "$HTTP_CODE" "true"
else
    print_result "Wrong password" "401" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 3: Login with non-existent email
################################################################################
print_test_header "TEST 3: POST /php/login.php - Non-existent Email"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/login.php" \
  -H "Content-Type: application/json" \
  -d '{"email":"nonexistent@example.com","password":"Test123!@#"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 401 ]; then
    print_result "Non-existent email" "401" "$HTTP_CODE" "true"
else
    print_result "Non-existent email" "401" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 4: Login with missing fields
################################################################################
print_test_header "TEST 4: POST /php/login.php - Missing Fields"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/login.php" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Missing fields" "400" "$HTTP_CODE" "true"
else
    print_result "Missing fields" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 5: Login with invalid JSON
################################################################################
print_test_header "TEST 5: POST /php/login.php - Invalid JSON"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/login.php" \
  -H "Content-Type: application/json" \
  -d 'invalid json')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Invalid JSON" "400" "$HTTP_CODE" "true"
else
    print_result "Invalid JSON" "400" "$HTTP_CODE" "false"
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
