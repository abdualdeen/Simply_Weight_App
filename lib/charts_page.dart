import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_app/constants.dart';
import 'package:weight_app/database_helpers.dart';
import 'package:weight_app/weight_model.dart';
import 'package:weight_app/widgets/line_chart.dart';

// the purpose of this function is to make it so that there is an average weight for days where there is multiple entries.
List<Weight> calculateDailyAverageWeight(List<Weight> weights) {
  Map<String, List<double>> weightMap = {};

  // group weights with similar date together.
  for (Weight weight in weights) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(weight.dateTime);
    // Check if the date exists in the map
    if (weightMap.containsKey(formattedDate)) {
      // If yes, add the weight to the existing list
      weightMap[formattedDate]!.add(weight.weight);
    } else {
      // If no, create a new list with the weight
      weightMap[formattedDate] = [weight.weight];
    }
  }
  // Calculate the average weight for each date.
  List<Weight> averages = [];
  weightMap.forEach((date, weights) {
    double average = weights.reduce((value, element) => value + element) / weights.length;
    // id is set to zero as it's irrelevant for this use case.
    Weight averageWeight = Weight(id: 0, weight: average, dateTime: DateFormat('yyyy-MM-dd').parse(date));
    averages.add(averageWeight);
    //print("${averageWeight.dateTime.toString()}, ${averageWeight.weight}"); // todo: remove
  });
  return averages;
}

List<Weight> prepareMonthlyWeights(List<Weight> weights) {
  // "normalize" the weights so that there is one point per day.
  List<Weight> normalizedWeights = calculateDailyAverageWeight(weights);

  // treat it like displaying the week case.
  if (normalizedWeights.length < 7) {
    return normalizedWeights;
  }

  DateTime? startDate = normalizedWeights[0].dateTime;
  int counter = 0;
  double sum = 0;
  List<Weight> preparedWeights = [];

  for (int i = 0; i < normalizedWeights.length; i++) {
    // check if startDate is null and if it is assign the current date in the loop.
    startDate ??= normalizedWeights[i].dateTime;

    sum += normalizedWeights[i].weight;
    counter++;

    // average and add the weight to the list if we've gone through 4 days or it's the end of the list.
    if (i == preparedWeights.length - 1 || normalizedWeights[i].dateTime.difference(startDate).inDays >= 4) {
      double averagedWeight = double.parse((sum / counter).toStringAsFixed(2));
      preparedWeights.add(Weight(id: 0, weight: averagedWeight, dateTime: normalizedWeights[i].dateTime));
      // reset counter for next averaging.
      sum = 0;
      counter = 0;
      startDate = null;
    }
  }

  return preparedWeights;
}

List<Weight> prepareYearlyWeights(List<Weight> weights) {
  // "normalize" the weights so that there is one point per day.
  List<Weight> normalizedWeights = calculateDailyAverageWeight(weights);

  // treat it like displaying the week case.
  if (normalizedWeights.length < 7) {
    return normalizedWeights;
  }

  DateTime? startDate = normalizedWeights[0].dateTime;
  int counter = 0;
  double sum = 0;
  List<Weight> preparedWeights = [];

  for (int i = 0; i < normalizedWeights.length; i++) {
    // check if startDate is null and if it is assign the current date in the loop.
    startDate ??= normalizedWeights[i].dateTime;

    sum += normalizedWeights[i].weight;
    counter++;

    // average and add the weight to the list if we've gone through 4 days or it's the end of the list.
    if (i == preparedWeights.length - 1 || normalizedWeights[i].dateTime.difference(startDate).inDays >= 30) {
      double averagedWeight = double.parse((sum / counter).toStringAsFixed(2));
      preparedWeights.add(Weight(id: 0, weight: averagedWeight, dateTime: normalizedWeights[i].dateTime));
      // reset counter for next averaging.
      sum = 0;
      counter = 0;
      startDate = null;
    }
  }

  return preparedWeights;
}

Map<String, double> findLimits(List<Weight> weightList) {
  double maxY = weightList.reduce((a, b) => a.weight > b.weight ? a : b).weight + 5.0;
  double minY = weightList.reduce((a, b) => a.weight < b.weight ? a : b).weight - 5.0;
  double maxX = weightList
      .reduce((a, b) => a.dateTime.millisecondsSinceEpoch.toDouble() > b.dateTime.millisecondsSinceEpoch.toDouble() ? a : b)
      .dateTime
      .millisecondsSinceEpoch
      .toDouble();
  double minX = weightList
      .reduce((a, b) => a.dateTime.millisecondsSinceEpoch.toDouble() < b.dateTime.millisecondsSinceEpoch.toDouble() ? a : b)
      .dateTime
      .millisecondsSinceEpoch
      .toDouble();

  return <String, double>{'maxY': maxY, 'minY': minY, 'maxX': maxX, 'minX': minX};
}

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
  Future<dynamic> callLineChart(Calendar selectedCalendar) async {
    List<Weight> weightList = [];
    double interval = 0;
    Map<String, double> limits = {'maxY': 0, 'minY': 0, 'maxX': 0, 'minX': 0};
    if (selectedCalendar == Calendar.week) {
      List<Weight> weightData = await dbHelper.getLastWeekWeights();
      weightList = calculateDailyAverageWeight(weightData);
      interval = Constants.DAY_IN_MILLISECONDS;
      limits = findLimits(weightList);
    } else if (selectedCalendar == Calendar.month) {
      List<Weight> weightData = await dbHelper.getLastMonthWeights();
      weightList = prepareMonthlyWeights(weightData);
      interval = Constants.WEEK_IN_MILLISECONDS;
      limits = findLimits(weightList);
    } else if (selectedCalendar == Calendar.year) {
      List<Weight> weightData = await dbHelper.getLastYearWeights();
      weightList = prepareYearlyWeights(weightData);
      interval = Constants.MONTH_IN_MILLISECONDS;
      limits = findLimits(weightList);
    } else {
      List<Weight> weightData = await dbHelper.getAllWeights();
      weightList = prepareYearlyWeights(weightData);
      interval = Constants.THREE_MONTHS_IN_MILLISECONDS;
      limits = findLimits(weightList);
    }
    return weightLineChart(weightList, interval, limits);
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
            future: callLineChart(_selectedCalendar),
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
