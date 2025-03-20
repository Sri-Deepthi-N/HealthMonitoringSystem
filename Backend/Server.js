const express = require('express');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const bodyParser = require('body-parser');
const cors = require('cors');
const db = require('./database');
const auth = require("./Middleware/auth");
const PORT = process.env.PORT || 3000;
const app = express();
app.use(cors());
app.use(express.json());
app.use(bodyParser.json());

// Secret key for JWT
const JWT_SECRET = "Project123";

const verifyToken = (req, res, next) => {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    if (!token) {
        return res.status(403).json({ error: 'Access denied. No token provided.' });
    }
    try {
        const decoded = jwt.verify(token, SECRET_KEY);
        req.userId = decoded.userId;
        next();
    } catch (err) {
        return res.status(400).json({ error: 'Invalid token' });
    }
};

//Signup
app.post('/signup', async (req, res) => {
    try {
        const { username, mobile, password } = req.body;
        if (!username || !mobile || !password) {
            return res.status(400).json({ msg: "All fields are required" });
        }
        db.get(`SELECT * FROM users WHERE PhoneNo = ?`, [mobile], async (err, existingUser) => {
            if (err) return res.status(500).json({ error: err.message });
            if (existingUser) return res.status(400).json({ msg: "User already exists" });
            const hashedPassword = await bcrypt.hash(password, 8);
            const token = jwt.sign({ mobile }, JWT_SECRET);
            db.run(
                `INSERT INTO users (UserName, PhoneNo, Password, JWTToken) VALUES (?, ?, ?,?)`,
                [username, mobile, hashedPassword, token],
                function (err) {
                    if (err) return res.status(500).json({ error: err.message });
                    res.status(200).json('User registered successfully');
                }
            );
        });

    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Login
app.post('/login', (req, res) => {
    try {
        const { mobile, password } = req.body;
        if (!mobile || !password) {
            return res.status(400).json({ msg: "Both mobile and password are required" });
        }
        db.get(`SELECT * FROM users WHERE PhoneNo = ?`, [mobile], async (err, user) => {
            if (err) return res.status(500).json({ error: err.message });
            if (!user) return res.status(400).json({ msg: "User not found" });
            if (!user.Password) return res.status(500).json({ error: "Stored password is missing" });
            const match = await bcrypt.compare(password, user.Password);
            if (!match) {
                return res.status(400).json({ msg: "Invalid credentials" });
            }
            res.status(200).json({ msg: "Login successful", user });
        });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

app.post("/tokenIsValid", (req, res) => {
    const token = req.header("x-auth-token");
    if (!token) return res.json(false);
    let verified;
    try {
        verified = jwt.verify(token, "Project123");
    } catch (error) {
        return res.json(false);
    }
    db.get("SELECT * FROM users WHERE JWTToken = ?", [token], (err, row) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        if (!row) return res.json(false);
        res.json(true);
    });
});

app.get("/", auth, async (req, res) => {
    const userId = req.user.mobile;
    db.get("SELECT * FROM users WHERE PhoneNo = ?", [userId], (err, row) => {
      if (err) {
          return res.status(500).json({ error: "Database error" });
      }
      if (!row) {
          return res.status(404).json({ error: "User not found" });
      }
      res.json({ ...row, token: req.token });
    });
});


//MEDICINE DETAILS
//ADD
app.post('/medicine', (req, res) => {
    const {user_id, MedicineName, Morning, Afternoon, Evening, Night, IntakeTime } = req.body;
    db.run(`INSERT INTO Medicine (user_id, MedicineName, Morning, Afternoon, Evening, Night, IntakeTime) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [user_id, MedicineName, Morning, Afternoon, Evening, Night, IntakeTime], function (err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ id: this.lastID });
        });
});
//GET
app.get('/medicine/:id', (req, res) => {
query = (`SELECT * FROM Medicine WHERE user_id = ?`);
    db.all(query, [req.params.id], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});
//DELETE
app.delete('/medicine/:id', (req, res) => {
    db.run(`DELETE FROM Medicine WHERE id = ? `, [req.params.id], function (err) {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ deletedID: req.params.id });
    });
});


//REMINDER DETAILS
//ADD
app.post('/reminders', (req, res) => {
    const { user_id, Activity, Frequency, ReminderNeeded, ReminderDate, ReminderTime } = req.body;
    db.run(`INSERT INTO Reminders (user_id, Activity, Frequency, ReminderNeeded, ReminderDate, ReminderTime)
            VALUES (?, ?, ?, ?, ?, ?)`,
        [user_id, Activity, Frequency, ReminderNeeded, ReminderDate, ReminderTime],
        function (err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ id: this.lastID });
        });
});
//GET
app.get('/reminders/:id', (req, res) => {
    db.all(`SELECT * FROM Reminders WHERE user_id = ?`, [req.params.id], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});


// HABIT DETAILS
//ADD
app.post('/habits', (req, res) => {
    const {user_id, Smoking, Drinking, Junk_food, Drugs, Coffee, Tea } = req.body;
    db.run(`INSERT INTO Habits (user_id, Smoking, Drinking, Junk_food, Drugs, Coffee, Tea) VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [user_id, Smoking, Drinking, Junk_food, Drugs, Coffee, Tea], function (err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ id: this.lastID });
        });
});
//GET
app.get('/habits/:id', (req, res) => {
    db.all(`SELECT * FROM Habits WHERE user_id = ?`, [req.params.id], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});
//UPDATE
app.put('/habits/:id', (req, res) => {
    const { Smoking, Drinking, Junk_food, Drugs, Coffee, Tea } = req.body;
    db.run(`UPDATE Habits SET Smoking = ?, Drinking = ?, Junk_food = ?, Drugs = ?, Coffee = ?, Tea = ? WHERE id = ?`,
        [Smoking, Drinking, Junk_food, Drugs, Coffee, Tea, req.params.id,], function (err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ updatedID: req.params.id });
        });
});


// MEDICAL DETAILS
//ADD
app.post('/medicaldetails', (req, res) => {
    const { user_id, Condition, Height, Weight, Age, Treatment, Tablet } = req.body;
    db.run(`INSERT INTO MedicalDetails (user_id, Condition, Height, Weight, Age, Treatment, Tablet)
            VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [user_id, Condition, Height, Weight, Age, Treatment, Tablet],
        function (err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ id: this.lastID });
        });
});
// GET
app.get('/medicaldetails/:id', (req, res) => {
    db.all(`SELECT * FROM MedicalDetails WHERE user_id = ?`, [req.params.id], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});
// UPDATE
app.put('/medicaldetails/:id', (req, res) => {
    const { Condition, Height, Weight, Age, Treatment, Tablet } = req.body;
    db.run(`UPDATE MedicalDetails
            SET Condition = ?, Height = ?, Weight = ?, Age = ?, Treatment = ?, Tablet = ?
            WHERE id = ?`,
        [Condition, Height, Weight, Age, Treatment, Tablet, req.params.id],
        function (err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ updatedID: req.params.id });
        });
});


//DOCTOR DETAILS
// ADD
app.post('/doctor', (req, res) => {
    const { user_id, DoctorName, Gender, PhoneNo, Specialization, WorkingHours, HospitalName, HospitalAddress } = req.body;
    db.run(
        `INSERT INTO Doctor (user_id, DoctorName, Gender, PhoneNo, Specialization, WorkingHours, HospitalName, HospitalAddress)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [user_id, DoctorName, Gender, PhoneNo, Specialization, WorkingHours, HospitalName, HospitalAddress],
        function (err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ id: this.lastID });
        }
    );
});
// GET
app.get('/doctor/:id', (req, res) => {
    db.all(`SELECT * FROM Doctor WHERE user_id = ?`, [req.params.id], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});
// DELETE
app.delete('/doctor/:id', (req, res) => {
    db.run(`DELETE FROM Doctor WHERE id = ?`,
        [req.params.id],
        function (err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ deletedID: req.params.id });
        }
    );
});


//FAMILY DETAILS
// ADD
app.post('/family', (req, res) => {
    const { user_id, Name, PhoneNo, Relation } = req.body;
    db.run(`INSERT INTO Family (user_id, Name, PhoneNo, Relation) VALUES (?, ?, ?, ?)`,
        [user_id, Name, PhoneNo, Relation],
        function (err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ id: this.lastID });
        });
});
//GET
app.get('/family/:id', (req, res) => {
    db.all(`SELECT * FROM Family WHERE user_id = ?`, [req.params.id], (err, rows) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(rows);
    });
});
// DELETE
app.delete('/family/:id', (req, res) => {
    db.run(`DELETE FROM Family WHERE id = ?`,
        [req.params.id],
        function (err) {
            if (err) return res.status(500).json({ error: err.message });
            res.json({ deletedID: req.params.id });
        });
});


// Start the server
app.listen(PORT, "0.0.0.0", () => console.log(`Server running on port ${PORT}`));
