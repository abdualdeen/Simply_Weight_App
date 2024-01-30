import 'package:flutter/material.dart';

enum Calendar { week, month, year, all }

class CalendarSegementedButton extends StatefulWidget {
  const CalendarSegementedButton({super.key});

  @override
  State<CalendarSegementedButton> createState() => _CalendarSegementedButtonState();
}

class _CalendarSegementedButtonState extends State<CalendarSegementedButton> {
  Calendar _selectedCalendar = Calendar.week;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Calendar>(
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
    );
  }
}
