import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class WeatherService {
  static Future<Map<String, dynamic>?> getCurrentWeather() async {
    try {
      // 1. Cek izin lokasi
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      
      if (permission == LocationPermission.deniedForever) return null;

      // 2. Dapatkan kordinat GPS pengguna
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium
      );

      // 3. Tembak API Open-Meteo (Gratis, Tanpa API Key)
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=${position.latitude}&longitude=${position.longitude}&current_weather=true'
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['current_weather'];
      }
      return null;
    } catch (e) {
      print("Error fetching weather: $e");
      return null;
    }
  }

  // Fungsi pembantu untuk mengubah kode cuaca menjadi teks & ikon
  static Map<String, dynamic> getWeatherCondition(int code) {
    if (code <= 3) return {'text': 'Cerah / Berawan', 'icon': '☀️', 'warning': false};
    if (code >= 51 && code <= 67) return {'text': 'Hujan Gerimis / Sedang', 'icon': '🌧️', 'warning': true};
    if (code >= 80) return {'text': 'Hujan Deras / Badai', 'icon': '⛈️', 'warning': true};
    return {'text': 'Mendung', 'icon': '☁️', 'warning': false};
  }
}