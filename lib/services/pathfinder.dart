import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

/// Simple A* pathfinder over a generated grid between two coordinates.
/// This is a generic utility — for production routing use proper routing APIs.
class Pathfinder {
  /// Returns a polyline (list of LatLng) from [start] to [goal].
  /// Uses OSRM routing API (road-following). Falls back to straight line if unavailable.
  Future<List<LatLng>> findRoute(LatLng start, LatLng goal, {double cellSizeMeters = 100}) async {
    // Try OSRM routing first (uses road network)
    try {
      final url = Uri.parse('https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${goal.longitude},${goal.latitude}?overview=full&geometries=geojson');
      final resp = await http.get(url).timeout(Duration(seconds: 5));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        if (data != null && data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final coords = data['routes'][0]['geometry']['coordinates'] as List;
          final points = coords.map<LatLng>((e) => LatLng((e[1] as num).toDouble(), (e[0] as num).toDouble())).toList();
          if (points.isNotEmpty) return points;
        }
      }
    } catch (e) {
      // ignore and fallback to grid/simple route
    }

    // Fallback: very simple straight line (or you can keep the A* grid implementation)
    return [start, goal];
  }

}
