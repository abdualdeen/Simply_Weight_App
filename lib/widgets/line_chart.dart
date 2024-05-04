import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../weight_model.dart';

List<FlSpot> getWeightSpots(List<Weight> weightList) {
  // Create FlSpot instances from Weight objects
  List<FlSpot> spots = weightList.map((weight) {
    print("${weight.dateTime.toString()}, ${weight.weight}");
    return FlSpot(weight.dateTime.millisecondsSinceEpoch.toDouble(), weight.weight);
  }).toList();

  return spots;
}

Future<dynamic> weightLineChart(List<Weight> weightList, double xAxisInterval) async {
  if (weightList.isEmpty) {
    return const Center(child: Text('No recorded data yet.'));
  }
  List<FlSpot> weightSpots = getWeightSpots(weightList);
  return LineChart(
    LineChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
            // todo: maybe change this later as it is a jank way to add space to the right side of the chart.
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return const Text('');
                })),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              Widget text = Text(value.toInt().toString());
              return SideTitleWidget(axisSide: meta.axisSide, child: text);
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: xAxisInterval,
            // reservedSize: 25,
            // dealing with how the date axis should be displayed.
            getTitlesWidget: (value, meta) {
              Widget text;
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              // Format DateTime to "MM/dd" string to display on chart
              text = Text(
                "${dateTime.month}/${dateTime.day}",
                style: const TextStyle(fontSize: 12),
              );
              return SideTitleWidget(
                axisSide: meta.axisSide,
                child: text,
                fitInside: const SideTitleFitInsideData(enabled: true, distanceFromEdge: 0, axisPosition: 0, parentAxisSize: 0),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        LineChartBarData(spots: weightSpots, belowBarData: BarAreaData(show: true)),
      ],
    ),
  );
}
