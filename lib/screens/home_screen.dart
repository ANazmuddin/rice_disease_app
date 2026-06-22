import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../services/weather_service.dart';

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
  
  // State untuk Cuaca
  Map<String, dynamic>? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather(); // Muat cuaca saat layar dibuka
  }

  Future<void> _loadWeather() async {
    final weather = await WeatherService.getCurrentWeather();
    setState(() {
      _weatherData = weather;
      _isLoadingWeather = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _predictionResult = null;
      });
      _analyzeImage();
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    setState(() { _isLoading = true; });
    try {
      final result = await ApiService.predictDisease(_selectedImage!);
      setState(() {
        _predictionResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() { _isLoading = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // --- FITUR BARU: BOTTOM SHEET PANDUAN ---
  void _showGuidelines() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF2E7D32), size: 28),
                SizedBox(width: 12),
                Text('Panduan Pengambilan Foto', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 30),
            _buildGuideItem(Icons.wb_sunny, 'Pencahayaan Terang', 'Ambil foto di siang hari atau di tempat terang agar tekstur daun terlihat jelas.'),
            const SizedBox(height: 16),
            _buildGuideItem(Icons.center_focus_strong, 'Fokus Pada Bercak', 'Pastikan area daun yang sakit (berbercak) berada di tengah frame foto.'),
            const SizedBox(height: 16),
            _buildGuideItem(Icons.do_not_disturb_alt, 'Hindari Latar Ramai', 'Usahakan tidak terlalu banyak tanah atau daun lain yang menumpuk di latar belakang.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Saya Mengerti'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.green[700], size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Deteksi Penyakit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          // Tombol Bantuan Panduan
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: _showGuidelines,
            tooltip: 'Panduan Foto',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            // --- FITUR BARU: KARTU CUACA ---
            if (!_isLoadingWeather && _weatherData != null) ...[
              Builder(
                builder: (context) {
                  final temp = _weatherData!['temperature'];
                  final code = _weatherData!['weathercode'];
                  final condition = WeatherService.getWeatherCondition(code);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: condition['warning'] ? Colors.orange[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: condition['warning'] ? Colors.orange[200]! : Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Text(condition['icon'], style: const TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cuaca Lokasi Anda ($temp°C)', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                condition['warning'] 
                                  ? '${condition['text']} - Waspada! Kelembaban tinggi memicu jamur Blast.'
                                  : '${condition['text']} - Kondisi ideal untuk pengecekan lahan.',
                                style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
              )
            ],

            // Kontainer Utama Pratinjau Gambar Asli
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_search_rounded, size: 56, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('Silakan unggah sampel foto daun padi', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      ],
                    ),
            ),
            const SizedBox(height: 24),

            // Tombol Kontrol Modern
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, size: 20),
                    label: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded, size: 20),
                    label: const Text('Galeri', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F5E9),
                      foregroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Indikator Loading
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF2E7D32), strokeWidth: 3),
                      const SizedBox(height: 16),
                      Text('AI sedang membedah struktur bercak...', style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic, fontSize: 14)),
                    ],
                  ),
                ),
              ),

            // Tampilan Output Analisis & Grad-CAM
            if (_predictionResult != null && !_isLoading) ...[
              // Kartu Hasil Diagnosis
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  children: [
                    const Text('HASIL DIAGNOSIS PAKAR AI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                    const SizedBox(height: 8),
                    Text(
                      _predictionResult!['data']['disease'].toString().toUpperCase().replaceAll('_', ' '),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF1B5E20)),
                    ),
                    const SizedBox(height: 4),
                    Text('Tingkat Keyakinan: ${_predictionResult!['data']['confidence']}%', style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Kartu Visualisasi Grad-CAM
              const Text('Karakteristik Fokus Bercak (Grad-CAM)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.memory(
                    base64Decode(_predictionResult!['data']['gradcam_image'].split(',').last),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Kartu Rekomendasi
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDE7),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFFFF59D).withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.gpp_good_rounded, color: Color(0xFFFBC02D), size: 24),
                        SizedBox(width: 8),
                        Text('Tindakan Penanganan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF574300))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _predictionResult!['data']['recommendation'],
                      style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF574300), fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}