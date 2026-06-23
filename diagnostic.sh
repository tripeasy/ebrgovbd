#!/bin/bash

# ============================================================================
# COMPREHENSIVE DIAGNOSTIC SCRIPT
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PASSED=0
FAILED=0
WARNINGS=0

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}════════════════════════════════════════${NC}"
}

check_pass() {
    echo -e "${GREEN}✅ $1${NC}"
    PASSED=$((PASSED+1))
}

check_fail() {
    echo -e "${RED}❌ $1${NC}"
    FAILED=$((FAILED+1))
}

check_warn() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    WARNINGS=$((WARNINGS+1))
}

file_exists() {
    if [ -f "$1" ]; then
        check_pass "File exists: $1"
        return 0
    else
        check_fail "File missing: $1"
        return 1
    fi
}

check_json() {
    local file="$1"
    if [ -f "$file" ]; then
        if node -e "require('$file')" 2>/dev/null; then
            check_pass "Valid JSON: $file"
            return 0
        else
            check_fail "Invalid JSON: $file"
            return 1
        fi
    else
        check_fail "File not found: $file"
        return 1
    fi
}

check_string_in_file() {
    local file="$1"
    local string="$2"
    local description="$3"
    
    if [ -f "$file" ]; then
        if grep -q "$string" "$file"; then
            check_pass "$description"
            return 0
        else
            check_fail "$description (not found in $file)"
            return 1
        fi
    else
        check_fail "File not found: $file"
        return 1
    fi
}

# ============================================================================
# START DIAGNOSTIC
# ============================================================================

print_header "🔍 EDUCATION BOARD SYSTEM - DIAGNOSTIC CHECK"

echo -e "${BLUE}Starting comprehensive system check...${NC}"
echo "Time: $(date)"
echo "Working Directory: $(pwd)"
echo ""

# ============================================================================
# 1. FILE STRUCTURE CHECK
# ============================================================================

print_header "1️⃣ FILE STRUCTURE CHECK"

file_exists "package.json"
file_exists "vercel.json"
file_exists "backend/server.js"
file_exists "admin/admin.html"
file_exists "admin/login.html"
file_exists "frontend/home.html"
file_exists ".gitignore"
file_exists "README.md"

# ============================================================================
# 2. PACKAGE.JSON VALIDATION
# ============================================================================

print_header "2️⃣ PACKAGE.JSON VALIDATION"

if check_json "package.json"; then
    # Check required dependencies
    check_string_in_file "package.json" "express" "Express.js dependency found"
    check_string_in_file "package.json" "express-session" "Session management found"
    check_string_in_file "package.json" "cors" "CORS support found"
    check_string_in_file "package.json" "compression" "Compression middleware found"
fi

# ============================================================================
# 3. VERCEL.JSON VALIDATION
# ============================================================================

print_header "3️⃣ VERCEL CONFIGURATION CHECK"

if check_json "vercel.json"; then
    check_string_in_file "vercel.json" "backend/server.js" "Backend server configured"
    check_string_in_file "vercel.json" "/login" "Login route configured"
    check_string_in_file "vercel.json" "/admin" "Admin route configured"
    check_string_in_file "vercel.json" "ADMIN_PASSWORD" "Environment variable set"
fi

# ============================================================================
# 4. BACKEND CODE CHECK
# ============================================================================

print_header "4️⃣ BACKEND CODE VALIDATION"

if file_exists "backend/server.js"; then
    check_string_in_file "backend/server.js" "app.post('/admin/login'" "Login endpoint found"
    check_string_in_file "backend/server.js" "app.get('/admin/check'" "Auth check endpoint found"
    check_string_in_file "backend/server.js" "app.get('/admin/admins'" "Admin list endpoint found"
    check_string_in_file "backend/server.js" "app.post('/admin/add-subadmin'" "Sub-admin creation found"
    check_string_in_file "backend/server.js" "app.delete('/admin/subadmin/" "Sub-admin deletion found"
    check_string_in_file "backend/server.js" "app.post('/admin/change-password'" "Password change endpoint found"
    check_string_in_file "backend/server.js" "app.post('/admin/lock-subadmin'" "Account lock/unlock found"
    check_string_in_file "backend/server.js" "app.post('/v2/getres'" "Student result endpoint found"
fi

# ============================================================================
# 5. FRONTEND CODE CHECK
# ============================================================================

print_header "5️⃣ FRONTEND CODE VALIDATION"

if file_exists "admin/login.html"; then
    check_string_in_file "admin/login.html" "handleLogin" "Login form handler found"
    check_string_in_file "admin/login.html" "/admin/login" "Login endpoint called"
    check_string_in_file "admin/login.html" "credentials: 'include'" "Session credentials enabled"
fi

if file_exists "admin/admin.html"; then
    check_string_in_file "admin/admin.html" "checkAuth()" "Auth check function found"
    check_string_in_file "admin/admin.html" "loadStudents()" "Load students function found"
    check_string_in_file "admin/admin.html" "/admin/check" "Auth check endpoint called"
    check_string_in_file "admin/admin.html" "credentials: 'include'" "Session credentials enabled"
fi

# ============================================================================
# 6. SECURITY CHECK
# ============================================================================

