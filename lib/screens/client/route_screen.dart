import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/pathfinder.dart';

class RouteScreen extends StatefulWidget {
  final LatLng start;
  final LatLng goal;
  const RouteScreen({required this.start, required this.goal, Key? key}) : super(key: key);

  @override
  State<RouteScreen> createState() => _RouteScreenState();
}

class _RouteScreenState extends State<RouteScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _route = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _computeRoute();
  }

  Future<void> _computeRoute() async {
    final pf = Pathfinder();
    try {
      final r = await pf.findRoute(widget.start, widget.goal, cellSizeMeters: 200);
      if (!mounted) return;
      setState(() {
        _route = r;
        _loading = false;
      });
      if (_route.isNotEmpty) {
        _mapController.move(_route.first, 13);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _route.isNotEmpty ? _route.first : widget.start;
    return Scaffold(
      appBar: AppBar(title: Text('Rute ke Kegiatan'), backgroundColor: Colors.teal),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(center: center, zoom: 13),
            children: [
              TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: ['a', 'b', 'c']),
              if (_route.isNotEmpty)
                PolylineLayer(
                  polylines: [Polyline(points: _route, color: Colors.blue, strokeWidth: 4.0)],
                ),
              if (_route.isNotEmpty)
                MarkerLayer(markers: [
                  Marker(point: widget.start, width: 40, height: 40, builder: (_) => Icon(Icons.person_pin_circle, color: Colors.green, size: 36)),
                  Marker(point: widget.goal, width: 40, height: 40, builder: (_) => Icon(Icons.location_on, color: Colors.red, size: 36)),
                ]),
            ],
          ),
          if (_loading)
            Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
