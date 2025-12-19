// Prayer schedule screen using a real API (Aladhan).
import 'package:flutter/material.dart';
import '../../services/prayer_service.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final PrayerService _service = PrayerService();
  Map<String, String>? _timings;
  bool _isLoading = false;
  String? _error;

  // Default coordinates (Jakarta). You can change to device location later.
  final double _lat = -6.200000;
  final double _lng = 106.816666;

  @override
  void initState() {
    super.initState();
    _loadTimings();
  }

  Future<void> _loadTimings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final res = await _service.fetchPrayerTimesFromApi(_lat, _lng);
    if (res == null) {
      setState(() {
        _error = 'Gagal mengambil jadwal sholat dari API';
        _isLoading = false;
      });
      return;
    }
    setState(() {
      _timings = res;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_timings == null) return const Center(child: Text('Tidak ada data'));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Jadwal Sholat Hari Ini', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._timings!.entries.map((e) => Card(
                child: ListTile(
                  title: Text(e.key),
                  trailing: Text(e.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              )),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _loadTimings,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          )
        ],
      ),
    );
  }
}