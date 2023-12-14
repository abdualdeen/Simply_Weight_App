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
    return MaterialApp(
      title: 'Simple Weight Tracking',
      theme: ThemeData(
        useMaterial3: true,
      ),
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
  late Future<Weight> weight;
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
                    Weight weight = Weight.empty();
                    weight.weight = _weightValue;
                    weight.dateTime = DateTime.now();

                    await dbHelper.insertWeight(weight);
                    initState();

                    setState(() {
                      // set the text that shows the last recorded weight
                      _weightValue = double.tryParse(_weightTextFieldController.text) ?? 00.00;
                    });
                    _weightTextFieldController.clear();
                    print(dbHelper.getAllWeights());
                    if (context.mounted) Navigator.pop(context);
                  })
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
        ],
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Card(
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
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        child: const Icon(Icons.add),
        onPressed: () {
          _displayAddWeightDialog(context);
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
