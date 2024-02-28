import 'package:flutter/material.dart';
import 'package:weight_app/database_helpers.dart';
import 'package:weight_app/weight_model.dart';
import 'package:weight_app/widgets/line_chart.dart';

enum Calendar { week, month, year, all }

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  Calendar _selectedCalendar = Calendar.week;
  DatabaseHelper dbHelper = DatabaseHelper();

  // this was done this way because I cannot pass in the weightlist into the linechart with `await` as you cannot use that inside the futurebuilder.
  Future<dynamic> callLineChart() async {
    List<Weight> weightList = await dbHelper.getLastMonthWeights();
    return weightLineChart(weightList);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: SegmentedButton<Calendar>(
            segments: const <ButtonSegment<Calendar>>[
              ButtonSegment(value: Calendar.week, label: Text('1W')),
              ButtonSegment(value: Calendar.month, label: Text('1M')),
              ButtonSegment(value: Calendar.year, label: Text('1Y')),
              ButtonSegment(value: Calendar.all, label: Text('All'))
            ],
            selected: <Calendar>{_selectedCalendar},
            onSelectionChanged: (Set<Calendar> newSelection) {
              setState(() {
                _selectedCalendar = newSelection.first;
              });
            },
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 500,
          child: FutureBuilder<dynamic>(
            future: callLineChart(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // todo: figure out what to do with logging here.
                // appLog.d(snapshot.error);
                return Text('Error: ${snapshot.error}');
              } else {
                return snapshot.data ?? Container();
              }
            },
          ),
        ),
      ],
    );
  }
}
