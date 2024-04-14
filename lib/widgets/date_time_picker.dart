import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weight_app/constants.dart';

class DateTimePicker extends StatefulWidget {
  final Function(DateTime)? onDateTimeChanged;
  DateTime? dateTime;
  DateTimePicker({Key? key, required this.dateTime, required this.onDateTimeChanged}) : super(key: key);

  @override
  State<DateTimePicker> createState() => _DateTimePickerState();
}

class _DateTimePickerState extends State<DateTimePicker> {
  DateFormat dateFormat = DateFormat(Constants.DATE_TIME_FORMAT);

  Future<DateTime?> pickDateTime(BuildContext context, DateTime dateTime) async {
    DateTime? newDateTime;
    DateTime? date = await showDatePicker(context: context, initialDate: dateTime, firstDate: DateTime(1900), lastDate: DateTime(2100));
    // if no date is selected, return the passed in dateTime.
    if (date == null) {
      widget.onDateTimeChanged?.call(dateTime);
      return dateTime;
    }

    TimeOfDay? time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(dateTime)); // todo: fix dont use context across async gaps
    // if no time is selected then just return the date picked and the time from the passed in dateTime.
    if (time == null) {
      newDateTime = DateTime(date.year, date.month, date.day, dateTime.hour, dateTime.minute);
      widget.onDateTimeChanged?.call(newDateTime);
      return newDateTime;
    }

    newDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    widget.onDateTimeChanged?.call(newDateTime);
    return newDateTime;
  }

  @override
  Widget build(BuildContext context) {
    DateTime? newDateTime = widget.dateTime;
    return ElevatedButton.icon(
      icon: const Icon(Icons.edit_calendar),
      label: Text(dateFormat.format(newDateTime!)),
      onPressed: () async {
        newDateTime = await pickDateTime(context, newDateTime!);
        setState(() {
          if (newDateTime == null) return; // no new date time is selected.
          widget.dateTime = newDateTime; // set the new datetime so the widget updates.
        });
      },
    );
  }
}
