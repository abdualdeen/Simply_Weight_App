import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simply_weight/charts_page.dart';
import 'package:simply_weight/constants.dart';
import 'package:simply_weight/database_helpers.dart';
import 'package:simply_weight/logging.dart';
import 'package:simply_weight/themes.dart';
import 'package:simply_weight/weight_model.dart';
import 'package:simply_weight/widgets/date_time_picker.dart';
import 'package:simply_weight/widgets/dialogs.dart';

void main() {
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(channelKey: 'weight_channel', channelName: 'Simply Weight', channelDescription: 'Weight Notifications'),
    ],
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simply Weight',
      theme: lightTheme, // todo: fix light theme text and green color being too dark.
      darkTheme: darkTheme,
      home: const MyHomePage(title: 'Simply Weight'),
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
  @override
  void initState() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    super.initState();
  }

  final appLog = appLogger;
  bool deleteWeight = false;
  int _currentPageIndex = 0;
  late Future<List<Weight>> allWeights;
  DatabaseHelper dbHelper = DatabaseHelper();
  NavigationDestinationLabelBehavior labelBehavior = NavigationDestinationLabelBehavior.onlyShowSelected;
  final TextEditingController _weightTextFieldController = TextEditingController();
  DateFormat dateFormat = DateFormat(Constants.DATE_TIME_FORMAT);

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
    DateTime selectedDateTime = weight.dateTime;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Edit weight'),
            content: IntrinsicHeight(
              child: Column(
                children: [
                  TextField(
                    controller: weightEditTextController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Weight'),
                  ),
                  SizedBox(height: 5),
                  DateTimePicker(
                    dateTime: selectedDateTime,
                    onDateTimeChanged: (newDateTime) {
                      selectedDateTime = newDateTime;
                    },
                  )
                ],
              ),
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
                        // todo: maybe add more input validation
                        double editedWeightValue = double.tryParse(weightEditTextController.text) ?? 0.0;
                        if (editedWeightValue <= 0) {
                          displayErrorDialog(context, 'Invalid Input: $editedWeightValue');
                        } else {
                          // save information to local database
                          Weight editedWeight = Weight.empty();
                          editedWeight.id = weight.id;
                          editedWeight.weight = editedWeightValue;
                          editedWeight.dateTime = selectedDateTime;
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

  Future<dynamic> _readSavedPreference(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final bool value = preferences.getBool(key) ?? false;
    print(value);
    return value;
  }

  Future<void> _savePreference(String key, bool value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(key, value);
  }

  Future<void> displayReminderPopup(BuildContext context, bool remindersSwicthValue) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            children: [
              SwitchListTile(
                title: const Text('Reminders'),
                value: remindersSwicthValue,
                onChanged: (value) {
                  print(value);
                  setState(() {
                    remindersSwicthValue = value;
                  });
                },
              ),
            ],
          );
        });
  }

  Future<dynamic> getHistoryPage() async {
    List<Weight> allWeights = await dbHelper.getAllWeights();
    if (allWeights.isEmpty) {
      return const Center(child: Text('No recorded data yet.'));
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
    bool remindersSwicthValue = false;
    if (lastWeight.isEmpty) {
      return const Center(child: Text("No recorded data yet. \nTo start, click the '+' Button below to add your weight!"));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
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
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {
                displayReminderPopup(context, remindersSwicthValue);
              },
              label: const Text('Set Reminder'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.sports_score),
              onPressed: () {},
              label: const Text('Set Goal'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _displayAddWeightDialog(BuildContext context) async {
    DateTime selectedDateTime = DateTime.now();

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Add weight'),
            content: IntrinsicHeight(
              child: Column(
                children: [
                  TextField(
                    controller: _weightTextFieldController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Weight'),
                  ),
                  SizedBox(height: 5),
                  DateTimePicker(
                    dateTime: selectedDateTime,
                    onDateTimeChanged: (newDateTime) {
                      selectedDateTime = newDateTime;
                    },
                  )
                ],
              ),
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
                    // todo: check if input validation is robust.
                    double newWeightValue = double.tryParse(_weightTextFieldController.text) ?? 0.0;
                    if (newWeightValue <= 0) {
                      displayErrorDialog(context, 'Invalid Input: $newWeightValue');
                    } else {
                      // save information to local database
                      Weight newWeight = Weight.empty();
                      newWeight.weight = newWeightValue;
                      newWeight.dateTime = selectedDateTime;

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
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        destinations: const [
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
      body: [
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
        const Card(
          margin: EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: ChartsPage(),
          ),
        ),
        // history page
        Card(
          margin: const EdgeInsets.all(8.0),
          child: FutureBuilder<dynamic>(
            future: getHistoryPage(),
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
      ][_currentPageIndex],
      floatingActionButton: _currentPageIndex != 1 // the use of _currentPageIndex here in the ternary is to hide the button on the chart page.
          ? FloatingActionButton(
              tooltip: 'Add',
              child: const Icon(Icons.add),
              onPressed: () {
                _displayAddWeightDialog(context);
                // todo: clean, the function below is used for testing to fill test data.
                // dbHelper.fillDbForTesting();
              },
            )
          : null,
    );
  }
}
