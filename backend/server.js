const express = require('express');
const session = require('express-session');
const cors = require('cors');
const path = require('path');
const compression = require('compression');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet({ contentSecurityPolicy: false, crossOriginEmbedderPolicy: false }));
app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(cors());
app.use(express.static(path.join(__dirname, '../frontend')));
app.use(express.static(path.join(__dirname, '../admin')));
app.use(express.static(path.join(__dirname, '../public')));

app.use(session({
    secret: 'edu_board_secret_key_2025_secure',
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false, maxAge: 3600000, httpOnly: true }
}));

// ============================================================================
// DATABASE
// ============================================================================
let adminUsers = {
    'admin': {
        password: 'admin123',
        role: 'super_admin',
        name: 'Super Administrator',
        email: 'admin@educationboard.gov.bd',
        locked: false,
        createdBy: 'system',
        createdAt: new Date()
    }
};

let studentsData = {
    ssc: {
        "310285": {
            roll_no: "310285", reg_no: "2470092", name: "GAHANARAF AKTER JUMA",
            fname: "JAHANGIR ALAM", mname: "TASLIMA BEGUM", board_name: "DHAKA",
            session: "2013-2014", year: "2015", stud_group: "SCIENCE",
            stud_type: "REGULAR", stud_sex: "Female", dob: "18-02-1999",
            res_detail: "P", gpa: "4.31", eiin: "108456",
            inst_name: "Demra Girls High School", exam_type: "ssc",
            display_details: "101:85=A+,109:82=A,136:78=A,137:75=A,138:80=A,150:90=A+,154:72=A-,126:70=A-,134:65=B,147:72=A-,156:88=A+",
            addedBy: "admin"
        },
        "827733": {
            roll_no: "827733", reg_no: "258090", name: "GAHANARAF AKTER JUMA",
            fname: "JAHANGIR ALAM", mname: "TASLIMA BEGUM", board_name: "DHAKA",
            session: "2013-2014", year: "2015", stud_group: "SCIENCE",
            stud_type: "REGULAR", stud_sex: "Female", dob: "18-02-1999",
            res_detail: "P", gpa: "4.00", eiin: "654321",
            inst_name: "Lalmohon Islamia Dakhil Madrasha", exam_type: "ssc",
            display_details: "101:80=A,109:78=A,136:75=A-,137:72=A-,138:80=A,150:85=A+,154:70=A-,126:68=A-,134:62=B,147:72=A-,156:82=A+",
            addedBy: "admin"
        },
        "234475": {
            roll_no: "234475", reg_no: "336628", name: "SHIPAN DAS",
            fname: "TAPAN DAS", mname: "SHOPNA RANI DAS", board_name: "MYMENSINGH",
            session: "1999-2000", year: "2001", stud_group: "ARTS",
            stud_type: "REGULAR", stud_sex: "Male", dob: "01-01-1984",
            res_detail: "P", gpa: "4.50", eiin: "456789",
            inst_name: "PALASH THANA HIGH SCHOOL", exam_type: "ssc",
            display_details: "101:92=A+,102:88=A+,103:82=A,105:85=A+,106:90=A+,107:78=A,150:86=A+,151:84=A,152:80=A,153:82=A,154:88=A+,114:85=A+",
            addedBy: "admin"
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
            display_details: "101:75=A,109:72=A-,136:70=A-,137:68=A-,138:72=A,150:80=A+,154:65=A-,126:62=B,134:58=B,147:65=A-,156:75=A",
            addedBy: "admin"
        }
    }
};

const subjectNames = {
    '101': 'Bangla', '102': 'English', '103': 'Mathematics', '105': 'Social Science',
    '106': 'Islamic Studies', '107': 'Hindu Religion', '109': 'Mathematics',
    '114': 'Career Education', '126': 'Higher Math', '134': 'Agriculture Studies',
    '136': 'Physics', '137': 'Chemistry', '138': 'Biology',
    '147': 'Physical Education', '150': 'Bangladesh & Global Studies',
    '151': 'History', '152': 'Geography', '153': 'Civics', '154': 'ICT', '156': 'Career Education'
};

function getStudentsByAdmin(username) {
    const admin = adminUsers[username];
    const all = [
        ...Object.values(studentsData.ssc).map(s => ({ ...s, exam_type: 'SSC', id: s.roll_no })),
        ...Object.values(studentsData.hsc).map(s => ({ ...s, exam_type: 'HSC', id: s.roll_no }))
    ];
    
    if (admin.role === 'super_admin') return all;
    return all.filter(s => s.addedBy === username);
}

