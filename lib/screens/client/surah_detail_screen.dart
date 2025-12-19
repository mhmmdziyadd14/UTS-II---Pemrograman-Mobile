import 'package:flutter/material.dart';
import '../../services/quran_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final String title;
  final int number;

  const SurahDetailScreen({super.key, required this.title, required this.number});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranService _service = QuranService();
  bool _loading = false;
  String? _error;
  List<Map<String, dynamic>> _ayahs = [];

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  Future<void> _loadSurah() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final res = await _service.fetchSurah(widget.number);
    if (res == null) {
      setState(() {
        _error = 'Gagal memuat surah';
        _loading = false;
      });
      return;
    }
    setState(() {
      _ayahs = (res['ayahs'] as List).cast<Map<String, dynamic>>();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: Colors.teal),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.separated(
                    itemCount: _ayahs.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, idx) {
                      final a = _ayahs[idx];
                      final arab = a['arab'] ?? '';
                      final trans = a['translation'] ?? '';
                      return ListTile(
                        leading: CircleAvatar(child: Text('${idx + 1}')),
                        title: Text(arab, textAlign: TextAlign.right, style: const TextStyle(fontSize: 18)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(trans),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
