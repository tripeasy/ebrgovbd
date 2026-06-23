const express = require('express');
const session = require('express-session');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const compression = require('compression');
const helmet = require('helmet');

const app = express();
const PORT = process.env.PORT || 3000;

// Security & Performance
app.use(helmet({
  contentSecurityPolicy: false,
  crossOriginEmbedderPolicy: false
}));
app.use(compression());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(cors());

// Static files
app.use(express.static(path.join(__dirname, '../frontend')));
app.use(express.static(path.join(__dirname, '../admin')));
app.use(express.static(path.join(__dirname, '../public')));

// Session
app.use(session({
    secret: 'edu_board_secret_key_2025_secure',
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false, maxAge: 3600000 }
}));

// ============================================================================
// STUDENT DATA (FULL DATABASE)
// ============================================================================
const studentsData = {
    ssc: {
        "310285": {
            roll_no: "310285",
            reg_no: "2470092",
            name: "GAHANARAF AKTER JUMA",
            fname: "JAHANGIR ALAM",
            mname: "TASLIMA BEGUM",
            board_name: "DHAKA",
            session: "2013-2014",
            year: "2015",
            stud_group: "SCIENCE",
            stud_type: "REGULAR",
            stud_sex: "Female",
            dob: "18-02-1999",
            res_detail: "P",
            gpa: "4.31",
            eiin: "108456",
            inst_name: "Demra Girls High School",
            exam_type: "ssc",
            display_details: "101:85=A+,109:82=A,136:78=A,137:75=A,138:80=A,150:90=A+,154:72=A-,126:70=A-,134:65=B,147:72=A-,156:88=A+"
        },
        "827733": {
            roll_no: "827733",
            reg_no: "258090",
            name: "GAHANARAF AKTER JUMA",
            fname: "JAHANGIR ALAM",
            mname: "TASLIMA BEGUM",
            board_name: "DHAKA",
            session: "2013-2014",
            year: "2015",
            stud_group: "SCIENCE",
            stud_type: "REGULAR",
            stud_sex: "Female",
            dob: "18-02-1999",
            res_detail: "P",
            gpa: "4.00",
            eiin: "654321",
            inst_name: "Lalmohon Islamia Dakhil Madrasha",
            exam_type: "ssc",
            display_details: "101:80=A,109:78=A,136:75=A-,137:72=A-,138:80=A,150:85=A+,154:70=A-,126:68=A-,134:62=B,147:72=A-,156:82=A+"
        },
        "234475": {
            roll_no: "234475",
            reg_no: "336628",
            name: "SHIPAN DAS",
            fname: "TAPAN DAS",
            mname: "SHOPNA RANI DAS",
            board_name: "MYMENSINGH",
            session: "1999-2000",
            year: "2001",
            stud_group: "ARTS",
            stud_type: "REGULAR",
            stud_sex: "Male",
            dob: "01-01-1984",
            res_detail: "P",
            gpa: "4.50",
            eiin: "456789",
            inst_name: "PALASH THANA HIGH SCHOOL",
            exam_type: "ssc",
            display_details: "101:92=A+,102:88=A+,103:82=A,105:85=A+,106:90=A+,107:78=A,150:86=A+,151:84=A,152:80=A,153:82=A,154:88=A+,114:85=A+"
        }
    },
    hsc: {
        "406020": {
            roll_no: "406020",
            reg_no: "9200247",
            name: "GAHANARAF AKTER JUMA",
            fname: "JAHANGIR ALAM",
            mname: "TASLIMA BEGUM",
            board_name: "DHAKA",
            session: "2015-2016",
            year: "2017",
            stud_group: "SCIENCE",
            stud_type: "REGULAR",
            stud_sex: "Female",
            dob: "18-02-1999",
            res_detail: "P",
            gpa: "3.70",
            eiin: "109876",
            inst_name: "Govt Abdul Jabber College",
            exam_type: "hsc",
            display_details: "101:75=A,109:72=A-,136:70=A-,137:68=A-,138:72=A,150:80=A+,154:65=A-,126:62=B,134:58=B,147:65=A-,156:75=A"
        }
    }
};

