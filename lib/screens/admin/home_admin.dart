import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'zis_monitor_screen.dart';
import 'create_event_screen.dart';
import 'admin_event_list_screen.dart';
import '../client/qibla_screen.dart';

class HomeAdmin extends StatefulWidget {
  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin TrueDeen"),
        backgroundColor: Colors.indigo,
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(icon: Icon(Icons.monetization_on), text: "Monitor ZIS"),
            Tab(icon: Icon(Icons.event), text: "Kegiatan"),
            Tab(icon: Icon(Icons.access_time), text: "Jadwal Sholat"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ZisMonitorScreen(),
          AdminEventListScreen(),
          // reuse prayer screen
          // imported lazily below
          PrayerScreen(),
        ],
      ),
    );
  }
}