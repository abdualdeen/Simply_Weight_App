import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_app/constants.dart';
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
        color: Colors.green,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.light,
      ),
    );

    ThemeData darkTheme = ThemeData(
      appBarTheme: const AppBarTheme(
        color: Colors.green,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
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
  late Future<List<Weight>> allWeights;
  DatabaseHelper dbHelper = DatabaseHelper();
  double _weightValue = 0;
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
                    print('Here is the weight value from the controller: ');
                    print(_weightTextFieldController.text);
                    double newWeightValue = double.tryParse(_weightTextFieldController.text) ?? 0.0;
                    // save information to local database
                    Weight newWeight = Weight.empty();
                    newWeight.weight = newWeightValue;
                    newWeight.dateTime = DateTime.now();

                    // todo: implement some input validation for weight
                    await dbHelper.insertWeight(newWeight);

                    setState(() {
                      // set the text that shows the last recorded weight
                      _weightValue = newWeightValue;
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

  Future<void> _displayAboutDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('About'),
            content: const Text('Made by Abdullah Aldeen'),
            actions: [
              MaterialButton(
                  child: const Text('Ok'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  Future<List<FlSpot>> getWeightSpots() async {
    List<Weight> allWeights = await dbHelper.getAllWeights();

    // Create FlSpot instances from Weight objects
    List<FlSpot> spots = allWeights.map((weight) {
      return FlSpot(weight.dateTime.millisecondsSinceEpoch.toDouble(), weight.weight);
    }).toList();

    return spots;
  }

  Future<ListView> getHistoryListView() async {
    List<Weight> allWeights = await dbHelper.getAllWeights();
    DateFormat dateFormat = DateFormat(Constants.DATE_TIME_FORMAT);

    // Create ListTile instances from Weight objects
    List<ListTile> listTiles = allWeights.reversed.map((weight) {
      Widget titleText = Text(weight.weight.toString());
      Widget subtitleText = Text(dateFormat.format(weight.dateTime));

      return ListTile(
        title: titleText,
        subtitle: subtitleText,
      );
    }).toList();

    // Create ListView to be returned
    ListView listView = ListView(
      children: listTiles,
    );

    return listView;
  }

  Future<Column> getHomePage() async {
    List<Weight> lastWeight = await dbHelper.getAllWeights();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Your last recorded weigth is',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          lastWeight.first.weight.toString(),
          style: Theme.of(context).textTheme.headlineMedium,
        )
      ],
    );
  }

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
          NavigationDestination(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(value: 0, child: Text('About')),
              ];
            },
            onSelected: (value) {
              if (value == 0) {
                _displayAboutDialog(context);
              }
            },
          ),
        ],
      ),
      body: <Widget>[
        // home page
        Card(
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: FutureBuilder<Column>(
              future: getHomePage(),
              builder: (context, AsyncSnapshot<Column> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // todo: implement error logging
                  // print(snapshot.error);
                  return Text('Error: ${snapshot.error}');
                } else {
                  return snapshot.data ?? Container();
                }
              },
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
                // print(snapshot.error);
                return Text('Error: ${snapshot.error}');
              } else {
                List<FlSpot> weightSpots = snapshot.data ?? [];
                // todo: remove debugging
                // print('========');
                // for (FlSpot item in weightSpots) {
                //   print(item.toString());
                // }
                return LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
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
            },
          ),
        ),
        // history page
        Card(
          margin: const EdgeInsets.all(8.0),
          child: FutureBuilder<ListView>(
            future: getHistoryListView(),
            builder: (context, AsyncSnapshot<ListView> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // todo: implement error logging
                // print(snapshot.error);
                return Text('Error: ${snapshot.error}');
              } else {
                return snapshot.data ?? Container();
              }
            },
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
