import 'package:flutter/material.dart';
import '../../models/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  final ReligiousEvent event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(event.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tanggal: ${event.date}'),
            const SizedBox(height: 4),
            Text('Lokasi: ${event.location}'),
            const SizedBox(height: 12),
            const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Expanded(child: SingleChildScrollView(child: Text(event.description ?? 'Tidak ada deskripsi'))),
          ],
        ),
      ),
    );
  }
}
