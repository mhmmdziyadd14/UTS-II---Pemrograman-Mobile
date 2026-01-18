import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:adhan/adhan.dart'; // Masih dipakai untuk rumus Kiblat (Offline)

class PrayerService {
  
  // FUNGSI BARU: Ambil Jadwal Sholat dari API Aladhan
  Future<Map<String, dynamic>?> getPrayerTimesFromApi(double lat, double long) async {
    try {
      final date = DateTime.now();
      // Format tanggal URL: DD-MM-YYYY
      final dateStr = "${date.day}-${date.month}-${date.year}";
      
      // Method 20: Kementerian Agama Republik Indonesia (Kemenag)
      // Method 11: Majlis Ugama Islam Singapura
      final url = Uri.parse("http://api.aladhan.com/v1/timings/$dateStr?latitude=$lat&longitude=$long&method=20");
      
      print("Mengambil data sholat dari: $url"); // Debugging

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Mengembalikan Map berisi jam: {"Fajr": "04:30", "Dhuhr": "11:50", ...}
        return json['data']['timings'];
      }
    } catch (e) {
      print("Error API Sholat: $e");
    }
    return null;
  }

  // Tetap pakai library adhan untuk Hitung Kiblat (karena ini rumus matematika murni, cepat & offline)
  Qibla getQiblaDirection(double lat, double long) {
    return Qibla(Coordinates(lat, long));
  }
}