import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class ResultScreen extends StatelessWidget {
  final File imageFile;
  final Map<String, dynamic> predictionData;

  const ResultScreen({super.key, required this.imageFile, required this.predictionData});

  // Fungsi pembantu untuk memunculkan teks gejala spesifik berdasarkan nama penyakit
  String _getGejala(String disease) {
    if (disease.toLowerCase() == 'blast') {
      return 'Terdapat bercak berbentuk belah ketupat dengan ujung runcing, pusat bercak berwarna abu-abu atau keputihan dengan tepi coklat kemerahan.';
    } else if (disease.toLowerCase() == 'brown_spot') {
      return 'Terdapat bercak coklat berbentuk oval atau melingkar pada daun. Pada infeksi berat, bercak menyatu dan menyebabkan daun mengering.';
    } else {
      return 'Terdapat bercak abu-abu kehijauan di sepanjang tepi daun yang mulai mengering dan berubah menjadi kuning keputihan.';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ekstraksi data dari Map JSON
    final String diseaseName = predictionData['disease'].toString().toUpperCase().replaceAll('_', ' ');
    final double confidence = predictionData['confidence'];
    final String recommendation = predictionData['recommendation'];
    final String gradCamBase64 = predictionData['gradcam_image'].toString().split(',').last;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        title: const Text('Analysis Result', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Gambar XAI (Grad-CAM)
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  // Decode teks Base64 panjang menjadi byte gambar visual
                  image: MemoryImage(base64Decode(gradCamBase64)),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber, 
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: const Text(
                        'AI Analyzed', 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            // 2. Konten Hasil Diagnosis
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  // Kartu Utama: Nama Penyakit & Confidence
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diseaseName, 
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Confidence Level', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                            Text('$confidence%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF1B5E20))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: confidence / 100,
                          backgroundColor: Colors.grey[200],
                          color: const Color(0xFF1B5E20),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kartu Detail Gejala
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Gejala Terdeteksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _getGejala(predictionData['disease']), 
                          style: const TextStyle(height: 1.5, color: Colors.black87)
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Kartu Rekomendasi Medis
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Rekomendasi Penanganan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFFC8E6C9), 
                              radius: 16, 
                              child: Icon(Icons.check, color: Color(0xFF2E7D32), size: 20)
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                recommendation, 
                                style: const TextStyle(height: 1.5, color: Colors.black87)
                              )
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Tombol Aksi: Simpan ke Riwayat Firebase
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Tembak data ke Firestore
                        await FirebaseService.saveHistory(
                          disease: predictionData['disease'],
                          confidence: predictionData['confidence'],
                          base64Image: gradCamBase64,
                        );
                        
                        // Notifikasi sukses
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Berhasil disimpan ke Riwayat!'),
                              backgroundColor: Color(0xFF2E7D32),
                            )
                          );
                        }
                      } catch (e) {
                        // Notifikasi gagal
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal menyimpan: $e'),
                              backgroundColor: Colors.red,
                            )
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Simpan ke Riwayat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  
                  // Tombol Aksi: Pindai Ulang
                  OutlinedButton(
                    onPressed: () {
                      // Tutup layar hasil dan kembali ke layar kamera (ScanScreen)
                      Navigator.pop(context); 
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Pindai Ulang', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 16)),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}