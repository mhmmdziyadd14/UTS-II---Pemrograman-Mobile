import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/zis_provider.dart';
import '../common/event_detail_screen.dart';

class AdminEventListScreen extends StatefulWidget {
  @override
  _AdminEventListScreenState createState() => _AdminEventListScreenState();
}

class _AdminEventListScreenState extends State<AdminEventListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ZisProvider>(context, listen: false).fetchEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ZisProvider>(builder: (context, provider, child) {
      if (provider.isEventsLoading) return const Center(child: CircularProgressIndicator());
      if (provider.eventList.isEmpty) return const Center(child: Text('Belum ada kegiatan'));

      return ListView.separated(
        itemCount: provider.eventList.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final e = provider.eventList[i];
          return ListTile(
            leading: const Icon(Icons.event, color: Colors.indigo),
            title: Text(e.title),
            subtitle: Text('${e.date} • ${e.location}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(event: e)));
              },
            ),
          );
        },
      );
    });
  }
}
