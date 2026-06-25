import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'result_screen.dart'; // Kita akan buat file ini setelah ini

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _processImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      File imageFile = File(pickedFile.path);
      // Mengirim ke API FastAPI
      final result = await ApiService.predictDisease(imageFile);
      
      setState(() {
        _isLoading = false;
      });

      // Pindah ke halaman hasil dengan membawa data
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              imageFile: imageFile,
              predictionData: result['data'],
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Tema gelap untuk layar scan
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF43A047)),
                  SizedBox(height: 20),
                  Text('AI sedang menganalisis pola penyakit...', 
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.document_scanner_outlined, size: 100, color: Colors.white54),
                  const SizedBox(height: 30),
                  const Text('Posisikan daun padi di dalam bingkai', 
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildScanButton(Icons.photo_library, 'Galeri', () => _processImage(ImageSource.gallery)),
                      const SizedBox(width: 40),
                      _buildScanButton(Icons.camera, 'Ambil Foto', () => _processImage(ImageSource.camera), isPrimary: true),
                    ],
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildScanButton(IconData icon, String label, VoidCallback onTap, {bool isPrimary = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isPrimary ? 24 : 16),
            decoration: BoxDecoration(
              color: isPrimary ? Colors.white : Colors.white24,
              shape: BoxShape.circle,
              border: isPrimary ? Border.all(color: const Color(0xFF43A047), width: 4) : null,
            ),
            child: Icon(icon, size: 36, color: isPrimary ? Colors.black87 : Colors.white),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}