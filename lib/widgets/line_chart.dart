import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';

LineChart weightLineChart(List<FlSpot> weightSpots) {
  return LineChart(
    LineChartData(
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
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
        LineChartBarData(spots: weightSpots),
      ],
    ),
  );
}
