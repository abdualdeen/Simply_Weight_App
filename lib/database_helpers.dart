import "package:collection/collection.dart";
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:weight_app/testing_data.dart';
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

  Future<List<Weight>> getLastWeekWeights() async {
    final Database db = await initializeDB();
    List<Map<String, dynamic>> result =
        await db.rawQuery("select * from weights where dateTime between datetime('now', '-6 days') and datetime('now' , 'localtime');");
    return result.map((e) => Weight.fromMap(e)).toList();
  }

  // the purpose of this function is to make it so that there is an average weight for days where there is multiple entries.
  Future<void> prepareWeightList(weightList) async {
    // todo: add type for weightlist
    // Map<dynamic, List<Weight>>
    Map<dynamic, List<Weight>> groupedWeightList = groupBy(weightList, (Weight obj) => DateFormat('yMd').format(obj.dateTime));
    for (int i = 0; i < groupedWeightList.length; i++) {
      print(groupedWeightList[i]);
    }
  }

  Future<List<Weight>> getLastMonthWeights() async {
    final Database db = await initializeDB();
    List<Map<String, dynamic>> result =
        await db.rawQuery("select * from weights where dateTime between datetime('now', 'start of month') and datetime('now' , 'localtime');");
    return result.map((e) => Weight.fromMap(e)).toList();
  }

  Future<List<Weight>> getLastYearWeights() async {
    final Database db = await initializeDB();
    List<Map<String, dynamic>> result =
        await db.rawQuery("select * from weights where dateTime between datetime('now', 'start of year') and datetime('now' , 'localtime');");
    return result.map((e) => Weight.fromMap(e)).toList();
  }

  Future<void> deleteTable() async {
    final Database db = await initializeDB();
    db.delete('weights');
  }

  Future<void> createTable() async {
    final Database db = await initializeDB();
    db.execute("CREATE TABLE weights (id INTEGER PRIMARY KEY AUTOINCREMENT, weight DOUBLE NOT NULL, dateTime DATETIME NOT NULL)");
  }

  Future<void> fillDbForTesting() async {
    await deleteTable();
    await createTable();
    List<Weight> testData = [
      weight1,
      weight2,
      weight3,
      weight4,
      weight5,
      weight6,
      weight7,
      weight8,
      weight9,
      weight10,
      weight11,
      weight12,
      weight13,
      weight14,
      weight15,
      weight16,
      weight17,
      weight18,
      weight19,
      weight20,
      weight21
    ];
    for (final Weight x in testData) {
      insertWeight(x);
    }
  }
}
