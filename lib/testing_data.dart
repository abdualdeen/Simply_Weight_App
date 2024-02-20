import 'dart:math';

import 'package:weight_app/weight_model.dart';

const String START_DATE = '2023-01-01 00:00:00';
const String END_DATE = '2024-02-02 00:00:00';

List<Weight> generateTestData() {
  DateTime startDate = DateTime.parse(START_DATE);
  DateTime endDate = DateTime.parse(END_DATE);

  List<Weight> testData = [];

  Random random = Random();

  // Generate test data for each day in the week before endDate
  for (DateTime date = startDate; date.isBefore(endDate); date = date.add(const Duration(days: 1))) {
    double weight = double.parse((100 + random.nextDouble() * 160).toStringAsFixed(2)); // Generate weight between 100 and 150
    Weight dataPoint = Weight(id: random.nextInt(500), weight: weight, dateTime: date);
    testData.add(dataPoint);
  }

  return testData;
}
