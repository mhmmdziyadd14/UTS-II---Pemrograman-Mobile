import 'package:flutter/material.dart';
import '../../services/map_service.dart';

class MapSearchScreen extends StatefulWidget {
  @override
  _MapSearchScreenState createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final MapService _mapService = MapService();
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  bool _loading = false;

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;
    setState(() { _loading = true; _results = []; });
    final res = await _mapService.searchAddress(q);
    setState(() { _results = res; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cari Alamat'), backgroundColor: Colors.teal),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(hintText: 'Ketik alamat...', prefixIcon: Icon(Icons.search)),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: _search, child: Text('Cari'))
              ],
            ),
            SizedBox(height: 12),
            _loading ? Center(child: CircularProgressIndicator()) : Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (ctx, i) {
                  final r = _results[i];
                  return ListTile(
                    title: Text(r['display_name']),
                    onTap: () {
                      Navigator.pop(context, r);
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
