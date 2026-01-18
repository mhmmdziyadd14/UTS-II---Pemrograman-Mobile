import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  // Helper function to launch URLs
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
 
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          // Logo Aplikasi
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.teal.shade50,
            ),
            child: Icon(Icons.mosque, size: 80, color: Colors.teal),
          ),
          SizedBox(height: 20),
          
          // Nama & Versi
          Text(
            "TrueDeen Admin",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
          ),
          Text(
            "Versi 1.0.0",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 40),

          // Deskripsi
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "Tentang Aplikasi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "TrueDeen adalah aplikasi manajemen kegiatan masjid dan ZIS (Zakat, Infaq, Shadaqah) yang bertujuan untuk memudahkan pengurus masjid dalam mengelola data dan jamaah dalam beribadah.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // API Information
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    "Teknologi & API",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                ),
                Divider(height: 1),
                _buildApiTile(
                  "Adhan Library", 
                  "https://pub.dev/packages/adhan", // Link Adhan
                  "Perhitungan Waktu Sholat & Arah Kiblat",
                  Icons.access_time
                ),
                Divider(height: 1, indent: 20, endIndent: 20),
                _buildApiTile(
                  "Alquran Cloud API", 
                  "https://alquran.cloud/api", // Link Alquran Cloud
                  "Data Surah, Ayat, dan Terjemahan Al-Quran",
                  Icons.menu_book
                ),
                Divider(height: 1, indent: 20, endIndent: 20),
                _buildApiTile(
                  "JSON Server", 
                  "https://github.com/typicode/json-server", // Link JSON Server
                  "Database Lokal (Simulasi Backend)",
                  Icons.storage
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          // Info Pengembang
          ListTile(
            leading: Icon(Icons.code, color: Colors.teal),
            title: Text("Dikembangkan Oleh"),
            subtitle: Text("152023194 - Rifal Septia | 152023198 - M Ziyad | TrueDeen"),
          ),
          ListTile(
            leading: Icon(Icons.email, color: Colors.teal),
            title: Text("Kontak"),
            subtitle: Text("admin@truedeen.com"),
          ),
          ListTile(
            leading: Icon(Icons.language, color: Colors.teal),
            title: Text("Website"),
            subtitle: Text("www.truedeen.com"),
          ),

          SizedBox(height: 40),
          Text(
            "© 2024 TrueDeen. All Rights Reserved.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildApiTile(String title, String url, String subtitle, IconData icon) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Icon(icon, color: Colors.teal, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2),
          Text(
            url, 
            style: TextStyle(fontSize: 10, color: Colors.blue, decoration: TextDecoration.underline),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12)),
        ],
      ),
      onTap: () => _launchUrl(url), // Add tap interaction
      trailing: Icon(Icons.open_in_new, size: 16, color: Colors.grey),
    );
  }
}