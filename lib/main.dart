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

                    await dbHelper.insertWeight(newWeight);
                    // initState(); todo: for when you implement pulling all weights

                    setState(() {
                      // set the text that shows the last recorded weight
                      _weightValue = double.tryParse(_weightTextFieldController.text) ?? 00.00;
                    });
                    _weightTextFieldController.clear();
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

  Future<List<Weight>> getAllWeights() async {
    return await DatabaseHelper().getAllWeights();
  }

  Future<List<FlSpot>> getWeightSpots() async {
    List<Weight> allWeights = await getAllWeights();

    // Create FlSpot instances from Weight objects
    List<FlSpot> spots = allWeights.map((weight) {
      // Assuming Weight has properties x (representing the x-axis value) and y (representing the y-axis value)
      return FlSpot(weight.dateTime, weight.weight);
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
          child: LineChart(
            LineChartData(borderData: FlBorderData(show: false), lineBarsData: [
              LineChartBarData(spots: [for (Weight weightPoint in allWeights) {}]),
            ]),
          ),
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

// todo: implement getting all weights to show graph
