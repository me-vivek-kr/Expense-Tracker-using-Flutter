import 'package:expense_tracker/models/expense.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper.internal();

  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'expense.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE expenses(
            id TEXT PRIMARY KEY,
            title TEXT,
            amount REAL,
            date TEXT,
            category TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertExpense(Expense expense) async {
    var dbClient = await db;
    return await dbClient!.insert('expenses', expense.toMap());
  }

  // Retrieve all expenses from the database
  Future<List<Expense>> getExpense() async {
    var dbClient = await db;
    List<Map<String, dynamic>> result = await dbClient!.query('expenses');

    return result.map((data) => Expense.fromMap(data)).toList();
  }
  
  Future<int> deleteExpense(int id) async {
    var dbClient = await db;
    return await dbClient!.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
}
