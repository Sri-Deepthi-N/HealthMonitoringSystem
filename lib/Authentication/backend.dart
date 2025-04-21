import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'health.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        UserName TEXT,
        PhoneNo TEXT UNIQUE,
        Password TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE Doctor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        DoctorName TEXT,
        Gender TEXT,
        PhoneNo TEXT,
        Specialization TEXT,
        WorkingHours TEXT,
        HospitalName TEXT,
        HospitalAddress TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Medicine (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        MedicineName TEXT,
        Morning TEXT,
        Afternoon TEXT,
        Evening TEXT,
        Night TEXT,
        IntakeTime TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        Activity TEXT,
        Frequency TEXT,
        ReminderNeeded TEXT,
        ReminderDate TEXT,
        ReminderTime TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        Smoking TEXT,
        Drinking TEXT,
        Junk_food TEXT,
        Drugs TEXT,
        Coffee TEXT,
        Tea TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE MedicalDetails (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        Condition TEXT,
        Treatment TEXT,
        Tablet TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE Family (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        Name TEXT,
        PhoneNo TEXT,
        Relation TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('''
  CREATE TABLE HeartRate (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    value TEXT,
    date TEXT,
    time TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
''');

    await db.execute('''
  CREATE TABLE BPLevel (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    systolic TEXT,
    diastolic TEXT,
    date TEXT,
    time TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
''');

    await db.execute('''
  CREATE TABLE SleepQuality (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    quality TEXT,
    date TEXT,
    time TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
''');

    await db.execute('''
  CREATE TABLE BodyTemperature (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    value TEXT,
    date TEXT,
    time TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
''');

    await db.execute('''
  CREATE TABLE SpO2Level (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    percentage TEXT,
    date TEXT,
    time TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
''');

    await db.execute('''
  CREATE TABLE StepsTaken (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    steps TEXT,
    date TEXT,
    time TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
''');

    await db.execute('''
  CREATE TABLE CaloriesBurned (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    calories TEXT,
    date TEXT,
    time TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
''');

    await db.execute('''
  CREATE TABLE BloodGlucose (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    glucose TEXT,
    date TEXT,
    time TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
''');

    await db.execute('''
  CREATE TABLE DistanceTravelled (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    distance TEXT,
    date TEXT,
    time TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
  );
''');

  }

  // =================== AUTH ===================

  Future<int> signup(Map<String, dynamic> user) async {
    final dbClient = await db;
    return await dbClient.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByMobile(String mobile) async {
    final dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient.query(
      'users',
      where: 'PhoneNo = ?',
      whereArgs: [mobile],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<String?> login(String phone, String password) async {
    final dbClient = await db;
    final result = await dbClient.query('users', where: 'PhoneNo = ?', whereArgs: [phone]);

    if (result.isEmpty) return 'User not found';
    if (result[0]['Password'] != password) return 'Invalid password';

    int userId = result[0]['id'] as int;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);

    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }

  // =================== DOCTOR ===================

  Future<int> insertDoctor(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('Doctor', data);
  }

  Future<List<Map<String, dynamic>>> getDoctors(int userId) async {
    final dbClient = await db;
    return await dbClient.query('Doctor', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> deleteDoctor(int id) async {
    final dbClient = await db;
    return await dbClient.delete('Doctor', where: 'id = ?', whereArgs: [id]);
  }

  // =================== MEDICINE ===================

  Future<int> insertMedicine(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('Medicine', data);
  }

  Future<List<Map<String, dynamic>>> getMedicines(int userId) async {
    final dbClient = await db;
    return await dbClient.query('Medicine', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> deleteMedicine(int id) async {
    final dbClient = await db;
    return await dbClient.delete('Medicine', where: 'id = ?', whereArgs: [id]);
  }

  // =================== REMINDERS ===================

  Future<int> insertReminder(Map<String, dynamic> reminder) async {
    final dbClient = await db;
    return await dbClient.insert('Reminders', reminder);
  }

  Future<List<Map<String, dynamic>>> getReminders(int userId) async {
    final dbClient = await db;
    return await dbClient.query('Reminders', where: 'user_id = ?', whereArgs: [userId]);
  }


  // =================== HABITS ===================

  Future<int> insertHabit(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('Habits', data);
  }

  Future<Map<String, dynamic>?> getHabit(int userId) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'habits',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> updateHabit(int id, Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.update('Habits', data, where: 'id = ?', whereArgs: [id]);
  }

  // =================== MEDICAL DETAILS ===================

  Future<int> insertMedical(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('MedicalDetails', data);
  }

  Future<List<Map<String, dynamic>>> getMedicalDetails(int userId) async {
    final dbClient = await db;
    return await dbClient.query('MedicalDetails', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> updateMedical(int id, Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.update('MedicalDetails', data, where: 'id = ?', whereArgs: [id]);
  }

  // =================== FAMILY ===================

  Future<int> insertFamily(Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert('Family', data);
  }

  Future<List<Map<String, dynamic>>> getFamily(int userId) async {
    final dbClient = await db;
    return await dbClient.query('Family', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> deleteFamily(int id) async {
    final dbClient = await db;
    return await dbClient.delete('Family', where: 'id = ?', whereArgs: [id]);
  }

  //Health Data
  Future<int> insertHealthData(String tableName, Map<String, dynamic> data) async {
    final dbClient = await db;
    return await dbClient.insert(tableName, data);
  }

  Future<List<Map<String, dynamic>>> getHealthData(String tableName, String userId) async {
    final dbClient = await db;
    return await dbClient.query(
        tableName,
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC, time DESC'
    );
  }
}
