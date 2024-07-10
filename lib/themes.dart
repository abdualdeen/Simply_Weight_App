import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  appBarTheme: AppBarTheme(
    color: Colors.green[900]!,
    iconTheme: const IconThemeData(color: Colors.black),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green[900]!,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
);

ThemeData darkTheme = ThemeData(
  appBarTheme: AppBarTheme(
    color: Colors.green[900]!,
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.green[900]!,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
