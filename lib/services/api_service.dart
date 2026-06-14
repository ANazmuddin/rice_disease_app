import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // TODO: Sesuaikan IP ini.
  // Gunakan '10.0.2.2' untuk Android Emulator.
  // Gunakan IP WiFi laptopmu (misal: '192.168.1.5') jika test di HP fisik.
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<Map<String, dynamic>> predictDisease(File imageFile) async {
    try {
      // 1. Siapkan request Multipart (untuk pengiriman file)
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/predict')
      );
      
      // 2. Masukkan file gambar ke dalam field 'file' (sesuai nama parameter di FastAPI)
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path)
      );

      // 3. Kirim request dan tunggu responnya
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // 4. Cek apakah respon server sukses (kode 200)
      if (response.statusCode == 200) {
        // Ubah string JSON menjadi Map/Dictionary (objek Dart)
        return jsonDecode(response.body);
      } else {
        throw Exception('Server mengembalikan error kode: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke server: $e');
    }
  }
}