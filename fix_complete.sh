#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${BLUE}🔧 COMPLETE SYSTEM FIX${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

# ============================================================================
# 1. FIX PACKAGE.JSON
# ============================================================================
echo -e "${GREEN}1️⃣ Fixing package.json...${NC}"
cat > package.json << 'JSON'
{
  "name": "www-educationboardresults-gov-bd",
  "version": "2.0.0",
  "description": "Education Board Result System",
  "main": "backend/server.js",
  "scripts": {
    "start": "node backend/server.js",
    "vercel-build": "npm install"
  },
  "dependencies": {
    "express": "^4.18.2",
    "express-session": "^1.17.3",
    "cors": "^2.8.5",
    "body-parser": "^1.20.2",
    "compression": "^1.7.4",
    "helmet": "^7.1.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
JSON
echo -e "${GREEN}✅ package.json fixed${NC}"

# ============================================================================
# 2. FIX VERCEL.JSON
# ============================================================================
echo -e "${GREEN}2️⃣ Fixing vercel.json...${NC}"
cat > vercel.json << 'JSON'
{
    "version": 2,
    "builds": [
        {
            "src": "backend/server.js",
            "use": "@vercel/node"
        }
    ],
    "routes": [
        {
            "src": "/api/(.*)",
            "dest": "/backend/server.js"
        },
        {
            "src": "/v2/(.*)",
            "dest": "/backend/server.js"
        },
        {
            "src": "/admin/(.*)",
            "dest": "/backend/server.js"
        },
        {
            "src": "/login",
            "dest": "/backend/server.js"
        },
        {
            "src": "/admin",
            "dest": "/backend/server.js"
        },
        {
            "src": "/(.*)",
            "dest": "/backend/server.js"
        }
    ],
    "env": {
        "NODE_ENV": "production",
        "PORT": "3000"
    }
}
JSON
echo -e "${GREEN}✅ vercel.json fixed${NC}"

# ============================================================================
# 3. COMPLETE BACKEND SERVER FIX
# ============================================================================
echo -e "${GREEN}3️⃣ Fixing backend/server.js...${NC}"
cat > backend/server.js << 'JS'
const express = require('express');
const session = require('express-session');
const cors = require('cors');
const path = require('path');
const compression = require('compression');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;

// ============================================================================
// MIDDLEWARE
// ============================================================================
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false
}));
app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(cors());

// Static files - MUST be before routes
app.use(express.static(path.join(__dirname, '../frontend')));
app.use(express.static(path.join(__dirname, '../admin')));
app.use(express.static(path.join(__dirname, '../public')));

// Session
app.use(session({
    secret: 'edu_board_secret_key_2025_secure',
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false, maxAge: 3600000, httpOnly: true }
}));

