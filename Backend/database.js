const sqlite3 = require('sqlite3').verbose();

const db = new sqlite3.Database('./sql_databade.db', (err) => {
    if (err) {
        console.error('Error opening database', err.message);
    } else {
        console.log('Connected to SQLite database');
        db.run(`CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            UserName TEXT NOT NULL,
            PhoneNo TEXT UNIQUE NOT NULL,
            Password TEXT NOT NULL,
            FCMToken TEXT NULL,
            JWTToken TEXT NULL
        )`);

        db.run(`CREATE TABLE IF NOT EXISTS Medicine (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            MedicineName TEXT NOT NULL,
            Morning INTEGER DEFAULT 0,
            Afternoon INTEGER DEFAULT 0,
            Evening INTEGER DEFAULT 0,
            Night INTEGER DEFAULT 0,
            IntakeTime TEXT CHECK(IntakeTime IN ('Before Food', 'After Food')) NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`);

        db.run(`CREATE TABLE IF NOT EXISTS Reminders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            Activity TEXT NOT NULL,
            Frequency TEXT CHECK(Frequency IN ('Daily', 'Weekly', 'Monthly', 'Yearly')) NOT NULL,
            ReminderNeeded TEXT CHECK(ReminderNeeded IN ('Needed', 'Not Needed')) DEFAULT 'Needed',
            ReminderDate DATE,
            ReminderTime TIME,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`);

        db.run(`CREATE TABLE IF NOT EXISTS Habits (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            Smoking TEXT CHECK(Smoking IN ('Frequently', 'Rarely', 'No')) DEFAULT 'No',
            Drinking TEXT CHECK(Drinking IN ('Frequently', 'Rarely', 'No')) DEFAULT 'No',
            Junk_food TEXT CHECK(Junk_food IN ('Frequently', 'Rarely', 'No')) DEFAULT 'No',
            Drugs TEXT CHECK(Drugs IN ('Frequently', 'Rarely', 'No')) DEFAULT 'No',
            Coffee TEXT CHECK(Coffee IN ('Frequently', 'Rarely', 'No')) DEFAULT 'No',
            Tea TEXT CHECK(Tea IN ('Frequently', 'Rarely', 'No')) DEFAULT 'No',
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`);
        db.run(`CREATE TABLE IF NOT EXISTS MedicalDetails (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            Condition TEXT NOT NULL,
            Height INTEGER NOT NULL,
            Weight INTEGER NOT NULL,
            Age INTEGER NOT NULL,
            Treatment TEXT NOT NULL,
            Tablet TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`);

        db.run(`CREATE TABLE IF NOT EXISTS Doctor (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            DoctorName TEXT NOT NULL,
            Gender TEXT CHECK(Gender IN ('Male', 'Female')) NOT NULL,
            PhoneNo TEXT UNIQUE NOT NULL,
            Specialization TEXT NOT NULL,
            WorkingHours TEXT NOT NULL,
            HospitalName TEXT NOT NULL,
            HospitalAddress TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`);

        db.run(`CREATE TABLE IF NOT EXISTS Family (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            Name TEXT NOT NULL,
            PhoneNo TEXT UNIQUE NOT NULL,
            Relation TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`);
    }
});

module.exports = db;
