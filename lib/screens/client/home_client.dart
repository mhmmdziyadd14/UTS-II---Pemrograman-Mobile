import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart';
import 'zis_form_screen.dart';
import '../../providers/zis_provider.dart';
import '../common/event_detail_screen.dart';

class HomeClient extends StatefulWidget {
  @override
  _HomeClientState createState() => _HomeClientState();
}

class _HomeClientState extends State<HomeClient> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
  PrayerScreen(), // Jadwal sholat via API
    QuranScreen(),
    ZisFormScreen(),
    EventListScreen(), // Widget lokal di bawah
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TrueDeen Client"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          )
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Sholat"),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Quran"),
          BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "ZIS"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "Info"),
        ],
      ),
    );
  }
}

// Widget Sederhana untuk List Event Client
class EventListScreen extends StatefulWidget {
  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
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
            leading: const Icon(Icons.event_note, color: Colors.teal),
            title: Text(e.title),
            subtitle: Text("${e.date} di ${e.location}"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) =>
                // lazy import to avoid circular issues
                EventDetailScreen(event: e)
              ));
            },
          );
        },
      );
    });
  }
}