import 'package:adhan/adhan.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PrayerService {
  PrayerTimes getPrayerTimes(double lat, double long) {
    final myCoordinates = Coordinates(lat, long);
    final params = CalculationMethod.singapore.getParameters();
    params.madhab = Madhab.shafi;
    
    // Mengambil waktu sholat hari ini
    return PrayerTimes.today(myCoordinates, params);
  }

  /// Fetch prayer times from Aladhan API for given coordinates.
  /// Returns a map of timing names to strings (e.g. {'Fajr':'05:00', ...}) or null on failure.
  Future<Map<String, String>?> fetchPrayerTimesFromApi(double lat, double long) async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final uri = Uri.parse('http://api.aladhan.com/v1/timings/$ts?latitude=$lat&longitude=$long&method=2');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body) as Map<String, dynamic>;
        final data = body['data'] as Map<String, dynamic>?;
        if (data != null && data['timings'] is Map<String, dynamic>) {
          final timings = Map<String, dynamic>.from(data['timings'] as Map);
          // Keep only main prayer times
          final keys = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
          final Map<String, String> result = {};
          for (final k in keys) {
            if (timings.containsKey(k)) result[k] = timings[k].toString();
          }
          return result;
        }
      }
    } catch (e) {
      print('[PrayerService] fetchPrayerTimesFromApi failed: $e');
    }
    return null;
  }
}