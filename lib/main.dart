import 'package:flutter/material.dart';
import 'screens/welcome_screen.dart';

void main() {
  runApp(const RiceDiseaseApp());
}

class RiceDiseaseApp extends StatelessWidget {
  const RiceDiseaseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rice Disease Detector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32), // Forest Green
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: const WelcomeScreen(),
    );
  }
} 