// ============================================================================
// STUDENT DATA
// ============================================================================
const studentsData = {
    ssc: {
        "310285": {
            roll_no: "310285", reg_no: "2470092", name: "GAHANARAF AKTER JUMA",
            fname: "JAHANGIR ALAM", mname: "TASLIMA BEGUM", board_name: "DHAKA",
            session: "2013-2014", year: "2015", stud_group: "SCIENCE",
            stud_type: "REGULAR", stud_sex: "Female", dob: "18-02-1999",
            res_detail: "P", gpa: "4.31", eiin: "108456",
            inst_name: "Demra Girls High School", exam_type: "ssc",
            display_details: "101:85=A+,109:82=A,136:78=A,137:75=A,138:80=A,150:90=A+,154:72=A-,126:70=A-,134:65=B,147:72=A-,156:88=A+"
        },
        "827733": {
            roll_no: "827733", reg_no: "258090", name: "GAHANARAF AKTER JUMA",
            fname: "JAHANGIR ALAM", mname: "TASLIMA BEGUM", board_name: "DHAKA",
            session: "2013-2014", year: "2015", stud_group: "SCIENCE",
            stud_type: "REGULAR", stud_sex: "Female", dob: "18-02-1999",
            res_detail: "P", gpa: "4.00", eiin: "654321",
            inst_name: "Lalmohon Islamia Dakhil Madrasha", exam_type: "ssc",
            display_details: "101:80=A,109:78=A,136:75=A-,137:72=A-,138:80=A,150:85=A+,154:70=A-,126:68=A-,134:62=B,147:72=A-,156:82=A+"
        },
        "234475": {
            roll_no: "234475", reg_no: "336628", name: "SHIPAN DAS",
            fname: "TAPAN DAS", mname: "SHOPNA RANI DAS", board_name: "MYMENSINGH",
            session: "1999-2000", year: "2001", stud_group: "ARTS",
            stud_type: "REGULAR", stud_sex: "Male", dob: "01-01-1984",
            res_detail: "P", gpa: "4.50", eiin: "456789",
            inst_name: "PALASH THANA HIGH SCHOOL", exam_type: "ssc",
            display_details: "101:92=A+,102:88=A+,103:82=A,105:85=A+,106:90=A+,107:78=A,150:86=A+,151:84=A,152:80=A,153:82=A,154:88=A+,114:85=A+"
        }
    },
    hsc: {
        "406020": {
            roll_no: "406020", reg_no: "9200247", name: "GAHANARAF AKTER JUMA",
            fname: "JAHANGIR ALAM", mname: "TASLIMA BEGUM", board_name: "DHAKA",
            session: "2015-2016", year: "2017", stud_group: "SCIENCE",
            stud_type: "REGULAR", stud_sex: "Female", dob: "18-02-1999",
            res_detail: "P", gpa: "3.70", eiin: "109876",
            inst_name: "Govt Abdul Jabber College", exam_type: "hsc",
            display_details: "101:75=A,109:72=A-,136:70=A-,137:68=A-,138:72=A,150:80=A+,154:65=A-,126:62=B,134:58=B,147:65=A-,156:75=A"
        }
    }
};

const subjectNames = {
    '101': 'Bangla', '102': 'English', '103': 'Mathematics', '105': 'Social Science',
    '106': 'Islamic Studies', '107': 'Hindu Religion', '109': 'Mathematics',
    '114': 'Career Education', '126': 'Higher Math', '134': 'Agriculture Studies',
    '136': 'Physics', '137': 'Chemistry', '138': 'Biology',
    '147': 'Physical Education, Health And Sports', '150': 'Bangladesh & Global Studies',
    '151': 'History', '152': 'Geography', '153': 'Civics', '154': 'ICT', '156': 'Career Education'
};

// ============================================================================
// ADMIN CREDENTIALS
// ============================================================================
const adminUsers = {
    'admin': 'admin123',
    'barisalboard': 'board@2025',
    'dhakaboard': 'dhaka@2025'
};

// ============================================================================
// PAGE ROUTES (SERVE HTML)
// ============================================================================
app.get('/login', (req, res) => {
    res.sendFile(path.join(__dirname, '../admin/login.html'));
});

app.get('/admin', (req, res) => {
    if (!req.session.admin) {
        return res.redirect('/login');
    }
    res.sendFile(path.join(__dirname, '../admin/admin.html'));
});

app.get('/home', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/home.html'));
});

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/home.html'));
});

// ============================================================================
// API ENDPOINTS - PUBLIC
// ============================================================================

app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.get('/v2/sub', (req, res) => {
    const subjects = Object.entries(subjectNames).map(([code, name]) => ({ SUB_CODE: code, SUB_NAME: name }));
    res.json(subjects);
});

app.get('/v2/list', (req, res) => {
    const { id, board } = req.query;
    if (id === 'dlist') {
        const districts = {
            barisal: [{ name: "BARISAL SADAR", code: "01" }],
            dhaka: [{ name: "DHAKA CITY", code: "01" }, { name: "GAZIPUR", code: "02" }],
            chittagong: [{ name: "CHITTAGONG CITY", code: "01" }],
            mymensingh: [{ name: "MYMENSINGH SADAR", code: "01" }],
            rajshahi: [{ name: "RAJSHAHI CITY", code: "01" }],
            sylhet: [{ name: "SYLHET CITY", code: "01" }],
            comilla: [{ name: "COMILLA SADAR", code: "01" }],
            jessore: [{ name: "JESSORE SADAR", code: "01" }],
            dinajpur: [{ name: "DINAJPUR SADAR", code: "01" }],
            madrasah: [{ name: "MADRASAH BOARD", code: "01" }],
            tec: [{ name: "TECHNICAL BOARD", code: "01" }]
        };
        res.json(districts[board] || []);
    } else {
        res.json([]);
    }
});

