import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_app/constants.dart';
import 'package:weight_app/database_helpers.dart';
import 'package:weight_app/dialogs.dart';
import 'package:weight_app/logging.dart';
import 'package:weight_app/themes.dart';
import 'package:weight_app/weight_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
  final appLog = appLogger;
  bool deleteWeight = false;
  int currentPageIndex = 0;
  late Future<List<Weight>> allWeights;
  DatabaseHelper dbHelper = DatabaseHelper();
  NavigationDestinationLabelBehavior labelBehavior = NavigationDestinationLabelBehavior.onlyShowSelected;
  final TextEditingController _weightTextFieldController = TextEditingController();

  Future<List<FlSpot>> getWeightSpots() async {
    List<Weight> allWeights = await dbHelper.getAllWeights();

    // Create FlSpot instances from Weight objects
    List<FlSpot> spots = allWeights.map((weight) {
      return FlSpot(weight.dateTime.millisecondsSinceEpoch.toDouble(), weight.weight);
    }).toList();

    return spots;
  }

  Future<dynamic> _displayDeleteWeightDialog(BuildContext context, int weightId) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Are you sure you want to delete?'),
            actions: [
              MaterialButton(
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    // todo: handle error? in case it doesn't delete.
                    await dbHelper.deleteWeight(weightId);
                    deleteWeight = true;
                    if (context.mounted) Navigator.pop(context);
                  }),
              MaterialButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    if (context.mounted) Navigator.pop(context);
                  }),
            ],
          );
        });
  }

  Future<void> _displayEditWeightDialog(BuildContext context, Weight weight) async {
    TextEditingController weightEditTextController = TextEditingController(text: weight.weight.toString());
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit weight'),
            content: TextField(
              controller: weightEditTextController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Weight'),
            ),
            actions: [
              Row(
                children: [
                  MaterialButton(
                      child: const Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () async {
                        await _displayDeleteWeightDialog(context, weight.id);
                        if (deleteWeight) {
                          if (context.mounted) Navigator.pop(context);
                          setState(() {});
                          deleteWeight = false;
                        }
                      }),
                  MaterialButton(
                      child: const Text('Cancel'),
                      onPressed: () {
                        if (context.mounted) Navigator.pop(context);
                      }),
                  MaterialButton(
                      child: const Text(
                        'Save',
                        style: TextStyle(color: Colors.green),
                      ),
                      onPressed: () async {
                        // todo: implement some input validation for weight
                        double editedWeightValue = double.tryParse(weightEditTextController.text) ?? 0.0;
                        if (editedWeightValue <= 0) {
                          displayErrorDialog(context, 'Invalid Input: $editedWeightValue');
                        } else {
                          // save information to local database
                          Weight editedWeight = Weight.empty();
                          editedWeight.id = weight.id;
                          editedWeight.weight = editedWeightValue;
                          editedWeight.dateTime = weight.dateTime;
                          await dbHelper.updateWeight(editedWeight);

                          weightEditTextController.clear();
                          setState(() {}); // invoke this function to update the homepage and latest weight.
                          if (context.mounted) Navigator.pop(context);
                        }
                      }),
                ],
              )
            ],
          );
        });
  }

  Future<dynamic> getHistoryListView() async {
    List<Weight> allWeights = await dbHelper.getAllWeights();
    if (allWeights.isEmpty) {
      return const Text('No recorded weights yet.');
    }
    DateFormat dateFormat = DateFormat(Constants.DATE_TIME_FORMAT);

    // Create ListTile instances from Weight objects
    List<ListTile> listTiles = allWeights.reversed.map((weight) {
      Widget titleText = Text(weight.weight.toString());
      Widget subtitleText = Text(dateFormat.format(weight.dateTime));

      return ListTile(
        title: titleText,
        subtitle: subtitleText,
        key: Key(weight.id.toString()), // ListTile has key which only takes strings. So a jankey solution but what can you do.
        onTap: () {
          _displayEditWeightDialog(context, weight);
        },
      );
    }).toList();

    // Create ListView to be returned
    ListView listView = ListView(
      children: listTiles,
    );

    return listView;
  }

  Future<dynamic> getHomePage() async {
    List<Weight> lastWeight = await dbHelper.getLastWeight();
    if (lastWeight.isEmpty) {
      return const Text('No recorded weight yet.');
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Your last recorded weigth is',
          style: Theme.of(context).textTheme.headlineSmall, // todo: check buildcontext async gaps issue
        ),
        Text(
          lastWeight.first.weight.toString(),
          style: Theme.of(context).textTheme.headlineMedium, // todo: check buildcontext async gaps issue
        )
      ],
    );
  }

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
                    // todo: implement some input validation for weight
                    double newWeightValue = double.tryParse(_weightTextFieldController.text) ?? 0.0;
                    if (newWeightValue <= 0) {
                      // todo: add error dialog.
                      displayErrorDialog(context, 'Invalid Input: $newWeightValue');
                    } else {
                      // save information to local database
                      Weight newWeight = Weight.empty();
                      newWeight.weight = newWeightValue;
                      newWeight.dateTime = DateTime.now();

                      await dbHelper.insertWeight(newWeight);
                      _weightTextFieldController.clear();

                      setState(() {}); // invoke this function to update the homepage and latest weight.
                      if (context.mounted) Navigator.pop(context);
                    }
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
            child: FutureBuilder<dynamic>(
              future: getHomePage(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  appLog.d(snapshot.error);
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
                appLog.d(snapshot.error);
                return Text('Error: ${snapshot.error}');
              } else {
                List<FlSpot> weightSpots = snapshot.data ?? [];
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
          child: FutureBuilder<dynamic>(
            future: getHistoryListView(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                appLog.d(snapshot.error);
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
