import 'package:flutter/material.dart';
import 'package:simply_weight/constants.dart';
import 'package:url_launcher/url_launcher.dart';

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

Future<void> displayAboutDialog(BuildContext context) async {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About'),
          content: Container(
            height: 300,
            width: 200,
            child: ListView(
              children: [
                ListTile(
                  title: const Text('Source Code'),
                  subtitle: const Text('Available on Github'),
                  onTap: () {
                    launchUrl(Uri.parse(Constants.SOURCE_URL));
                  },
                ),
                ListTile(
                  title: const Text('License'),
                  subtitle: const Text('GPLv3'),
                  onTap: () {
                    launchUrl(Uri.parse('https://www.gnu.org/licenses/gpl-3.0.en.html'));
                  },
                ),
                ListTile(
                  title: const Text('Version'),
                  subtitle: const Text('0.8.0'),
                ),
                ListTile(
                  title: const Text('Author'),
                  subtitle: const Text('Abdullah Aldeen'),
                ),
              ],
            ),
          ),
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