// ============================================================================
// ROUTES - PUBLIC
// ============================================================================
app.get('/login', (req, res) => res.sendFile(path.join(__dirname, '../admin/login.html')));
app.get('/admin', (req, res) => {
    if (!req.session.admin) return res.redirect('/login');
    res.sendFile(path.join(__dirname, '../admin/admin.html'));
});
app.get(['/', '/home'], (req, res) => res.sendFile(path.join(__dirname, '../frontend/home.html')));

app.get('/api/health', (req, res) => res.json({ status: 'ok' }));

app.get('/v2/sub', (req, res) => {
    const subjects = Object.entries(subjectNames).map(([code, name]) => ({ SUB_CODE: code, SUB_NAME: name }));
    res.json(subjects);
});

app.get('/v2/list', (req, res) => {
    const { id, board } = req.query;
    if (id === 'dlist') {
        const districts = {
            dhaka: [{ name: "DHAKA CITY", code: "01" }, { name: "GAZIPUR", code: "02" }],
            mymensingh: [{ name: "MYMENSINGH SADAR", code: "01" }],
            barisal: [{ name: "BARISAL SADAR", code: "01" }],
            chittagong: [{ name: "CHITTAGONG CITY", code: "01" }],
            rajshahi: [{ name: "RAJSHAHI CITY", code: "01" }],
            sylhet: [{ name: "SYLHET CITY", code: "01" }],
            comilla: [{ name: "COMILLA SADAR", code: "01" }],
            jessore: [{ name: "JESSORE SADAR", code: "01" }],
            dinajpur: [{ name: "DINAJPUR SADAR", code: "01" }]
        };
        res.json(districts[board] || []);
    } else res.json([]);
});

app.post('/v2/getres', (req, res) => {
    const { roll, exam } = req.body;
    let data = null;
    
    if (exam === 'ssc' && studentsData.ssc[roll]) data = studentsData.ssc[roll];
    else if (exam === 'hsc' && studentsData.hsc[roll]) data = studentsData.hsc[roll];
    else {
        if (studentsData.ssc[roll]) data = studentsData.ssc[roll];
        else if (studentsData.hsc[roll]) data = studentsData.hsc[roll];
    }
    
    if (data) res.json({ status: 0, res: data });
    else res.json({ status: 1, msg: 'No result found' });
});

// ============================================================================
// AUTHENTICATION
// ============================================================================
app.post('/admin/login', (req, res) => {
    const { username, password } = req.body;
    const admin = adminUsers[username];
    
    if (!admin) return res.json({ success: false, message: 'Invalid credentials' });
    if (admin.locked) return res.json({ success: false, message: 'Account locked. Contact super admin.' });
    if (admin.password !== password) return res.json({ success: false, message: 'Invalid credentials' });
    
    req.session.admin = true;
    req.session.adminUser = username;
    req.session.adminRole = admin.role;
    res.json({ success: true });
});

app.get('/admin/check', (req, res) => {
    res.json({ 
        loggedIn: !!req.session.admin,
        username: req.session.adminUser,
        role: req.session.adminRole
    });
});

app.post('/admin/logout', (req, res) => {
    req.session.destroy();
    res.json({ success: true });
});

// ============================================================================
// ADMIN MANAGEMENT
// ============================================================================
app.get('/admin/admins', (req, res) => {
    if (!req.session.admin || req.session.adminRole !== 'super_admin') {
        return res.status(401).json({ success: false });
    }
    const admins = Object.entries(adminUsers).map(([username, data]) => ({
        username, name: data.name, role: data.role, email: data.email, locked: data.locked, createdAt: data.createdAt
    }));
    res.json(admins);
});

app.post('/admin/add-subadmin', (req, res) => {
    if (!req.session.admin || req.session.adminRole !== 'super_admin') {
        return res.status(401).json({ success: false });
    }
    
    const { username, password, name, email, allowEdit } = req.body;
    
    if (!username || !password || !name || !email) {
        return res.json({ success: false, message: 'All fields required' });
    }
    if (adminUsers[username]) {
        return res.json({ success: false, message: 'Username exists' });
    }
    if (password.length < 6) {
        return res.json({ success: false, message: 'Password must be at least 6 characters' });
    }
    
    adminUsers[username] = {
        password, role: 'sub_admin', name, email, locked: false,
        createdBy: req.session.adminUser, createdAt: new Date(), allowEdit
    };
    
    res.json({ success: true, message: 'Sub-admin added successfully' });
});

