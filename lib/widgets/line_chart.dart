import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../weight_model.dart';

List<FlSpot> getWeightSpots(List<Weight> weightList) {
  // Create FlSpot instances from Weight objects
  List<FlSpot> spots = weightList.map((weight) {
    return FlSpot(weight.dateTime.millisecondsSinceEpoch.toDouble(), weight.weight);
  }).toList();

  return spots;
}

Future<dynamic> weightLineChart(List<Weight> weightList, double xAxisInterval, Map<String, int> limits) async {
  if (weightList.isEmpty) {
    return const Center(child: Text('No recorded data yet.'));
  }
  List<FlSpot> weightSpots = getWeightSpots(weightList);
  return LineChart(
    LineChartData(
      maxY: limits['maxY']?.toDouble(),
      minY: limits['minY']?.toDouble(),
      maxX: limits['maxX']?.toDouble(),
      minX: limits['minX']?.toDouble(),
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
            interval: 5,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              Widget axisTitle = Text(value.toInt().toString());
              // A workaround to hide the max value title as FLChart is overlapping it on top of previous
              if (value == meta.max) {
                final remainder = value % meta.appliedInterval;
                if (remainder != 0.0 && remainder / meta.appliedInterval < 0.5) {
                  axisTitle = const SizedBox.shrink();
                }
              }
              return SideTitleWidget(axisSide: meta.axisSide, child: axisTitle);
            },
          ),
        ),
        topTitles: AxisTitles(
            sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return const Text('');
                })),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: xAxisInterval,
            // dealing with how the date axis should be displayed.
            getTitlesWidget: (value, meta) {
              Widget axisTitle;
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              // Format DateTime to "MM/dd" string to display on chart
              axisTitle = Text(
                "${dateTime.month}/${dateTime.day}",
                style: const TextStyle(fontSize: 12),
              );

              // A workaround to hide the max value title as FLChart is overlapping it on top of previous
              if (value == meta.max) {
                final remainder = value % meta.appliedInterval;
                if (remainder != 0.0 && remainder / meta.appliedInterval < 0.5) {
                  axisTitle = const SizedBox.shrink();
                }
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                fitInside: const SideTitleFitInsideData(enabled: true, distanceFromEdge: 0, axisPosition: 0, parentAxisSize: 0),
                child: axisTitle,
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
