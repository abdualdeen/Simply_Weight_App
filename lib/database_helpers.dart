import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weight_app/weight_model.dart';

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

  Future<List<Weight>> getAllWeights() async {
    final Database db = await initializeDB();
    List<Map<String, dynamic>> result = await db.query('weights');
    return result.map((e) => Weight.fromMap(e)).toList();
  }

  Future<void> deleteWeight(int id) async {
    final Database db = await initializeDB();
    db.delete('weights', where: 'id= ?', whereArgs: [id]);
  }

  Future<void> updateWeight(Weight weight) async {
    final Database db = await initializeDB();
    await db.update('weights', weight.toMap(), where: 'id= ?', whereArgs: [weight.id]);
  }

  Future<List<Weight>> getLastWeight() async {
    final Database db = await initializeDB();
    List<Map<String, dynamic>> result = await db.query('weights', orderBy: 'id DESC', limit: 1);
    return result.map((e) => Weight.fromMap(e)).toList();
  }

  Future<void> fillDbForTesting() async {
    Weight weight1 = Weight(id: 1, weight: 135.0, dateTime: DateTime.parse('2024-01-15 17:30:00'));
    Weight weight2 = Weight(id: 2, weight: 136.0, dateTime: DateTime.parse('2024-01-16 17:30:00'));
    Weight weight3 = Weight(id: 3, weight: 136.5, dateTime: DateTime.parse('2024-01-17 17:30:00'));
    Weight weight4 = Weight(id: 4, weight: 136.0, dateTime: DateTime.parse('2024-01-18 17:30:00'));
    Weight weight5 = Weight(id: 5, weight: 135.8, dateTime: DateTime.parse('2024-01-19 17:30:00'));

    List<Weight> testData = [weight1, weight2, weight3, weight4, weight5];
    for (final Weight x in testData) {
      insertWeight(x);
    }
  }
}
