import 'package:flutter/material.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> disease;

  const DiseaseDetailScreen({super.key, required this.disease});

  @override
  Widget build(BuildContext context) {
    // Mengonversi kode warna dari string ke Color
    final Color themeColor = Color(int.parse(disease['color']));
    
    // Menentukan warna teks agar kontras dengan background
    final Color textColor = themeColor == const Color(0xFFE8F5E9) 
        ? const Color(0xFF1B5E20) // Teks Hijau Tua untuk Blast
        : themeColor == const Color(0xFFFFF3E0)
            ? const Color(0xFFE65100) // Teks Oranye Tua untuk Brown Spot
            : const Color(0xFFB71C1C); // Teks Merah Tua untuk HDB

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: textColor,
        elevation: 0,
        title: const Text('Detail Penyakit', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header melengkung dengan warna dinamis
            Container(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40, top: 10),
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      disease['pathogen'], 
                      style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontStyle: FontStyle.italic)
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    disease['title'], 
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: textColor, height: 1.2)
                  ),
                ],
              ),
            ),
            
            // Kartu-kartu Konten
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildInfoCard('Deskripsi', disease['desc'], Icons.description_outlined),
                  const SizedBox(height: 16),
                  _buildInfoCard('Gejala Klinis', disease['symptoms'], Icons.warning_amber_rounded),
                  const SizedBox(height: 16),
                  _buildInfoCard('Rekomendasi Penanganan', disease['treatment'], Icons.medical_services_outlined),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2E7D32), size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
            ],
          ),
          const Divider(height: 30),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.6),
          ),
        ],
      ),
    );
  }
}