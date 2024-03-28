import 'dart:math';

import 'package:weight_app/weight_model.dart';

List<Weight> generateTestData() {
  DateTime nowDateTime = DateTime.now();

  List<Weight> testData = [];

  Random _random = Random();

  // Generate test data for each day in the week before endDate
  for (DateTime date = nowDateTime.subtract(const Duration(days: 400)); date.isBefore(nowDateTime); date = date.add(const Duration(days: 1))) {
    double weight = double.parse((130 + _random.nextDouble() * (145 - 140)).toStringAsFixed(2)); // Generate weight between 140 and 145
    Weight dataPoint = Weight(id: _random.nextInt(500), weight: weight, dateTime: date);
    testData.add(dataPoint);
  }

  return testData;
}
