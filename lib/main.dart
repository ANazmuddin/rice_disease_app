import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}