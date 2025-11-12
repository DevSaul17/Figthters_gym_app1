import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'constants.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTexts.appTitle,
      theme: ThemeData(primarySwatch: Colors.red, fontFamily: 'Arial'),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
