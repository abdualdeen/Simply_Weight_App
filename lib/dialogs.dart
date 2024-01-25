import 'package:flutter/material.dart';

Future<void> displayErrorDialog(BuildContext context, String message) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Input Error'),
          content: Text(message),
          actions: [
            MaterialButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.pop(context);
                })
          ],
        );
      });
}