app.post('/v2/getres', (req, res) => {
    const { roll, reg, board, exam, year } = req.body;
    let studentData = null;
    
    if (exam === 'ssc' && studentsData.ssc[roll]) {
        studentData = studentsData.ssc[roll];
    } else if (exam === 'hsc' && studentsData.hsc[roll]) {
        studentData = studentsData.hsc[roll];
    } else {
        if (studentsData.ssc[roll]) studentData = studentsData.ssc[roll];
        else if (studentsData.hsc[roll]) studentData = studentsData.hsc[roll];
    }
    
    if (studentData) {
        return res.json({ status: 0, res: studentData });
    }
    res.json({ status: 1, msg: 'No result found. Please check your information.' });
});

// ============================================================================
// ADMIN AUTHENTICATION
// ============================================================================

app.post('/admin/login', (req, res) => {
    const { username, password } = req.body;
    
    if (!username || !password) {
        return res.json({ success: false, message: 'Username and password required' });
    }
    
    if (adminUsers[username] && adminUsers[username] === password) {
        req.session.admin = true;
        req.session.adminUser = username;
        return res.json({ success: true, message: 'Login successful' });
    }
    
    res.json({ success: false, message: 'Invalid username or password' });
});

app.get('/admin/check', (req, res) => {
    res.json({ 
        loggedIn: !!req.session.admin,
        username: req.session.adminUser || null
    });
});

app.post('/admin/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) return res.json({ success: false, message: 'Logout failed' });
        res.json({ success: true, message: 'Logged out successfully' });
    });
});

// ============================================================================
// STUDENT MANAGEMENT (Protected Routes)
// ============================================================================

app.get('/admin/students', (req, res) => {
    if (!req.session.admin) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    const allStudents = [
        ...Object.values(studentsData.ssc).map(s => ({ ...s, exam_type: 'SSC', id: s.roll_no })),
        ...Object.values(studentsData.hsc).map(s => ({ ...s, exam_type: 'HSC', id: s.roll_no }))
    ];
    res.json(allStudents);
});

app.get('/admin/students/:roll', (req, res) => {
    if (!req.session.admin) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    const { roll } = req.params;
    let found = null;
    for (const exam in studentsData) {
        if (studentsData[exam][roll]) {
            found = { ...studentsData[exam][roll], exam_type: exam.toUpperCase(), id: roll };
            break;
        }
    }
    if (found) {
        res.json({ success: true, student: found });
    } else {
        res.json({ success: false, message: 'Student not found' });
    }
});

app.put('/admin/students/:roll', (req, res) => {
    if (!req.session.admin) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    const { roll } = req.params;
    const updatedData = req.body;
    
    for (const exam in studentsData) {
        if (studentsData[exam][roll]) {
            studentsData[exam][roll] = { ...studentsData[exam][roll], ...updatedData };
            return res.json({ success: true, message: 'Student updated successfully' });
        }
    }
    res.json({ success: false, message: 'Student not found' });
});

app.post('/admin/students', (req, res) => {
    if (!req.session.admin) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    const student = req.body.student;
    if (student && student.roll_no) {
        const examType = student.exam_type || 'ssc';
        if (!studentsData[examType]) studentsData[examType] = {};
        studentsData[examType][student.roll_no] = student;
        res.json({ success: true, message: 'Student added successfully' });
    } else {
        res.json({ success: false, message: 'Invalid student data' });
    }
});