// Subject names mapping
const subjectNames = {
    '101': 'Bangla',
    '102': 'English',
    '103': 'Mathematics',
    '105': 'Social Science',
    '106': 'Islamic Studies',
    '107': 'Hindu Religion',
    '109': 'Mathematics',
    '114': 'Career Education',
    '126': 'Higher Math',
    '134': 'Agriculture Studies',
    '136': 'Physics',
    '137': 'Chemistry',
    '138': 'Biology',
    '147': 'Physical Education, Health And Sports',
    '150': 'Bangladesh & Global Studies',
    '151': 'History',
    '152': 'Geography',
    '153': 'Civics',
    '154': 'ICT',
    '156': 'Career Education'
};

// ============================================================================
// API ENDPOINTS
// ============================================================================

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Subject list
app.get('/v2/sub', (req, res) => {
    const subjects = Object.entries(subjectNames).map(([code, name]) => ({ 
        SUB_CODE: code, 
        SUB_NAME: name 
    }));
    res.json(subjects);
});

// District list
app.get('/v2/list', (req, res) => {
    const { id, board, exam, year } = req.query;
    if (id === 'dlist') {
        const districts = {
            barisal: [{ name: "BARISAL SADAR", code: "01" }, { name: "BAKERGANJ", code: "02" }],
            dhaka: [{ name: "DHAKA CITY", code: "01" }, { name: "GAZIPUR", code: "02" }, { name: "NARAYANGANJ", code: "03" }],
            chittagong: [{ name: "CHITTAGONG CITY", code: "01" }, { name: "COX'S BAZAR", code: "02" }],
            mymensingh: [{ name: "MYMENSINGH SADAR", code: "01" }, { name: "JAMALPUR", code: "02" }],
            rajshahi: [{ name: "RAJSHAHI CITY", code: "01" }, { name: "BOGRA", code: "02" }],
            sylhet: [{ name: "SYLHET CITY", code: "01" }, { name: "MOULVIBAZAR", code: "02" }],
            comilla: [{ name: "COMILLA SADAR", code: "01" }, { name: "BRAHMANBARIA", code: "02" }],
            jessore: [{ name: "JESSORE SADAR", code: "01" }, { name: "JASHORE", code: "02" }],
            dinajpur: [{ name: "DINAJPUR SADAR", code: "01" }, { name: "RANGPUR", code: "02" }],
            madrasah: [{ name: "MADRASAH BOARD", code: "01" }],
            tec: [{ name: "TECHNICAL BOARD", code: "01" }]
        };
        res.json(districts[board] || []);
    } else if (id === 'clist') {
        const centers = {
            "01": [{ name: "DHAKA COLLEGE", code: "001" }, { name: "NOTRE DAME COLLEGE", code: "002" }, { name: "HOLY CROSS COLLEGE", code: "003" }],
            "02": [{ name: "GAZIPUR COLLEGE", code: "004" }]
        };
        res.json(centers[req.query.dcode] || []);
    } else {
        res.json([]);
    }
});

// Get result
app.post('/v2/getres', (req, res) => {
    const { roll, reg, board, exam, year } = req.body;
    let studentData = null;
    
    // Search in SSC
    if (exam === 'ssc' && studentsData.ssc[roll]) {
        studentData = studentsData.ssc[roll];
    } 
    // Search in HSC
    else if (exam === 'hsc' && studentsData.hsc[roll]) {
        studentData = studentsData.hsc[roll];
    }
    // Search in both if exam not specified
    else {
        if (studentsData.ssc[roll]) {
            studentData = studentsData.ssc[roll];
        } else if (studentsData.hsc[roll]) {
            studentData = studentsData.hsc[roll];
        }
    }
    
    if (studentData) {
        return res.json({ status: 0, res: studentData });
    }
    res.json({ status: 1, msg: 'No result found. Please check your information.' });
});

