import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'zis_monitor_screen.dart';
import 'create_event_screen.dart';
import '../client/qibla_screen.dart'; // Menggunakan kembali layar Jadwal Sholat Client
import 'about_screen.dart'; // Import layar About yang baru dibuat

class HomeAdmin extends StatefulWidget {
  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi TabController dengan 4 tab
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Keluar",
            onPressed: () {
              // Dialog konfirmasi logout
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Keluar?"),
                  content: Text("Apakah Anda yakin ingin keluar dari akun admin?"),
                  actions: [
                    TextButton(
                      child: Text("Batal"), 
                      onPressed: () => Navigator.pop(context)
                    ),
                    TextButton(
                      child: Text("Ya, Keluar"),
                      onPressed: () {
                        Navigator.pop(context); // Tutup dialog
                        Provider.of<AuthProvider>(context, listen: false).logout();
                        Navigator.pushReplacement(
                          context, 
                          MaterialPageRoute(builder: (_) => LoginScreen())
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.teal,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.teal,
              indicatorWeight: 3,
              isScrollable: true, // Agar tab bisa digulir jika layar sempit
              tabs: [
                Tab(
                  icon: Icon(Icons.analytics_outlined),
                  text: "Monitor ZIS",
                ),
                Tab(
                  icon: Icon(Icons.edit_calendar_outlined),
                  text: "Buat Kegiatan",
                ),
                Tab(
                  icon: Icon(Icons.access_time_outlined),
                  text: "Jadwal Sholat",
                ),
                Tab(
                  icon: Icon(Icons.info_outline),
                  text: "About",
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ZisMonitorScreen(),   // Tab 1: Monitor Data ZIS
          CreateEventScreen(),  // Tab 2: Input Kegiatan Baru
          QiblaScreen(),        // Tab 3: Jadwal Sholat (Reuse dari Client)
          AboutScreen(),        // Tab 4: Halaman Tentang Aplikasi
        ],
      ),
    );
  }
}