app.delete('/admin/students/:id', (req, res) => {
    if (!req.session.admin) {
        return res.status(401).json({ success: false, message: 'Not authenticated' });
    }
    const { id } = req.params;
    for (const exam in studentsData) {
        if (studentsData[exam][id]) {
            delete studentsData[exam][id];
            return res.json({ success: true, message: 'Student deleted' });
        }
    }
    res.json({ success: false, message: 'Student not found' });
});

// ============================================================================
// 404 HANDLER
// ============================================================================
app.use((req, res) => {
    res.status(404).sendFile(path.join(__dirname, '../frontend/home.html'));
});

// ============================================================================
// START SERVER
// ============================================================================
app.listen(PORT, '0.0.0.0', () => {
    console.log('\n════════════════════════════════════════');
    console.log('✅ Education Board Result System');
    console.log('════════════════════════════════════════');
    console.log('');
    console.log('🌐 Frontend: http://localhost:3000');
    console.log('🔐 Login: http://localhost:3000/login');
    console.log('👤 Credentials: admin / admin123');
    console.log('');
    console.log('📌 Test Rolls:');
    console.log('   SSC: 310285, 827733, 234475');
    console.log('   HSC: 406020');
    console.log('════════════════════════════════════════\n');
});

module.exports = app;
JS
echo -e "${GREEN}✅ backend/server.js fixed${NC}"

