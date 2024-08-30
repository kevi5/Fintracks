import 'package:FinTrack/models/category_model.dart';
import 'package:FinTrack/models/transaction_model.dart';
import 'package:FinTrack/models/trash_model.dart';
import 'package:FinTrack/models/recurrence_model.dart';
import 'package:FinTrack/util/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();

  factory DBHelper() => _instance;

  DBHelper._internal();

  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'categories.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        String categoriesTableCreationQuery = '''
          CREATE TABLE IF NOT EXISTS categories(
            cat_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            cat_name TEXT NOT NULL,
            cat_type INTEGER DEFAULT 0,
            cat_count INTEGER, 
            cat_color STRING, 
            cat_is_fav BOOL DEFAULT 0
          )
        ''';
        await db.execute(categoriesTableCreationQuery);

        String transactionsTableCreationQuery = '''
          CREATE TABLE IF NOT EXISTS transactions (
            id INTEGER NOT NULL PRIMARY KEY autoincrement, 
            description TEXT,
            amount FLOAT NOT NULL DEFAULT '0', 
            date TEXT NOT NULL, 
            cat_id INTEGER NOT NULL, 
            is_auto_added INTEGER DEFAULT 0, 
            FOREIGN KEY(cat_id) REFERENCES categories(cat_id)
          )
        ''';
        await db.execute(transactionsTableCreationQuery);

        String recurringTableCreationQuery = '''
          CREATE TABLE IF NOT EXISTS recurrence(
            recur_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            recur_amount TEXT, 
            recur_note TEXT, 
            recur_cat_id INTEGER,
            recur_type INTEGER, 
            recur_on_label TEXT,
            recur_on TEXT,
            recur_shown BOOL DEFAULT 0
          )''';
        await db.execute(recurringTableCreationQuery);

        String trashTableCreationQuery = '''
          CREATE TABLE IF NOT EXISTS trash (
            id INTEGER NOT NULL PRIMARY KEY autoincrement, 
            description TEXT,
            amount FLOAT NOT NULL DEFAULT '0', 
            date TEXT NOT NULL, 
            cat_id INTEGER NOT NULL, 
            is_auto_added INTEGER DEFAULT 0,
            trash_date TEXT NOT NULL,
            FOREIGN KEY(cat_id) REFERENCES categories(cat_id)
          )
        ''';
        await db.execute(trashTableCreationQuery);

        for (CategoryModel category in Constants.initialCategories) {
          await db.insert('categories', category.toJson());
        }
      },
    );
  }

  //TRANSACTIONS TABLE CRUD OPERATIONS
  static Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toJson());
  }

  static Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('transactions', orderBy: 'date DESC');
    return maps;
  }

  static Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toJson(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  static Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getTransactionById(int id) async {
    final db = await database;
    return db.query('transactions', where: 'id=?', whereArgs: [id], limit: 1);
  }

  static void deleteAllTransactions() async {
    final db = await database;
    String query = 'DROP TABLE IF EXISTS transactions';
    await db.execute(query);
  }

  static Future<List<Map<String, dynamic>>> getTransactionsByDate(
      DateTime fromDate, DateTime toDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('transactions',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [fromDate.toIso8601String(), toDate.toIso8601String()],
        orderBy: 'date DESC');
    return maps;
  }

  static Future<DateTime> getStartDate() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db
        .rawQuery('''SELECT MIN(date) AS firstDate FROM transactions''');

    DateTime date = result.isNotEmpty && result.first['firstDate'] != null
        ? DateTime.parse(result.first['firstDate']!)
        : DateTime.now();
    date = DateTime(date.year, date.month - 1, date.day);
    return date;
  }

  static Future<double?> getAmountByDate(
      int type, DateTime fromDate, DateTime toDate) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery(
        '''SELECT SUM(t.amount) as totalAmount
      FROM transactions as t
      JOIN categories as c ON t.cat_id = c.cat_id
      WHERE c.cat_type = ? and date BETWEEN ? AND ?''',
        [type, fromDate.toIso8601String(), toDate.toIso8601String()]);
    final double? totalAmount = result.first['totalAmount'];
    return totalAmount;
  }

  //CATAGORIES TABLE CRUD OPERATIONS
  static Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert('categories', category.toJson());
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return maps;
  }

  static Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toJson(),
      where: 'cat_id = ?',
      whereArgs: [category.catId],
    );
  }

  static Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete(
      'categories',
      where: 'cat_id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getCategoryById(int id) async {
    final db = await database;
    return db.query('categories', where: 'cat_id=?', whereArgs: [id], limit: 1);
  }

  static void deleteAllCategories() async {
    final db = await database;
    String query = 'DROP TABLE IF EXISTS categories';
    await db.execute(query);
  }

  //RECURRENCE TABLE CRUD OPERATIONS
  static Future<int> insertRecurrence(RecurrenceModel recurrence) async {
    final db = await database;
    return await db.insert('recurrence', recurrence.toJson());
  }

  static Future<List<Map<String, dynamic>>> getRecurrences() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('recurrence');
    return maps;
  }

  static Future<int> updateRecurrence(RecurrenceModel recurrence) async {
    final db = await database;
    return await db.update(
      'recurrence',
      recurrence.toJson(),
      where: 'recur_id = ?',
      whereArgs: [recurrence.recurId],
    );
  }

  static Future<int> deleteRecurrence(int id) async {
    final db = await database;
    return await db.delete(
      'recurrence',
      where: 'recur_id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getRecurrenceById(int id) async {
    final db = await database;
    return db.query('recurrence',
        where: 'recur_id=?', whereArgs: [id], limit: 1);
  }

  static void deleteAllRecurrences() async {
    final db = await database;
    String query = 'DROP TABLE IF EXISTS recurrence';
    await db.execute(query);
  }

  static Future<List<Map<String, dynamic>>> getUpcomingRecurrentTransactions(
      DateTime startdate, DateTime endDate) async {
    final db = await database;
    return db.query('recurrence',
        where: 'recur_on BETWEEN ? AND ? AND recur_shown = ?',
        whereArgs: [
          startdate.toIso8601String(),
          endDate.toIso8601String(),
          false
        ]);
  }

  /// SQL QUERY IN RAW FORM
  /// SELECT * from recurrence where recur_on BETWEEN '2021-09-01T00:00:00.000' AND '2021-09-30T00:00:00.000' AND recur_shown = 0;

  // TRASH TABLE OPERATIONS
  static Future<int> insertTrash(TrashModel trash) async {
    final db = await database;
    return await db.insert('trash', trash.toJson());
  }

  static Future<List<Map<String, dynamic>>> getTrash() async {
    deleteExpiredTransactionsFromTrash();
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query('trash');
    return maps;
  }

  static Future<int> deleteTrash(int id) async {
    final db = await database;
    return await db.delete(
      'trash',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<List<Map<String, dynamic>>> getTrashById(int id) async {
    final db = await database;
    return db.query('trash', where: 'id=?', whereArgs: [id], limit: 1);
  }

  static void deleteAllTrash() async {
    final db = await database;
    String query = 'DROP TABLE IF EXISTS trash';
    await db.execute(query);
  }

  static void deleteExpiredTransactionsFromTrash() async {
    final db = await database;

    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(Duration(days: 30));

    // Delete old transactions
    await db.delete(
      'trash',
      where: 'trash_date < ?',
      whereArgs: [thirtyDaysAgo.toIso8601String()],
    );
  }
}
