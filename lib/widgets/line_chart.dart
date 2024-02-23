import 'package:d_chart/d_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../weight_model.dart';

List<TimeData> _buildGroupList(List<Weight> weightList) {
  List<TimeData> timeDataList = [];
  for (final e in weightList) {
    timeDataList.add(TimeData(domain: DateTime(e.dateTime.year, e.dateTime.month, e.dateTime.day), measure: e.weight));
    print(e.weight);
  }
  return timeDataList;
}

DChartLineT weightLineChart(List<Weight> weightList) {
  final timeGroupList = [TimeGroup(id: '1', data: _buildGroupList(weightList))];
  return DChartLineT(
    groupList: timeGroupList,
    configRenderLine: ConfigRenderLine(includeArea: true),
    areaColor: (group, ordinalData, index) {
      return Colors.green.withOpacity(0.1);
    },
    fillColor: (group, ordinalData, index) {
      return Colors.green;
    },
    animate: true,
    // measureAxis: const MeasureAxis(numericViewport: NumericViewport(130, 145)),
  );
}

// brought back fl_chart because it looks the issue was my test data not the library. sorry fl_chart!
LineChart weightLineChart2(List<FlSpot> weightSpots) {
  return LineChart(
    LineChartData(
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            reservedSize: 35,
            // dealing with how the date axis should be displayed.
            getTitlesWidget: (value, meta) {
              Widget text;
              DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt());
              // Format DateTime to "MM/dd" string to display on chart
              text = Text("${dateTime.month}/${dateTime.day}");
              return SideTitleWidget(axisSide: meta.axisSide, child: text);
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