# ============================================================================
# 4. FIX LOGIN.HTML
# ============================================================================
echo -e "${GREEN}4️⃣ Fixing admin/login.html...${NC}"
cat > admin/login.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admin Login - Education Board</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: Arial, sans-serif; background: linear-gradient(135deg, #006a4e, #00843d); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .login-container { background: white; border-radius: 20px; box-shadow: 0 10px 50px rgba(0,0,0,0.3); width: 100%; max-width: 450px; overflow: hidden; }
        .login-header { background: linear-gradient(135deg, #006a4e, #00843d); color: white; padding: 40px 30px; text-align: center; }
        .login-header h2 { font-size: 24px; margin-bottom: 10px; }
        .login-header p { opacity: 0.9; font-size: 14px; }
        .login-body { padding: 40px 30px; }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: 600; color: #333; font-size: 14px; }
        input { width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 8px; font-size: 15px; }
        input:focus { outline: none; border-color: #006a4e; box-shadow: 0 0 0 3px rgba(0,106,78,0.1); }
        .btn-login { width: 100%; padding: 14px; background: linear-gradient(135deg, #006a4e, #00843d); color: white; border: none; border-radius: 8px; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.3s; }
        .btn-login:hover { transform: translateY(-2px); box-shadow: 0 5px 20px rgba(0,106,78,0.3); }
        .btn-login:disabled { opacity: 0.6; cursor: not-allowed; }
        .error-msg { background: #f8d7da; color: #721c24; padding: 12px 15px; border-radius: 8px; margin-bottom: 20px; display: none; border: 1px solid #f5c6cb; }
        .success-msg { background: #d4edda; color: #155724; padding: 12px 15px; border-radius: 8px; margin-bottom: 20px; display: none; border: 1px solid #c3e6cb; }
        .login-footer { background: #f8f9fa; padding: 20px; text-align: center; font-size: 12px; color: #666; border-top: 1px solid #eee; }
        .loading { display: none; }
        @media (max-width: 480px) { .login-container { margin: 20px; } .login-header { padding: 30px 20px; } .login-body { padding: 30px 20px; } }
    </style>
</head>
<body>
<div class="login-container">
    <div class="login-header">
        <h2>🎓 Education Board</h2>
        <p>Admin Management System</p>
    </div>
    <div class="login-body">
        <div id="errorMsg" class="error-msg"></div>
        <div id="successMsg" class="success-msg"></div>
        
        <form id="loginForm" onsubmit="handleLogin(event)">
            <div class="form-group">
                <label for="username">Username</label>
                <input type="text" id="username" name="username" required autofocus autocomplete="off" placeholder="Enter username">
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required placeholder="Enter password">
            </div>
            
            <button type="submit" class="btn-login" id="loginBtn">
                <span class="login-text">Login to Dashboard</span>
                <span class="loading" id="loader">Logging in...</span>
            </button>
        </form>
    </div>
    
    <div class="login-footer">
        <p><strong>Demo Account:</strong></p>
        <p>Username: <strong>admin</strong></p>
        <p>Password: <strong>admin123</strong></p>
        <hr style="margin: 10px 0; border: none; border-top: 1px solid #ddd;">
        <p>© Bangladesh Education Board | All rights reserved</p>
    </div>
</div>

<script>
async function handleLogin(event) {
    event.preventDefault();
    
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    const errorDiv = document.getElementById('errorMsg');
    const successDiv = document.getElementById('successMsg');
    const loginBtn = document.getElementById('loginBtn');
    const loginText = document.querySelector('.login-text');
    const loader = document.getElementById('loader');
    
    // Reset messages
    errorDiv.style.display = 'none';
    successDiv.style.display = 'none';
    
    // Disable button
    loginBtn.disabled = true;
    loginText.style.display = 'none';
    loader.style.display = 'inline';
    
    try {
        console.log('Attempting login with:', { username });
        
        const response = await fetch('/admin/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            credentials: 'include',
            body: JSON.stringify({ username, password })
        });
        
        console.log('Response status:', response.status);
        const data = await response.json();
        console.log('Response data:', data);
        
        if (data.success) {
            successDiv.innerHTML = '✅ Login successful! Redirecting...';
            successDiv.style.display = 'block';
            setTimeout(() => {
                window.location.href = '/admin';
            }, 1500);
        } else {
            errorDiv.innerHTML = `❌ ${data.message || 'Login failed. Please try again.'}`;
            errorDiv.style.display = 'block';
            loginBtn.disabled = false;
            loginText.style.display = 'inline';
            loader.style.display = 'none';
        }
    } catch (error) {
        console.error('Login error:', error);
        errorDiv.innerHTML = `❌ Connection error: ${error.message}`;
        errorDiv.style.display = 'block';
        loginBtn.disabled = false;
        loginText.style.display = 'inline';
        loader.style.display = 'none';
    }
}

// Focus username on load
window.addEventListener('load', () => {
    document.getElementById('username').focus();
});
</script>
</body>
</html>
HTML
echo -e "${GREEN}✅ login.html fixed${NC}"

# ============================================================================
# 5. NPM INSTALL
# ============================================================================
echo -e "${GREEN}5️⃣ Installing npm dependencies...${NC}"
npm install
echo -e "${GREEN}✅ npm install complete${NC}"

# ============================================================================
# 6. GIT COMMIT AND PUSH
# ============================================================================
echo -e "${GREEN}6️⃣ Committing and pushing to GitHub...${NC}"
git add .
git commit -m "Fix: Complete system fix - login, backend, frontend configuration"
git push origin main
echo -e "${GREEN}✅ Pushed to GitHub${NC}"

# ============================================================================
# 7. VERCEL DEPLOY
# ============================================================================
echo -e "${GREEN}7️⃣ Deploying to Vercel...${NC}"
npx vercel --prod --yes
echo -e "${GREEN}✅ Deployed to Vercel${NC}"

# ============================================================================
# FINAL SUMMARY
# ============================================================================
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ ALL FIXES COMPLETE!${NC}"
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}🌐 Live URLs:${NC}"
echo "  📚 Main: https://www-educationboardresults-gov-bd.vercel.app"
echo "  🔐 Login: https://www-educationboardresults-gov-bd.vercel.app/login"
echo "  👤 Admin: https://www-educationboardresults-gov-bd.vercel.app/admin"
echo ""
echo -e "${YELLOW}🔑 Credentials:${NC}"
echo "  Username: admin"
echo "  Password: admin123"
echo ""
echo -e "${YELLOW}📌 Test Rolls:${NC}"
echo "  SSC: 310285, 827733, 234475"
echo "  HSC: 406020"
echo ""
echo -e "${BLUE}════════════════════════════════════════${NC}"
