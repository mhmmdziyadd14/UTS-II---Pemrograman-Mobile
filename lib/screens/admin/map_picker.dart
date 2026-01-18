import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../services/map_service.dart';

class MapPickerResult {
  final String address;
  final double lat;
  final double lon;
  final String? placeName;
  MapPickerResult({required this.address, required this.lat, required this.lon, this.placeName});
}

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLon;
  MapPickerScreen({this.initialLat, this.initialLon});

  @override
  _MapPickerScreenState createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapService _mapService = MapService();
  late MapController _mapController;
  LatLng? _picked;
  String? _pickedAddress;
  final _placeNameCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLat != null && widget.initialLon != null) {
      _picked = LatLng(widget.initialLat!, widget.initialLon!);
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _placeNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _search(String q) async {
    final results = await _mapService.searchAddress(q);
    if (!mounted) return;
    setState(() => _searchResults = results);
    // auto-pan map to first result for quick preview (do not select)
    if (results.isNotEmpty) {
      final first = results.first;
      final lat = first['lat'] as double?;
      final lon = first['lon'] as double?;
      if (lat != null && lon != null) {
        try {
          _mapController.move(LatLng(lat, lon), 15);
        } catch (_) {}
      }
    }
  }

  Future<void> _pickAt(LatLng pos) async {
    _picked = pos;
    final addr = await _mapService.reverseGeocode(pos.latitude, pos.longitude);
    if (!mounted) return;
    setState(() {
      _pickedAddress = addr ?? '';
      if ((_placeNameCtrl.text).trim().isEmpty && _pickedAddress != null) {
        // prefill place name from the address (first segment)
        final parts = _pickedAddress!.split(',');
        _placeNameCtrl.text = parts.isNotEmpty ? parts.first.trim() : '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = _picked ?? LatLng(widget.initialLat ?? -6.1754, widget.initialLon ?? 106.8272);
    return Scaffold(
      appBar: AppBar(title: Text('Pilih Lokasi'), backgroundColor: Colors.teal),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(hintText: 'Cari alamat...', prefixIcon: Icon(Icons.search)),
                        onChanged: (v) {
                          if (v.length > 2) _search(v);
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                      onPressed: () async {
                        if (_picked != null && _pickedAddress != null) {
                          Navigator.pop(context, MapPickerResult(address: _pickedAddress!, lat: _picked!.latitude, lon: _picked!.longitude, placeName: _placeNameCtrl.text.trim().isEmpty ? null : _placeNameCtrl.text.trim()));
                        }
                      },
                      child: Text('Pilih'),
                    )
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _placeNameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama tempat (opsional)',
                    prefixIcon: Icon(Icons.label),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: center,
                    zoom: 13.0,
                    onTap: (tapPos, latlng) async {
                      await _pickAt(latlng);
                      try {
                        _mapController.move(latlng, 15);
                      } catch (_) {}
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: ['a','b','c'],
                    ),
                    if (_picked != null)
                      MarkerLayer(
                        markers: [
                          Marker(point: _picked!, width: 40, height: 40, builder: (ctx) => Icon(Icons.location_on, color: Colors.red, size: 40)),
                        ],
                      ),
                  ],
                ),

                if (_searchResults.isNotEmpty)
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.all(12),
                      padding: EdgeInsets.all(8),
                      width: MediaQuery.of(context).size.width - 24,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.95), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _searchResults.map((r) {
                          return ListTile(
                            title: Text(r['display_name'] ?? ''),
                            onTap: () {
                              final lat = r['lat'] as double?;
                              final lon = r['lon'] as double?;
                              if (lat != null && lon != null) {
                                final pos = LatLng(lat, lon);
                                // Use search result directly to set picked address (no extra async)
                                _picked = pos;
                                _pickedAddress = r['display_name'] ?? '';
                                // prefill place name using first comma-separated segment
                                final dn = r['display_name'] ?? '';
                                final parts = dn.split(',');
                                _placeNameCtrl.text = parts.isNotEmpty ? parts.first.trim() : dn;
                                try {
                                  _mapController.move(pos, 15);
                                } catch (_) {}
                                // update UI
                                if (mounted) setState(() {
                                  _searchResults = [];
                                  _searchCtrl.text = r['display_name'] ?? '';
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                if (_pickedAddress != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.all(12),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Text(_pickedAddress!, style: TextStyle(fontSize: 14)),
                    ),
                  ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
