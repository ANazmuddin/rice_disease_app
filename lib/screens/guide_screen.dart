import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Panduan Penggunaan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1B5E20),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Panduan
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cara Memindai Presisi', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('Kuasai seni mengambil foto daun yang benar untuk hasil deteksi AI dengan akurasi maksimal.', 
                    style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            const Text('Langkah - Langkah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
            const SizedBox(height: 16),

            // Daftar Langkah
            _buildStepCard(
              number: '1',
              title: 'Pilih Daun yang Jelas',
              desc: 'Pilih satu helai daun padi yang menunjukkan gejala penyakit (bercak/kering). Pastikan tidak tertutup oleh daun lain.',
              icon: Icons.filter_center_focus,
            ),
            _buildStepCard(
              number: '2',
              title: 'Hindari Bayangan Gelap',
              desc: 'Pastikan pencahayaan merata. Bayangan tajam atau pantulan cahaya matahari langsung dapat membingungkan sistem AI.',
              icon: Icons.wb_sunny_outlined,
            ),
            _buildStepCard(
              number: '3',
              title: 'Jaga Jarak 10-15 cm',
              desc: 'Posisikan kamera HP sekitar 10 hingga 15 sentimeter dari permukaan daun agar fokus lensa menjadi optimal.',
              icon: Icons.straighten,
            ),
            _buildStepCard(
              number: '4',
              title: 'Tahan Posisi Kamera',
              desc: 'Saat memencet tombol ambil gambar, tahan tangan agar tidak bergetar (blur). Gambar blur akan menurunkan akurasi.',
              icon: Icons.camera_alt_outlined,
            ),
            
            const SizedBox(height: 20),
            
            // Tips Pro
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFDE7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Pro Tips', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('• Bersihkan lensa kamera HP Anda sebelum memindai.\n• Jika cuaca sangat terik, gunakan tubuh Anda untuk menutupi daun agar cahayanya menjadi redup merata (soft shade).', 
                    style: TextStyle(height: 1.6, color: Colors.black87)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard({required String number, required String title, required String desc, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE8F5E9),
            foregroundColor: const Color(0xFF2E7D32),
            radius: 16,
            child: Text(number, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E20))),
                    Icon(icon, size: 20, color: Colors.grey[400]),
                  ],
                ),
                const SizedBox(height: 8),
                Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5)),
              ],
            ),
          )
        ],
      ),
    );
  }
}