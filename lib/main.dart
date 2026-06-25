import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import halaman
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_layout.dart';

void main() async {
  // Wajib dipanggil sebelum inisialisasi Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Firebase menggunakan konfigurasi yang digenerate oleh FlutterFire CLI
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
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      
      // StreamBuilder memantau perubahan status autentikasi secara real-time
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Saat sistem sedang memuat status
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
              ),
            );
          }
          
          // Jika ada data user (berarti sesi login masih aktif)
          if (snapshot.hasData) {
            return const MainLayout();
          }
          
          // Jika tidak ada data user (belum login atau sudah logout)
          // Secara opsional Anda bisa mengarahkannya ke WelcomeScreen terlebih dahulu 
          // atau langsung ke LoginScreen. Di sini kita arahkan ke LoginScreen.
          return const LoginScreen(); 
        },
      ),
    );
  }
}