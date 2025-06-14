import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/splash_screen.dart';

void main() {
  runApp(BankApp());
}

class BankApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: SplashScreen(), // <-- Start with the splash screen
    );
  }
}