// ============================================================================
// ADMIN AUTHENTICATION - Using Environment Variables
// ============================================================================
const adminUsers = {
    'admin': process.env.ADMIN_PASSWORD || 'EducationBoard@006',
    'barisalboard': 'board@2025',
    'dhakaboard': 'dhaka@2025'
};

app.post('/admin/login', (req, res) => {
    const { username, password } = req.body;
    if (adminUsers[username] && adminUsers[username] === password) {
        req.session.admin = true;
        req.session.adminUser = username;
        res.json({ success: true, message: 'Login successful' });
    } else {
        res.json({ success: false, message: 'Invalid username or password' });
    }
});

app.get('/admin/check', (req, res) => {
    res.json({ loggedIn: !!req.session.admin });
});

app.post('/admin/logout', (req, res) => {
    req.session.destroy();
    res.json({ success: true });
});

// Get all students
app.get('/admin/students', (req, res) => {
    if (!req.session.admin) return res.status(401).json([]);
    const allStudents = [
        ...Object.values(studentsData.ssc).map(s => ({ ...s, exam_type: 'SSC', id: s.roll_no })),
        ...Object.values(studentsData.hsc).map(s => ({ ...s, exam_type: 'HSC', id: s.roll_no }))
    ];
    res.json(allStudents);
});

// Get single student
app.get('/admin/students/:roll', (req, res) => {
    if (!req.session.admin) return res.status(401).json({ success: false });
    const { roll } = req.params;
    let found = null;
    for (const exam in studentsData) {
        if (studentsData[exam][roll]) {
            found = { ...studentsData[exam][roll], exam_type: exam.toUpperCase(), id: roll };
            break;
        }
    }
    if (found) res.json({ success: true, student: found });
    else res.json({ success: false, message: 'Student not found' });
});

// Update student
app.put('/admin/students/:roll', (req, res) => {
    if (!req.session.admin) return res.status(401).json({ success: false });
    const { roll } = req.params;
    const updatedData = req.body;
    let found = false;
    for (const exam in studentsData) {
        if (studentsData[exam][roll]) {
            studentsData[exam][roll] = { ...studentsData[exam][roll], ...updatedData };
            found = true;
            break;
        }
    }
    if (found) res.json({ success: true, message: 'Student updated successfully' });
    else res.json({ success: false, message: 'Student not found' });
});

// Add student
app.post('/admin/students', (req, res) => {
    if (!req.session.admin) return res.status(401).json({ success: false });
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

// Delete student
app.delete('/admin/students/:id', (req, res) => {
    if (!req.session.admin) return res.status(401).json({ success: false });
    const { id } = req.params;
    let found = false;
    for (const exam in studentsData) {
        if (studentsData[exam][id]) {
            delete studentsData[exam][id];
            found = true;
            break;
        }
    }
    res.json({ success: found });
});

// ============================================================================
// FALLBACK ROUTE
// ============================================================================
app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, '../frontend/home.html'));
});

// ============================================================================
// START SERVER
// ============================================================================
app.listen(PORT, '0.0.0.0', () => {
    console.log('\n========================================');
    console.log('✅ Education Board Result System');
    console.log('========================================');
    console.log('');
    console.log('📌 SSC RESULTS:');
    console.log('   Board: dhaka | Exam: ssc | Year: 2015');
    console.log('   Roll: 310285 | Reg: 2470092');
    console.log('   Roll: 827733 | Reg: 258090');
    console.log('   Board: mymensingh | Exam: ssc | Year: 2001');
    console.log('   Roll: 234475 | Reg: 336628');
    console.log('');
    console.log('📌 HSC RESULT:');
    console.log('   Board: dhaka | Exam: hsc | Year: 2017');
    console.log('   Roll: 406020 | Reg: 9200247');
    console.log('');
    console.log('🌐 Frontend: http://localhost:3000/');
    console.log('🔐 Admin Login: http://localhost:3000/login');
    console.log('👤 Admin Credentials: admin / ' + (process.env.ADMIN_PASSWORD || 'EducationBoard@006'));
    console.log('========================================\n');
});

module.exports = app;
