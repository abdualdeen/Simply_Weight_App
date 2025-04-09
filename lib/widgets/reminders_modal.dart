import 'package:flutter/material.dart';
import 'package:simply_weight/constants.dart';
import '../preferences.dart';

class RemindersModal extends StatefulWidget {
  bool reminderSwitchValue;
  RemindersModal({Key? key, required this.reminderSwitchValue}) : super(key: key);

  @override
  State<RemindersModal> createState() => _RemindersModalState();
}

class _RemindersModalState extends State<RemindersModal> {
  bool isSwitched = false;

  @override
  void initState() {
    isSwitched = widget.reminderSwitchValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        SwitchListTile(
          title: const Text('Reminder'),
          value: isSwitched,
          onChanged: (value) {
            setState(() {
              // _onSwitchChanged(value);
              isSwitched = value;
              savePreference(Constants.REMINDERS_STATE, isSwitched);
            });
          },
        )
      ],
    ));
  }
}
