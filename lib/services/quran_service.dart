import 'dart:convert';
import 'package:http/http.dart' as http;

class QuranService {
  final String _base = 'https://equran.id/api/v2';

  Future<List<Map<String, dynamic>>> fetchSurahList() async {
    try {
      final uri = Uri.parse('$_base/surat');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        // equran returns a list at top-level or under 'data'
        final data = body is List ? body : (body['data'] ?? body['surat'] ?? []);
        if (data is List) {
          return data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    } catch (e) {
      print('[QuranService] fetchSurahList error: $e');
    }
    return [];
  }

  /// Fetch a single surah (ayat + translations) from equran.id
  Future<Map<String, dynamic>?> fetchSurah(int number) async {
    try {
      final uri = Uri.parse('$_base/surat/$number');
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);
        final data = body is Map ? (body['data'] ?? body) : null;
        if (data is Map<String, dynamic>) {
          final name = data['nama'] ?? data['name'] ?? data['englishName'] ?? '';
          final ayahs = <Map<String, dynamic>>[];
          // equran may use 'ayat' list
          final list = data['ayat'] ?? data['verses'] ?? data['list'] ?? data['ayahs'];
          if (list is List) {
            for (final a in list) {
              try {
                final m = Map<String, dynamic>.from(a);
                final arab = m['teks'] ?? m['ar'] ?? m['text'] ?? m['arabic'] ?? '';
                String translation = '';
                if (m.containsKey('terjemahan')) {
                  translation = m['terjemahan'] is String ? m['terjemahan'] : (m['terjemahan']['id'] ?? '');
                } else if (m.containsKey('translation')) {
                  translation = m['translation'] is String ? m['translation'] : (m['translation']['id'] ?? '');
                }
                ayahs.add({
                  'numberInSurah': m['nomor'] ?? m['numberInSurah'] ?? m['number'] ?? 0,
                  'arab': arab,
                  'translation': translation,
                });
              } catch (_) {}
            }
          }
          return {'name': name, 'number': number, 'ayahs': ayahs};
        }
      }
    } catch (e) {
      print('[QuranService] fetchSurah error: $e');
    }
    return null;
  }
}