app.post('/admin/lock-subadmin', (req, res) => {
    if (!req.session.admin || req.session.adminRole !== 'super_admin') {
        return res.status(401).json({ success: false });
    }
    
    const { username, locked } = req.body;
    if (username === 'admin') return res.json({ success: false, message: 'Cannot lock super admin' });
    if (!adminUsers[username]) return res.json({ success: false, message: 'Admin not found' });
    
    adminUsers[username].locked = locked;
    res.json({ success: true });
});

app.delete('/admin/subadmin/:username', (req, res) => {
    if (!req.session.admin || req.session.adminRole !== 'super_admin') {
        return res.status(401).json({ success: false });
    }
    
    const { username } = req.params;
    if (username === 'admin') return res.json({ success: false, message: 'Cannot delete super admin' });
    if (!adminUsers[username]) return res.json({ success: false, message: 'Admin not found' });
    
    delete adminUsers[username];
    res.json({ success: true });
});

// ============================================================================
// PASSWORD CHANGE - For any logged in admin
// ============================================================================
app.post('/admin/change-password', (req, res) => {
    if (!req.session.admin) return res.status(401).json({ success: false, message: 'Not logged in' });
    
    const { oldPassword, newPassword } = req.body;
    const username = req.session.adminUser;
    
    if (!adminUsers[username]) {
        return res.json({ success: false, message: 'User not found' });
    }
    
    if (adminUsers[username].password !== oldPassword) {
        return res.json({ success: false, message: 'Current password is incorrect' });
    }
    
    if (newPassword.length < 6) {
        return res.json({ success: false, message: 'New password must be at least 6 characters' });
    }
    
    adminUsers[username].password = newPassword;
    res.json({ success: true, message: 'Password changed successfully' });
});

// ============================================================================
// STUDENT MANAGEMENT
// ============================================================================
app.get('/admin/students', (req, res) => {
    if (!req.session.admin) return res.status(401).json([]);
    res.json(getStudentsByAdmin(req.session.adminUser));
});

app.get('/admin/students/:roll', (req, res) => {
    if (!req.session.admin) return res.status(401).json({ success: false });
    
    const { roll } = req.params;
    let found = null;
    for (const exam in studentsData) {
        if (studentsData[exam][roll]) {
            found = { ...studentsData[exam][roll], exam_type: exam.toUpperCase() };
            break;
        }
    }
    
    if (found) {
        const admin = adminUsers[req.session.adminUser];
        if (admin.role === 'sub_admin' && found.addedBy !== req.session.adminUser) {
            return res.json({ success: false, message: 'No access to this student' });
        }
        res.json({ success: true, student: found });
    } else {
        res.json({ success: false, message: 'Student not found' });
    }
});

app.put('/admin/students/:roll', (req, res) => {
    if (!req.session.admin) return res.status(401).json({ success: false });
    
    const admin = adminUsers[req.session.adminUser];
    if (admin.role === 'sub_admin' && !admin.allowEdit) {
        return res.json({ success: false, message: 'Sub-admin does not have edit permissions' });
    }
    
    const { roll } = req.params;
    for (const exam in studentsData) {
        if (studentsData[exam][roll]) {
            studentsData[exam][roll] = { ...studentsData[exam][roll], ...req.body };
            return res.json({ success: true });
        }
    }
    res.json({ success: false, message: 'Student not found' });
});

app.post('/admin/students', (req, res) => {
    if (!req.session.admin) return res.status(401).json({ success: false });
    
    const student = req.body.student;
    if (student && student.roll_no) {
        const exam = student.exam_type || 'ssc';
        if (!studentsData[exam]) studentsData[exam] = {};
        student.addedBy = req.session.adminUser;
        studentsData[exam][student.roll_no] = student;
        res.json({ success: true });
    } else {
        res.json({ success: false, message: 'Invalid student data' });
    }
});

app.delete('/admin/students/:id', (req, res) => {
    if (!req.session.admin) return res.status(401).json({ success: false });
    
    const admin = adminUsers[req.session.adminUser];
    if (admin.role !== 'super_admin') {
        return res.json({ success: false, message: 'Only super admin can delete' });
    }
    
    const { id } = req.params;
    for (const exam in studentsData) {
        if (studentsData[exam][id]) {
            delete studentsData[exam][id];
            return res.json({ success: true });
        }
    }
    res.json({ success: false, message: 'Student not found' });
});

app.use((req, res) => {
    res.status(404).sendFile(path.join(__dirname, '../frontend/home.html'));
});

app.listen(PORT, '0.0.0.0', () => {
    console.log('\n════════════════════════════════════════');
    console.log('✅ Education Board System');
    console.log('════════════════════════════════════════');
    console.log('🔐 Admin Login: admin / admin123');
    console.log('   (Change password after first login)');
    console.log('════════════════════════════════════════\n');
});

module.exports = app;