print_header "6️⃣ SECURITY VALIDATION"

check_string_in_file "backend/server.js" "helmet()" "Helmet security enabled"
check_string_in_file "backend/server.js" "cors()" "CORS enabled"
check_string_in_file "backend/server.js" "express.json()" "JSON parser configured"
check_string_in_file "backend/server.js" "session({" "Session management enabled"
check_string_in_file "backend/server.js" "req.session.admin" "Admin session check implemented"
check_string_in_file "backend/server.js" "req.session.adminRole" "Role-based access control found"

# ============================================================================
# 7. DATABASE/DATA STRUCTURE CHECK
# ============================================================================

print_header "7️⃣ DATA STRUCTURE VALIDATION"

check_string_in_file "backend/server.js" "let adminUsers = {" "Admin users database found"
check_string_in_file "backend/server.js" "let studentsData = {" "Student data structure found"
check_string_in_file "backend/server.js" "ssc:" "SSC exam data found"
check_string_in_file "backend/server.js" "hsc:" "HSC exam data found"
check_string_in_file "backend/server.js" "addedBy:" "Data tracking (addedBy) found"

# ============================================================================
# 8. GIT STATUS CHECK
# ============================================================================

print_header "8️⃣ GIT REPOSITORY CHECK"

if [ -d ".git" ]; then
    check_pass "Git repository initialized"
    
    # Check git config
    if git config user.email > /dev/null 2>&1; then
        check_pass "Git user configured"
    else
        check_warn "Git user not configured (run: git config user.email/user.name)"
    fi
    
    # Check git remote
    if git remote -v | grep -q "github"; then
        check_pass "GitHub remote configured"
    else
        check_fail "GitHub remote not configured"
    fi
else
    check_fail "Git repository not initialized"
fi

# ============================================================================
# 9. DEPENDENCIES CHECK
# ============================================================================

print_header "9️⃣ NPM DEPENDENCIES CHECK"

if [ -f "package.json" ] && [ -d "node_modules" ]; then
    check_pass "Dependencies installed (node_modules exists)"
    
    # Check specific packages
    if [ -d "node_modules/express" ]; then
        check_pass "Express installed"
    else
        check_fail "Express not installed"
    fi
    
    if [ -d "node_modules/express-session" ]; then
        check_pass "Express-session installed"
    else
        check_fail "Express-session not installed"
    fi
else
    check_warn "Run 'npm install' to install dependencies"
fi

# ============================================================================
# 10. VERCEL STATUS CHECK
# ============================================================================

print_header "🔟 VERCEL DEPLOYMENT CHECK"

if command -v vercel &> /dev/null; then
    check_pass "Vercel CLI installed"
    
    # Try to get project info
    if vercel whoami > /dev/null 2>&1; then
        check_pass "Vercel authenticated"
    else
        check_warn "Vercel not authenticated (run: vercel login)"
    fi
else
    check_warn "Vercel CLI not installed"
fi

# ============================================================================
# 11. ENVIRONMENT VARIABLES CHECK
# ============================================================================

print_header "1️⃣1️⃣ ENVIRONMENT VARIABLES CHECK"

if grep -q "ADMIN_PASSWORD" vercel.json; then
    check_pass "ADMIN_PASSWORD defined in vercel.json"
else
    check_fail "ADMIN_PASSWORD not found in vercel.json"
fi

if grep -q "NODE_ENV" vercel.json; then
    check_pass "NODE_ENV defined in vercel.json"
else
    check_fail "NODE_ENV not found in vercel.json"
fi

# ============================================================================
# 12. FEATURE COMPLETENESS CHECK
# ============================================================================

print_header "1️⃣2️⃣ FEATURE COMPLETENESS CHECK"

check_string_in_file "backend/server.js" "super_admin" "Super admin role found"
check_string_in_file "backend/server.js" "sub_admin" "Sub-admin role found"
check_string_in_file "backend/server.js" "dataFilter" "Data filtering implemented"
check_string_in_file "backend/server.js" "allowEdit" "Edit permission control found"
check_string_in_file "backend/server.js" "locked" "Account lock feature found"
check_string_in_file "backend/server.js" "getStudentsByAdmin" "Role-based data retrieval found"

# ============================================================================
# SUMMARY
# ============================================================================

print_header "📊 DIAGNOSTIC SUMMARY"

echo ""
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo -e "${YELLOW}Warnings: $WARNINGS${NC}"
echo ""

TOTAL=$((PASSED + FAILED + WARNINGS))
echo "Total Checks: $TOTAL"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ ALL SYSTEMS OPERATIONAL!${NC}"
    echo ""
    echo "🚀 Your system is ready for deployment!"
    echo ""
    echo "Quick Actions:"
    echo "  1. Deploy: npx vercel --prod"
    echo "  2. Test Login: https://www-educationboardresults-gov-bd.vercel.app/login"
    echo "  3. View Logs: npx vercel logs https://www-educationboardresults-gov-bd.vercel.app"
else
    echo -e "${RED}❌ SYSTEM NEEDS FIXES!${NC}"
    echo ""
    echo "Issues found: $FAILED"
    echo "Please fix the failed checks above before deployment."
fi

echo ""
echo "Diagnostic Report Generated: $(date)"
echo ""
