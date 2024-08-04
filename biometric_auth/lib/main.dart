import 'package:flutter/material.dart';
import 'biometric_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Biometric Authentication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BiometricAuth(),
    );
  }
}
