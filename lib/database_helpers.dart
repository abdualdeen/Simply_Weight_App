import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weight_app/weight_model.dart';

Future<Database> initializeDB() async {
  String path = await getDatabasesPath();
  return openDatabase(
    join(path, "weights.db"),
    onCreate: (database, version) async {
      await database.execute("CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT, weight DOUBLE NOT NULL, dateTime DATETIME NOT NULL )");
    },
    version: 1,
  );
}

Future<int> insertUser(Weight weight) async {
  final Database db = await initializeDB();
  return await db.insert('weights', weight.toMap());
}

Future<List<Weight>> getAllWeights() async {
  final Database db = await initializeDB();
  List<Map<String, dynamic>> result = await db.query('weights');
  return result.map((e) => Weight.fromMap(e)).toList();
}

Future<void> deleteUser(int id) async {
  final Database db = await initializeDB();
  db.delete('weights', where: 'id= ?', whereArgs: [id]);
}

Future<void> updateUsingHelper(Weight weight) async {
  final Database db = await initializeDB();
  await db.update('users', weight.toMap(), where: 'id= ?', whereArgs: [weight.id]);
}
