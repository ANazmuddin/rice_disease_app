import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final weather = await WeatherService.getCurrentWeather();
    if (mounted) {
      setState(() {
        _weatherData = weather;
        _isLoadingWeather = false;
      });
    }
  }

  // Fungsi ekstraktor nama dari Firebase Auth
  String _getUserGreeting() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'Petani';

    // 1. Jika suatu saat menggunakan Login Google dan memiliki Display Name
    if (user.displayName != null && user.displayName!.isNotEmpty) {
      return user.displayName!;
    }

    // 2. Jika menggunakan Email biasa, potong teks sebelum '@'
    final email = user.email;
    if (email != null && email.contains('@')) {
      String username = email.split('@')[0];
      // Mengubah huruf pertama menjadi kapital (contoh: "joko99" -> "Joko99")
      return username[0].toUpperCase() + username.substring(1);
    }

    return 'Petani';
  }

  // Data statis untuk Ensiklopedia Penyakit
  final List<Map<String, String>> _diseases = [
    {
      'title': 'Blast (Pirikularia)',
      'desc': 'Penyakit jamur yang menyerang daun, ditandai dengan bercak belah ketupat memanjang.',
      'color': '0xFFE8F5E9' // Hijau sangat muda
    },
    {
      'title': 'Brown Spot',
      'desc': 'Bercak coklat oval pada daun akibat jamur, sering terjadi di lahan dengan nutrisi tanah rendah.',
      'color': '0xFFFFF3E0' // Oranye muda
    },
    {
      'title': 'Hawar Daun Bakteri',
      'desc': 'Infeksi bakteri (Kresek) yang membuat daun menguning dan layu mulai dari ujung hingga pangkal.',
      'color': '0xFFFFEBEE' // Merah muda pudar
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Sapaan Dinamis
            Text(
              'Halo, ${_getUserGreeting()}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 4),
            Text(
              'Kesehatan padi Anda terlihat optimal hari ini.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Kartu Cuaca Cerdas
            _buildWeatherCard(),
            const SizedBox(height: 24),

            // Tombol CTA (Call to Action) Mulai Deteksi
            _buildScanCTA(),
            const SizedBox(height: 28),

            // Bagian Ensiklopedia Penyakit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ensiklopedia Penyakit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF2E7D32))),
                )
              ],
            ),
            const SizedBox(height: 12),
            _buildEncyclopediaList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (_isLoadingWeather) {
      return Container(
        height: 140,
        decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(20)),
        child: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final temp = _weatherData?['temperature'] ?? '--';
    final code = _weatherData?['weathercode'] ?? 0;
    final condition = WeatherService.getWeatherCondition(code);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.green.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cuaca Lokasi Anda', style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(condition['icon'], style: const TextStyle(fontSize: 32)),
            ],
          ),
          const SizedBox(height: 8),
          Text('$temp°C', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(condition['text'], style: const TextStyle(color: Colors.white, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildScanCTA() {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan tekan tab "Scan" di menu bawah untuk memindai.')),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF43A047), Color(0xFF1B5E20)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.camera_alt_rounded, color: Colors.white, size: 40),
            SizedBox(height: 12),
            Text('Mulai Deteksi', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text('Arahkan kamera ke daun padi untuk diagnosa', style: TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildEncyclopediaList() {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _diseases.length,
        itemBuilder: (context, index) {
          final disease = _diseases[index];
          return Container(
            width: 260,
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(int.parse(disease['color']!)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('PENYAKIT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54, letterSpacing: 0.5)),
                ),
                const SizedBox(height: 16),
                Text(disease['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                const SizedBox(height: 8),
                Text(
                  disease['desc']!, 
                  style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4), 
                  maxLines: 3, 
                  overflow: TextOverflow.ellipsis
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}