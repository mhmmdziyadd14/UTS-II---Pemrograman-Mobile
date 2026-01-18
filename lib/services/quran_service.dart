import 'dart:convert';
import 'package:http/http.dart' as http;

class QuranService {
  // Base URL API Al-Quran Cloud
  static const String _baseUrl = "http://api.alquran.cloud/v1";

  // 1. Ambil Daftar Semua Surah
  Future<List<dynamic>> getAllSurahs() async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/surah"));
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['data']; // Mengembalikan list surah
      } else {
        throw Exception("Gagal memuat surah");
      }
    } catch (e) {
      print("Error Surah: $e");
      return [];
    }
  }

  // 2. Ambil Detail Ayat per Surah (Arab + Terjemahan Indonesia)
  Future<Map<String, dynamic>?> getSurahDetail(int number) async {
    try {
      // Mengambil edisi quran-uthmani (Arab) dan id.indonesian (Terjemahan)
      final response = await http.get(
        Uri.parse("$_baseUrl/surah/$number/editions/quran-uthmani,id.indonesian")
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'] as List;
        
        // Data[0] = Teks Arab
        // Data[1] = Terjemahan Indonesia
        return {
          'arabic': data[0],
          'translation': data[1],
        };
      }
    } catch (e) {
      print("Error Detail Surah: $e");
    }
    return null;
  }
}