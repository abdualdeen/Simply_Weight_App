import 'package:d_chart/d_chart.dart';

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
    // measureAxis: const MeasureAxis(numericViewport: NumericViewport(130, 145)),
  );
}
