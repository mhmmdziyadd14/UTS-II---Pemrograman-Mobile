import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/zis_provider.dart';
import '../../models/event_model.dart';
import '../common/event_detail_screen.dart';

class EventsMapScreen extends StatefulWidget {
  const EventsMapScreen({Key? key}) : super(key: key);

  @override
  State<EventsMapScreen> createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends State<EventsMapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ZisProvider>(context, listen: false).fetchEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ZisProvider>(context);
    final events = provider.eventList.where((e) => e.latitude != null && e.longitude != null).toList();
    final center = events.isNotEmpty ? LatLng(events.first.latitude!, events.first.longitude!) : LatLng(-6.1754, 106.8272);

    return Scaffold(
      appBar: AppBar(title: Text('Peta Kegiatan'), backgroundColor: Colors.teal),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(center: center, zoom: 13),
        children: [
          TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: ['a','b','c']),
          if (events.isNotEmpty)
            MarkerLayer(
              markers: events.map((ev) {
                final point = LatLng(ev.latitude!, ev.longitude!);
                return Marker(
                  point: point,
                  width: 48,
                  height: 48,
                  builder: (ctx) => GestureDetector(
                    onTap: () => _showEventBottom(ev),
                    child: Icon(Icons.location_on, color: Colors.red, size: 36),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showEventBottom(ReligiousEvent ev) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ev.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Text(ev.location, style: TextStyle(color: Colors.grey[700])),
            SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: ev)));
                  },
                  child: Text('Lihat Detail'),
                ),
                SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Tutup'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
