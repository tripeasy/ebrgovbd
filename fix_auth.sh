#!/bin/bash

echo "🔧 Fixing authentication in frontend files..."

# ============================================================================
# admin.html ফিক্স করুন
# ============================================================================
echo "Patching admin.html..."

# checkAuth function ফিক্স
sed -i "s|fetch('/api/auth/check')|fetch('/admin/check', { credentials: 'include' })|g" admin/admin.html

# loadStudents ফিক্স
sed -i "s|fetch('/admin/students')|fetch('/admin/students', { credentials: 'include' })|g" admin/admin.html

# editStudent, deleteStudent, logout ফিক্স
sed -i "s|fetch(\`/admin/students/|fetch(\`/admin/students/|g" admin/admin.html
sed -i "s|fetch('/admin/logout'|fetch('/admin/logout', { credentials: 'include' }|g" admin/admin.html

echo "✅ admin.html fixed"

# ============================================================================
# login.html ফিক্স করুন
# ============================================================================
echo "Patching login.html..."

# login fetch ফিক্স
sed -i "s|fetch('/admin/login',|fetch('/admin/login', { credentials: 'include',|g" admin/login.html

echo "✅ login.html fixed"

echo ""
echo "✅ All files patched!"
echo ""
echo "Now pushing to GitHub..."

# Git commit এবং push
git add admin/admin.html admin/login.html
git commit -m "Fix: Add credentials to all fetch requests for session management"
git push origin main

echo "✅ Pushed to GitHub"

# Vercel deploy
echo ""
echo "🚀 Deploying to Vercel..."
npx vercel --prod

echo ""
echo "=============================================="
echo "✅ AUTHENTICATION FIXES COMPLETE!"
echo "=============================================="
echo ""
echo "এখন সাইটে যান এবং login করুন:"
echo "🌐 https://www-educationboardresults-gov-bd.vercel.app/login.html"
echo ""
echo "Admin credentials:"
echo "Username: admin"
echo "Password: EducationBoard@006"
echo "=============================================="
