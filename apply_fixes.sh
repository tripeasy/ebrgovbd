#!/usr/bin/env bash
set -e

TS=$(date +%s)
FILES_UPDATED=0

backup_file() {
  local f="$1"
  if [ -f "$f" ]; then
    cp -v "$f" "${f}.bak.$TS"
  else
    echo "Warning: file not found: $f"
  fi
}

replace_in_file() {
  local f="$1"
  local desc="$2"
  local cmd="$3"
  if [ -f "$f" ]; then
    echo "-> $desc in $f"
    eval "$cmd"
    FILES_UPDATED=$((FILES_UPDATED+1))
  else
    echo "!! skipped (not found): $f"
  fi
}

echo "Starting automatic frontend auth fixes..."
echo "Working directory: $(pwd)"
echo ""

# Files to patch
ADMIN_HTML="admin/admin.html"
LOGIN_HTML="admin/login.html"

# Backups
backup_file "$ADMIN_HTML"
backup_file "$LOGIN_HTML"

echo ""
# 1) Fix checkAuth() path and add credentials in admin/admin.html
replace_in_file "$ADMIN_HTML" "change /api/auth/check -> /admin/check and add credentials" \
  "sed -i \"s|const res = await fetch('/api/auth/check');|const res = await fetch('/admin/check', { credentials: 'include' });|g\" \"$ADMIN_HTML\" || true"

# 2) Add credentials to simple fetch('/admin/students') calls
replace_in_file "$ADMIN_HTML" "add credentials to fetch('/admin/students')" \
  "sed -i \"s|fetch('/admin/students')|fetch('/admin/students', { credentials: 'include' })|g\" \"$ADMIN_HTML\" || true"

# 3) Add credentials when using template literal fetch(`/admin/students/${roll}`)
# need to escape $ for shell -> use \\\${roll} in sed pattern, and \${roll} in replacement
replace_in_file "$ADMIN_HTML" \"add credentials to fetch(\`/admin/students/\${roll}\`)\" \
  "sed -i \"s|fetch(\`/admin/students/\\\${roll}\`)|fetch(\`/admin/students/\\\${roll}\`, { credentials: 'include' })|g\" \"$ADMIN_HTML\" || true"

# 4) For fetch calls that already pass an options object, inject credentials if missing:
#    - fetch(`/admin/students/${roll}`, { ...  -> insert credentials after '{'
replace_in_file "$ADMIN_HTML" "inject credentials into fetch(\`/admin/students/\${roll}\`, { ... })" \
  "sed -i \"s|fetch(\`/admin/students/\\\${roll}\`, {\\s*|fetch(\`/admin/students/\\\${roll}\`, { credentials: 'include', |g\" \"$ADMIN_HTML\" || true"

# 5) For add-student POST: fetch('/admin/students', { ...  -> add credentials
replace_in_file "$ADMIN_HTML" \"inject credentials into fetch('/admin/students', { ... })\" \
  "sed -i \"s|fetch('/admin/students', {\\s*|fetch('/admin/students', { credentials: 'include', |g\" \"$ADMIN_HTML\" || true"

# 6) Inject credentials into PUT/DELETE/other fetches that start with fetch('/admin/students', {
replace_in_file "$ADMIN_HTML" \"ensure credentials for fetch('/admin/students', { ... })\" \
  "sed -i \"s|fetch('/admin/students', {\\s*|fetch('/admin/students', { credentials: 'include', |g\" \"$ADMIN_HTML\" || true"

# 7) Ensure logout fetch includes credentials
replace_in_file "$ADMIN_HTML" "add credentials to fetch('/admin/logout', { method: 'POST' ... })" \
  "sed -i \"s|fetch('/admin/logout', { method: 'POST'|fetch('/admin/logout', { method: 'POST', credentials: 'include'|g\" \"$ADMIN_HTML\" || true"

# 8) Update login page: add credentials: 'include' to the POST /admin/login call
replace_in_file "$LOGIN_HTML" "add credentials to login POST" \
  "sed -i \"s|fetch('/admin/login', {\\s*method: 'POST',\\s*headers: { 'Content-Type': 'application/json' },|fetch('/admin/login', {\\n            method: 'POST',\\n            headers: { 'Content-Type': 'application/json' },\\n            credentials: 'include',|g\" \"$LOGIN_HTML\" || true"

echo ""
echo "Done. Files updated: $FILES_UPDATED (backups saved with suffix .bak.$TS)"
echo ""
echo "Please check the diffs (or open the files):"
echo "  git diff -- admin/admin.html admin/login.html || true"
echo ""
echo "If everything looks good, redeploy (Vercel) or restart your server."
echo ""
echo "If you want, I can also prepare a git commit command for you to run."
