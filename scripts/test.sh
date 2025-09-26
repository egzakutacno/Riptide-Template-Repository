#!/bin/bash

# Test script for Riptide Crypto Node Template
# This script runs various tests and checks

set -e

echo "🧪 Running tests for Riptide Crypto Node Template..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

# Function to run a test and capture result
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${YELLOW}Running: $test_name${NC}"
    if eval "$test_command" > /dev/null 2>&1; then
        print_status 0 "$test_name"
    else
        print_status 1 "$test_name"
        return 1
    fi
}

# Test 1: Lint check
run_test "Lint Check" "npm run lint"

# Test 2: Format check
run_test "Format Check" "npm run format -- --check"

# Test 3: Package.json validation
run_test "Package.json Validation" "node -e 'JSON.parse(require(\"fs\").readFileSync(\"package.json\", \"utf8\"))'"

# Test 4: Riptide config validation
run_test "Riptide Config Validation" "node -e 'JSON.parse(require(\"fs\").readFileSync(\"riptide.config.json\", \"utf8\"))'"

# Test 5: Hooks file syntax check
run_test "Hooks File Syntax Check" "node -c hooks.js"

# Test 6: Main file syntax check
run_test "Main File Syntax Check" "node -c index.js"

# Test 7: Environment file exists
if [ -f .env ]; then
    print_status 0 "Environment file exists"
else
    print_status 1 "Environment file missing (run setup.sh first)"
fi

# Test 8: Check if all required files exist
REQUIRED_FILES=("package.json" "riptide.config.json" "hooks.js" "index.js" "README.md")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        print_status 0 "Required file exists: $file"
    else
        print_status 1 "Required file missing: $file"
    fi
done

# Test 9: Check if dependencies are installed
if [ -d "node_modules" ]; then
    print_status 0 "Dependencies installed"
else
    print_status 1 "Dependencies not installed (run npm install)"
fi

# Test 10: Health check endpoint (if server is running)
if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    print_status 0 "Health check endpoint responding"
else
    echo -e "${YELLOW}⚠️  Health check endpoint not responding (server may not be running)${NC}"
fi

echo ""
echo "🎉 All tests completed!"
echo ""
echo "To start the development server:"
echo "  npm run dev"
echo ""
echo "To run the production server:"
echo "  npm start"
