import 'package:flutter/foundation.dart';
import 'package:flutter_charts/flutter_charts.dart' as charts;

class WeightSeries {
  final double weight;
  final DateTime dateTime;
  final charts.Color barColor;

  DeveloperSeries({@required this.weight, @required this.dateTime, @required this.barColor});
}
