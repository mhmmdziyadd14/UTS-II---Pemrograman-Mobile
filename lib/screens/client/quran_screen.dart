import 'package:flutter/material.dart';
import '../../services/quran_service.dart';
import 'surah_detail_screen.dart';

class QuranScreen extends StatelessWidget {
  final QuranService _service = QuranService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _service.fetchSurahList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text('Gagal mengambil daftar surah'));
        final list = snapshot.data ?? [];
        if (list.isEmpty) return const Center(child: Text('Daftar surah kosong'));

        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final s = list[index];
            final name = s['name'] ?? s['englishName'] ?? s['name_simple'] ?? 'Surah ${index + 1}';
            final number = s['number'] ?? index + 1;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal[100],
                child: Text('${number}', style: const TextStyle(color: Colors.teal)),
              ),
              title: Text(name),
              subtitle: const Text('Ketuk untuk membaca'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => SurahDetailScreen(title: name, number: number)));
              },
            );
          },
        );
      },
    );
  }
}