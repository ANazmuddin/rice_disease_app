import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  Map<String, dynamic>? _predictionResult;

  final ImagePicker _picker = ImagePicker();

  // Fungsi untuk mengambil gambar dari Kamera atau Galeri
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _predictionResult = null; // Reset hasil sebelumnya jika ada
      });
      
      // Langsung eksekusi analisis setelah gambar dipilih
      _analyzeImage();
    }
  }

  // Fungsi untuk mengirim gambar ke Backend API
  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.predictDisease(_selectedImage!);
      setState(() {
        _predictionResult = result;
        _isLoading = false;
      });
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
      appBar: AppBar(
        title: const Text('Rice Disease AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Area Penampil Gambar Asli
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : const Center(
                      child: Text('Belum ada daun yang difoto',
                          style: TextStyle(color: Colors.grey, fontSize: 16))),
            ),
            const SizedBox(height: 20),

            // 2. Tombol Aksi (Kamera & Galeri)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Kamera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeri'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    foregroundColor: Colors.green[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 3. Indikator Loading
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 15),
                    Text('AI sedang menganalisis pola bercak daun...',
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),

            // 4. Area Hasil Prediksi & Visualisasi Grad-CAM
            if (_predictionResult != null && !_isLoading) ...[
              const Divider(thickness: 2),
              const SizedBox(height: 15),
              
              Text(
                'Diagnosis: ${_predictionResult!['data']['disease'].toString().toUpperCase()}',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              Text(
                'Tingkat Keyakinan: ${_predictionResult!['data']['confidence']}%',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Bagian Paling Krusial: Render Base64 menjadi Gambar Asli
              const Text(
                'Peta Analisis AI (Grad-CAM):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  // base64Decode mengubah teks string menjadi byte gambar visual
                  base64Decode(_predictionResult!['data']['gradcam_image'].split(',').last),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Rekomendasi Penanganan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.health_and_safety, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Rekomendasi Pakar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const Divider(color: Colors.orange),
                    const SizedBox(height: 8),
                    Text(
                      _predictionResult!['data']['recommendation'],
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}