import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // File ini di-generate otomatis oleh flutterfire
import 'screens/welcome_screen.dart'; // Biarkan welcome screen tetap ada
import 'screens/main_layout.dart'; // Kita akan buat ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RiceDiseaseApp());
}

class RiceDiseaseApp extends StatelessWidget {
  const RiceDiseaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rice Disease Detector',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto', // Atau font pilihanmu
      ),
      debugShowCheckedModeBanner: false,
      // Sementara kita arahkan langsung ke MainLayout untuk testing UI baru
      home: const MainLayout(), 
    );
  }
}