import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:weight_app/database_helpers.dart';
import 'package:weight_app/weight_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData lightTheme = ThemeData(
      appBarTheme: const AppBarTheme(
        color: Colors.red,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.red,
        brightness: Brightness.light,
      ),
    );

    ThemeData darkTheme = ThemeData(
      appBarTheme: const AppBarTheme(
        color: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.red,
        brightness: Brightness.dark,
      ),
    );
    return MaterialApp(
      title: 'Simple Weight Tracking',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const MyHomePage(title: 'Simple Weight Tracking'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  double _weightValue = 0;
  late Future<List<Weight>> allWeights;
  DatabaseHelper dbHelper = DatabaseHelper();
  NavigationDestinationLabelBehavior labelBehavior = NavigationDestinationLabelBehavior.onlyShowSelected;
  TextEditingController _weightTextFieldController = TextEditingController();

  Future<void> _displayAddWeightDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add weight'),
            content: TextField(
              controller: _weightTextFieldController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Weight'),
            ),
            actions: [
              MaterialButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              MaterialButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    print(_weightTextFieldController.text);
                    // save information to local database
                    Weight newWeight = Weight.empty();
                    newWeight.weight = _weightValue;
                    newWeight.dateTime = DateTime.now();

                    // todo: implement some input validation for weight
                    await dbHelper.insertWeight(newWeight);
                    // initState(); todo: for when you implement pulling all weights

                    setState(() {
                      // set the text that shows the last recorded weight
                      _weightValue = double.tryParse(_weightTextFieldController.text) ?? 00.00;
                    });
                    _weightTextFieldController.clear();
                    // todo: remove debugging lines
                    Future<List<Weight>> weightListFuture = dbHelper.getAllWeights();
                    List<Weight> weightList = await weightListFuture;
                    print('printing:==========');
                    for (Weight item in weightList) {
                      print(item.weight);
                    }
                    if (context.mounted) Navigator.pop(context);
                  })
            ],
          );
        });
  }

  Future<List<FlSpot>> getWeightSpots() async {
    List<Weight> allWeights = await DatabaseHelper().getAllWeights();

    // Create FlSpot instances from Weight objects
    List<FlSpot> spots = allWeights.map((weight) {
      return FlSpot(weight.dateTime.millisecondsSinceEpoch.toDouble(), weight.weight);
      // todo: figure out how to turn dateTime back to show on chart or how to deal with it
    }).toList();

    return spots;
  }

  // @override
  // void initState() {
  //   super.initState();
  //   allWeights = getAllWeights();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        labelBehavior: labelBehavior,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: 'Chart',
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: <Widget>[
        // home page
        Card(
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Last recorded weight is',
                ),
                Text(
                  '$_weightValue',
                  style: Theme.of(context).textTheme.headlineMedium,
                )
              ],
            ),
          ),
        ),
        // charts page
        Card(
          margin: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<FlSpot>>(
              future: getWeightSpots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // todo: implement error logging
                  print(snapshot.error);
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<FlSpot> weightSpots = snapshot.data ?? [];
                  // todo: remove debugging
                  print('========');
                  for (FlSpot item in weightSpots) {
                    print(item.toString());
                  }
                  return LineChart(
                    LineChartData(
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
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
                        ]),
                  );
                }
              }),
        ),
      ][currentPageIndex],
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        child: const Icon(Icons.add),
        onPressed: () {
          _displayAddWeightDialog(context);
        },
      ),
    );
  }
}
