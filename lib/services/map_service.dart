import 'dart:convert';
import 'package:http/http.dart' as http;

class MapService {
  // Nominatim OpenStreetMap search
  // Forward geocode: query -> list of results with display_name, lat, lon
  Future<List<Map<String, dynamic>>> searchAddress(String query, {int limit = 8}) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?format=json&addressdetails=1&q=${Uri.encodeComponent(query)}&limit=$limit');
    final resp = await http.get(url, headers: {'User-Agent': 'truedeen-app/1.0 (your-email@example.com)'});
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return data.map((e) => {
        'display_name': e['display_name'],
        'lat': double.tryParse(e['lat'].toString()),
        'lon': double.tryParse(e['lon'].toString()),
        'raw': e,
      }).toList();
    }
    return [];
  }

  // Reverse geocode lat/lon -> address
  Future<String?> reverseGeocode(double lat, double lon) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon');
    final resp = await http.get(url, headers: {'User-Agent': 'truedeen-app/1.0 (your-email@example.com)'});
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body);
      return data['display_name'];
    }
    return null;
  }
}
