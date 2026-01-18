import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/zis_provider.dart';
import '../login_screen.dart';
import 'qibla_screen.dart';
import 'quran_screen.dart'; // Pastikan file ini ada
import 'zis_form_screen.dart';
// IMPORT HALAMAN DETAIL (PENTING)
import '../common/event_detail_screen.dart';

class HomeClient extends StatefulWidget {
  @override
  _HomeClientState createState() => _HomeClientState();
}

class _HomeClientState extends State<HomeClient> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    QiblaScreen(), 
    QuranScreen(),
    ZisFormScreen(),
    EventListScreen(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TrueDeen"),
        elevation: 0,
        backgroundColor: Colors.teal,
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: Colors.teal.shade100,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.access_time_outlined),
              selectedIcon: Icon(Icons.access_time_filled, color: Colors.teal.shade800),
              label: 'Sholat',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book, color: Colors.teal.shade800),
              label: 'Quran',
            ),
            NavigationDestination(
              icon: Icon(Icons.volunteer_activism_outlined),
              selectedIcon: Icon(Icons.volunteer_activism, color: Colors.teal.shade800),
              label: 'ZIS',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined),
              selectedIcon: Icon(Icons.event, color: Colors.teal.shade800),
              label: 'Info',
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET LIST KEGIATAN (Event) ---
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
    final provider = Provider.of<ZisProvider>(context);
    
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Kegiatan Masjid", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
          SizedBox(height: 10),
          Expanded(
            // Pengecekan isLoading yang aman
            child: (provider.isLoading == true) 
              ? Center(child: CircularProgressIndicator())
              : provider.eventList.isEmpty 
                ? Center(child: Text("Belum ada kegiatan"))
                : ListView.builder(
                    itemCount: provider.eventList.length,
                    itemBuilder: (ctx, i) {
                      final e = provider.eventList[i];
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        clipBehavior: Clip.antiAlias, // Agar efek klik rapi dalam card
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: InkWell( 
                          // --- FUNGSI KLIK MENUJU DETAIL ---
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventDetailScreen(event: e),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.event_note, color: Colors.amber.shade800),
                                ),
                                SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(e.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                          SizedBox(width: 5),
                                          Text(e.date, style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                                          SizedBox(width: 5),
                                          Text(e.location, style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400)
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}