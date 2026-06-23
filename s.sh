#!/bin/bash

echo "🔧 Starting Complete Backend Rebuild..."
echo "════════════════════════════════════════"

cd ~/www-educationboardresults-gov-bd || exit

# Backup old file
cp backend/server.js backend/server.js.backup 2>/dev/null

# Create complete backend/server.js
cat > backend/server.js << 'EOF'
const express = require('express');
const session = require('express-session');
const helmet = require('helmet');
const app = express();

// ════════════════════════════════════════
// 🔒 SECURITY MIDDLEWARE
// ════════════════════════════════════════
app.use(helmet());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ════════════════════════════════════════
// 🌐 CORS CONFIGURATION
// ════════════════════════════════════════
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Credentials', 'true');
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

// ════════════════════════════════════════
// 📋 SESSION CONFIGURATION
// ════════════════════════════════════════
app.use(session({
  secret: 'education-board-secret-key-2026',
  resave: false,
  saveUninitialized: true,
  cookie: { 
    secure: false, 
    httpOnly: true,
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));

// ════════════════════════════════════════
// 👥 ADMIN USERS DATABASE
// ════════════════════════════════════════
const adminUsers = [
  { 
    id: 1, 
    username: 'admin', 
    password: 'admin123', 
    role: 'super-admin', 
    locked: false,
    createdAt: new Date()
  }
];

// ════════════════════════════════════════
// 📚 STUDENT DATA STRUCTURE
// ════════════════════════════════════════
const students = [
  {
    id: 1,
    roll: '001',
    name: 'Student One',
    ssc: {
      bangla: 85,
      english: 78,
      math: 92,
      science: 88,
      social: 80,
      total: 423,
      gpa: 5.0
    },
    hsc: {
      bangla: 82,
      english: 80,
      math: 95,
      physics: 90,
      chemistry: 87,
      total: 434,
      gpa: 5.0
    },
    addedBy: 'admin',
    createdAt: new Date()
  }
];

// ════════════════════════════════════════
// 🔐 ROLE-BASED ACCESS CONTROL MIDDLEWARE
// ════════════════════════════════════════
const requireAuth = (req, res, next) => {
  if (!req.session.admin) {
    return res.status(401).json({ success: false, message: 'Not authenticated' });
  }
  next();
};

const requireSuperAdmin = (req, res, next) => {
  if (!req.session.admin || req.session.admin.role !== 'super-admin') {
    return res.status(403).json({ success: false, message: 'Super admin access required' });
  }
  next();
};

const requireAdmin = (req, res, next) => {
  if (!req.session.admin || (req.session.admin.role !== 'super-admin' && req.session.admin.role !== 'sub-admin')) {
    return res.status(403).json({ success: false, message: 'Admin access required' });
  }
  next();
};

// ════════════════════════════════════════
// 🔑 AUTHENTICATION ENDPOINTS
// ════════════════════════════════════════

// Login endpoint
app.post('/api/login', (req, res) => {
  try {
    const { username, password } = req.body;
    
    if (!username || !password) {
      return res.json({ success: false, message: 'Username and password required' });
    }
    
    const admin = adminUsers.find(u => u.username === username && u.password === password);
    
    if (!admin) {
      return res.json({ success: false, message: 'Invalid credentials' });
    }
    
    if (admin.locked) {
      return res.json({ success: false, message: 'Account is locked' });
    }
    
    req.session.admin = {
      id: admin.id,
      username: admin.username,
      role: admin.role
    };
    
    res.json({ 
      success: true, 
      role: admin.role,
      username: admin.username,
      message: 'Login successful'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Auth check endpoint
app.get('/api/auth-check', (req, res) => {
  if (req.session.admin) {
    res.json({ 
      authenticated: true, 
      role: req.session.admin.role,
      username: req.session.admin.username
    });
  } else {
    res.json({ authenticated: false });
  }
});

// Logout endpoint
app.post('/api/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.json({ success: false, message: 'Logout failed' });
    }
    res.json({ success: true, message: 'Logged out successfully' });
  });
});

// ════════════════════════════════════════
// 👨‍💼 ADMIN MANAGEMENT ENDPOINTS
// ════════════════════════════════════════

// Get all admins (Super Admin only)
app.get('/api/admins', requireSuperAdmin, (req, res) => {
  try {
    const adminList = adminUsers.map(({ password, ...admin }) => admin);
    res.json({ success: true, admins: adminList });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Create sub-admin (Super Admin only)
app.post('/api/create-subadmin', requireSuperAdmin, (req, res) => {
  try {
    const { username, password } = req.body;
    
    if (!username || !password) {
      return res.json({ success: false, message: 'Username and password required' });
    }
    
    if (adminUsers.find(a => a.username === username)) {
      return res.json({ success: false, message: 'Username already exists' });
    }
    
    const newAdmin = {
      id: Math.max(...adminUsers.map(a => a.id), 0) + 1,
      username,
      password,
      role: 'sub-admin',
      locked: false,
      addedBy: req.session.admin.username,
      createdAt: new Date()
    };
    
    adminUsers.push(newAdmin);
    
    const { password: _, ...adminData } = newAdmin;
    res.json({ success: true, message: 'Sub-admin created', admin: adminData });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Delete admin (Super Admin only)
app.delete('/api/delete-admin/:id', requireSuperAdmin, (req, res) => {
  try {
    const adminId = parseInt(req.params.id);
    
    if (adminId === 1) {
      return res.json({ success: false, message: 'Cannot delete super admin' });
    }
    
    const index = adminUsers.findIndex(a => a.id === adminId);
    if (index > -1) {
      adminUsers.splice(index, 1);
      res.json({ success: true, message: 'Admin deleted' });
    } else {
      res.json({ success: false, message: 'Admin not found' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Lock/Unlock account (Super Admin only)
app.post('/api/lock-account/:id', requireSuperAdmin, (req, res) => {
  try {
    const adminId = parseInt(req.params.id);
    const admin = adminUsers.find(a => a.id === adminId);
    
    if (!admin) {
      return res.json({ success: false, message: 'Admin not found' });
    }
    
    admin.locked = !admin.locked;
    res.json({ 
      success: true, 
      message: admin.locked ? 'Account locked' : 'Account unlocked',
      locked: admin.locked 
    });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Change password
app.post('/api/change-password', requireAuth, (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    
    if (!currentPassword || !newPassword) {
      return res.json({ success: false, message: 'Current and new password required' });
    }
    
    const admin = adminUsers.find(a => a.id === req.session.admin.id);
    
    if (!admin || admin.password !== currentPassword) {
      return res.json({ success: false, message: 'Current password incorrect' });
    }
    
    admin.password = newPassword;
    res.json({ success: true, message: 'Password changed successfully' });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ════════════════════════════════════════
// 📊 STUDENT DATA ENDPOINTS
// ════════════════════════════════════════

// Get all students (Role-based filtering)
app.get('/api/students', requireAuth, (req, res) => {
  try {
    const admin = req.session.admin;
    let filteredStudents = students;
    
    // Role-based data retrieval
    if (admin.role === 'sub-admin') {
      filteredStudents = students.filter(s => s.addedBy === admin.username);
    }
    
    res.json({ success: true, students: filteredStudents });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Get student by ID
app.get('/api/students/:id', requireAuth, (req, res) => {
  try {
    const student = students.find(s => s.id === parseInt(req.params.id));
    
    if (!student) {
      return res.json({ success: false, message: 'Student not found' });
    }
    
    // Edit permission control - only super admin or creator can view
    if (req.session.admin.role === 'sub-admin' && student.addedBy !== req.session.admin.username) {
      return res.status(403).json({ success: false, message: 'Access denied' });
    }
    
    res.json({ success: true, student });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Add new student (Admin only)
app.post('/api/students', requireAdmin, (req, res) => {
  try {
    const { roll, name, ssc, hsc } = req.body;
    
    if (!roll || !name) {
      return res.json({ success: false, message: 'Roll and name required' });
    }
    
    const newStudent = {
      id: Math.max(...students.map(s => s.id), 0) + 1,
      roll,
      name,
      ssc: ssc || { bangla: 0, english: 0, math: 0, science: 0, social: 0, total: 0, gpa: 0 },
      hsc: hsc || { bangla: 0, english: 0, math: 0, physics: 0, chemistry: 0, total: 0, gpa: 0 },
      addedBy: req.session.admin.username,
      createdAt: new Date()
    };
    
    students.push(newStudent);
    res.json({ success: true, message: 'Student added', student: newStudent });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Update student (Edit permission control)
app.put('/api/students/:id', requireAdmin, (req, res) => {
  try {
    const student = students.find(s => s.id === parseInt(req.params.id));
    
    if (!student) {
      return res.json({ success: false, message: 'Student not found' });
    }
    
    // Edit permission control - only super admin or creator can edit
    if (req.session.admin.role === 'sub-admin' && student.addedBy !== req.session.admin.username) {
      return res.status(403).json({ success: false, message: 'Permission denied' });
    }
    
    const { roll, name, ssc, hsc } = req.body;
    
    if (roll) student.roll = roll;
    if (name) student.name = name;
    if (ssc) student.ssc = { ...student.ssc, ...ssc };
    if (hsc) student.hsc = { ...student.hsc, ...hsc };
    
    res.json({ success: true, message: 'Student updated', student });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Delete student (Super Admin only)
app.delete('/api/students/:id', requireSuperAdmin, (req, res) => {
  try {
    const index = students.findIndex(s => s.id === parseInt(req.params.id));
    
    if (index > -1) {
      students.splice(index, 1);
      res.json({ success: true, message: 'Student deleted' });
    } else {
      res.json({ success: false, message: 'Student not found' });
    }
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ════════════════════════════════════════
// 📄 EXAM RESULTS ENDPOINTS
// ════════════════════════════════════════

// Get SSC results
app.get('/api/results/ssc', requireAuth, (req, res) => {
  try {
    const sscResults = students.map(s => ({
      id: s.id,
      roll: s.roll,
      name: s.name,
      ssc: s.ssc,
      addedBy: s.addedBy
    }));
    res.json({ success: true, results: sscResults });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// Get HSC results
app.get('/api/results/hsc', requireAuth, (req, res) => {
  try {
    const hscResults = students.map(s => ({
      id: s.id,
      roll: s.roll,
      name: s.name,
      hsc: s.hsc,
      addedBy: s.addedBy
    }));
    res.json({ success: true, results: hscResults });
  } catch (error) {
    res.status(500).json({ success: false, message: 'Server error' });
  }
});

// ════════════════════════════════════════
// 📁 STATIC FILES
// ════════════════════════════════════════
app.use(express.static('frontend'));
app.use(express.static('admin'));

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
});

// ════════════════════════════════════════
// 🚀 SERVER START
// ════════════════════════════════════════
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
EOF

echo "✅ backend/server.js completely rebuilt"

# Install helmet if not already installed
echo "📦 Ensuring Helmet is installed..."
npm install helmet --save

echo "════════════════════════════════════════"
echo "✅ COMPLETE BACKEND REBUILD FINISHED!"
echo "════════════════════════════════════════"
echo ""
echo "✨ Features Added:"
echo "  ✅ CORS fully configured"
echo "  ✅ Role-based access control (RBAC)"
echo "  ✅ Super Admin & Sub-Admin roles"
echo "  ✅ Admin users database"
echo "  ✅ Student data structure"
echo "  ✅ SSC exam data"
echo "  ✅ HSC exam data"
echo "  ✅ Data filtering by role"
echo "  ✅ Edit permission control"
echo "  ✅ Account lock/unlock feature"
echo "  ✅ Password change endpoint"
echo "  ✅ Session management"
echo "  ✅ Helmet security"
echo "  ✅ JSON parser"
echo ""
echo "🚀 Ready for deployment!"
