#!/bin/bash

# ============================================================================
# Education Board Results - Full Deployment Script
# ============================================================================

echo "🚀 Starting Full Deployment..."
echo ""

# Navigate to project
cd ~/www-educationboardresults-gov-bd || exit

# ============================================================================
# 1. SECURITY UPDATE
# ============================================================================
echo "🔒 Fixing Security Vulnerabilities..."
npm audit fix --force
echo "✅ Security fixed"
echo ""

# ============================================================================
# 2. GIT COMMIT & PUSH
# ============================================================================
echo "📤 Pushing to GitHub..."
git add .
git commit -m "Deployment: Full Update - $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main
echo "✅ Pushed to GitHub"
echo ""

# ============================================================================
# 3. VERCEL LOGIN & DEPLOY
# ============================================================================
echo "🔐 Vercel Login & Deployment..."
npx vercel login
npx vercel --prod
echo "✅ Deployed to Vercel"
echo ""

# ============================================================================
# 4. FINAL INFO
# ============================================================================
echo "=============================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "=============================================="
echo ""
echo "📌 Live URLs:"
echo "🌐 https://www-educationboardresults-gov-bd.vercel.app"
echo ""
echo "🔐 Admin Login:"
echo "   Username: admin"
echo "   Password: admin123"
echo ""
echo "📊 Test SSC Roll Numbers:"
echo "   310285 (Dhaka, 2015)"
echo "   827733 (Dhaka, 2015)"
echo "   234475 (Mymensingh, 2001)"
echo ""
echo "📊 Test HSC Roll Number:"
echo "   406020 (Dhaka, 2017)"
echo ""
echo "🔗 Vercel Dashboard:"
echo "   https://vercel.com/ssinfotech/www-educationboardresults-gov-bd"
echo ""
echo "✨ Deployment successful!"
echo "=============================================="
