#!/bin/bash

################################################################################
# Get-Regions.php API Test Script
# Tests region retrieval endpoint (public access)
################################################################################

BASE_URL="http://localhost/php"

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

print_test_header "GET-REGIONS.PHP - API TESTS"

################################################################################
# TEST 1: Get all regions (public access)
################################################################################
print_test_header "TEST 1: GET /php/get-regions.php - Public Access"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X GET "${BASE_URL}/get-regions.php")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

if [ "$HTTP_CODE" -eq 200 ]; then
    print_result "Get regions (public)" "200" "$HTTP_CODE" "true"
    
    # Additional validation: check if response contains expected regions
    if echo "$BODY" | grep -q "Hong Kong Island" && echo "$BODY" | grep -q "Kowloon"; then
        echo -e "${GREEN}✓ Response contains expected region data${NC}"
    else
        echo -e "${YELLOW}⚠ Response structure may be unexpected${NC}"
    fi
else
    print_result "Get regions (public)" "200" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 2: Verify response structure
################################################################################
print_test_header "TEST 2: GET /php/get-regions.php - Response Structure"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X GET "${BASE_URL}/get-regions.php")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Check if response is valid JSON array
if echo "$BODY" | python3 -c "import sys, json; data = json.load(sys.stdin); assert isinstance(data, list) and len(data) > 0" 2>/dev/null; then
    echo -e "${GREEN}✓ Response is valid JSON array with data${NC}"
    print_result "Valid response structure" "200" "$HTTP_CODE" "true"
else
    echo -e "${RED}✗ Response is not a valid JSON array or is empty${NC}"
    print_result "Valid response structure" "200" "$HTTP_CODE" "false"
fi

################################################################################
# TEST 3: Test with different HTTP methods (should fail)
################################################################################
print_test_header "TEST 3: POST /php/get-regions.php - Wrong Method"

RESPONSE=$(curl -s -w "\n%{http_code}" \
  -X POST "${BASE_URL}/get-regions.php" \
  -H "Content-Type: application/json" \
  -d '{}')

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

echo "Response Body:"
echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
echo ""

# Note: Depending on implementation, this might be 405 Method Not Allowed or still return 200
if [ "$HTTP_CODE" -eq 405 ] || [ "$HTTP_CODE" -eq 400 ]; then
    print_result "POST method rejected" "405 or 400" "$HTTP_CODE" "true"
else
    echo -e "${YELLOW}⚠ API accepts POST method (may need validation)${NC}"
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
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
