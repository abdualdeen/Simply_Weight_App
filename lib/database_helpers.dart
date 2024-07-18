import 'package:path/path.dart';
import 'package:simply_weight/testing_data.dart';
import 'package:simply_weight/weight_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, "weights.db"),
      onCreate: (database, version) async {
        await database.execute("CREATE TABLE weights (id INTEGER PRIMARY KEY AUTOINCREMENT, weight DOUBLE NOT NULL, dateTime DATETIME NOT NULL)");
      },
      version: 1,
    );
  }

  Future<int> insertWeight(Weight weight) async {
    final Database db = await initializeDB();
    return await db.insert('weights', weight.toMap());
  }

  Future<void> deleteWeight(int id) async {
    final Database db = await initializeDB();
    db.delete('weights', where: 'id= ?', whereArgs: [id]);
  }

  Future<void> updateWeight(Weight weight) async {
    final Database db = await initializeDB();
    await db.update('weights', weight.toMap(), where: 'id= ?', whereArgs: [weight.id]);
  }

  // these two functions below are used for testing purposes.
  Future<void> deleteTable() async {
    final Database db = await initializeDB();
    db.delete('weights');
  }

  Future<void> createTable() async {
    final Database db = await initializeDB();
    db.execute("CREATE TABLE weights (id INTEGER PRIMARY KEY AUTOINCREMENT, weight DOUBLE NOT NULL, dateTime DATETIME NOT NULL)");
  }

  Future<List<Weight>> getLastWeekWeights() async {
    final Database db = await initializeDB();
    List<Map<String, dynamic>> result =
        await db.rawQuery("select * from weights where dateTime between datetime('now', '-6 days') and datetime('now', 'localtime');");
    return result.map((e) => Weight.fromMap(e)).toList();
  }

  Future<List<Weight>> getLastMonthWeights() async {
    final Database db = await initializeDB();
    List<Map<String, dynamic>> result =
        await db.rawQuery("select * from weights where dateTime between datetime('now', '-30 days') and datetime('now', 'localtime');");
    return result.map((e) => Weight.fromMap(e)).toList();
  }

  Future<List<Weight>> getLastYearWeights() async {
    final Database db = await initializeDB();
    List<Map<String, dynamic>> result =
        await db.rawQuery("select * from weights where dateTime between datetime('now', 'start of year') and datetime('now' , 'localtime');");
    return result.map((e) => Weight.fromMap(e)).toList();
  }

  Future<List<Weight>> getAllWeights() async {
    final Database db = await initializeDB();
    List<Map<String, dynamic>> result = await db.query('weights');
    return result.map((e) => Weight.fromMap(e)).toList();
  }

  Future<List<Weight>> getLastWeight() async {
    final Database db = await initializeDB();
    List<Map<String, dynamic>> result = await db.query('weights', orderBy: 'id DESC', limit: 1);
    return result.map((e) => Weight.fromMap(e)).toList();
  }

  Future<void> fillDbForTesting() async {
    await deleteTable();
    await createTable();
    List<Weight> testData = generateTestData();
    for (final Weight x in testData) {
      insertWeight(x);
    }
  }
}
