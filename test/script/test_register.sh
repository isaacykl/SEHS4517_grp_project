#!/bin/bash

################################################################################
# Register.php API Test Script
# Tests user registration endpoint with various scenarios
################################################################################

BASE_URL="http://localhost/php"
TIMESTAMP=$(date +%s)
TEST_EMAIL="testreg${TIMESTAMP}@example.com"

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

print_test_header "REGISTER.PHP - API TESTS"
echo "Test Email: $TEST_EMAIL"
echo ""

################################################################################
# TEST 1: Register with valid data
################################################################################
print_test_header "TEST 1: POST /php/register.php - Valid Registration"

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
    print_result "Valid registration" "201" "$HTTP_CODE" "true"
else
    print_result "Valid registration" "201" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 2: Register duplicate email
################################################################################
print_test_header "TEST 2: POST /php/register.php - Duplicate Email"

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
    print_result "Duplicate email" "409" "$HTTP_CODE" "true"
else
    print_result "Duplicate email" "409" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 3: Missing required fields
################################################################################
print_test_header "TEST 3: POST /php/register.php - Missing Fields"

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
    print_result "Missing fields" "400" "$HTTP_CODE" "true"
else
    print_result "Missing fields" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 4: Invalid email format
################################################################################
print_test_header "TEST 4: POST /php/register.php - Invalid Email"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/register.php" \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Test","lastName":"User","address":"123 Test St","phone":"1234567890","email":"invalid-email","password":"Test123!@#"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Invalid email format" "400" "$HTTP_CODE" "true"
else
    print_result "Invalid email format" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 5: Invalid phone format
################################################################################
print_test_header "TEST 5: POST /php/register.php - Invalid Phone"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/register.php" \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Test","lastName":"User","address":"123 Test St","phone":"123","email":"test@example.com","password":"Test123!@#"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Invalid phone format" "400" "$HTTP_CODE" "true"
else
    print_result "Invalid phone format" "400" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 6: Weak password
################################################################################
print_test_header "TEST 6: POST /php/register.php - Weak Password"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/register.php" \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Test","lastName":"User","address":"123 Test St","phone":"1234567890","email":"test2@example.com","password":"weak"}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 400 ]; then
    print_result "Weak password" "400" "$HTTP_CODE" "true"
else
    print_result "Weak password" "400" "$HTTP_CODE" "false"
fi

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
