import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../models/event_model.dart';
import '../client/route_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final ReligiousEvent event;

  const EventDetailScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Detail Kegiatan"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- HEADER GAMBAR (Placeholder) ---
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.teal.shade100,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.mosque_outlined, size: 100, color: Colors.teal.withOpacity(0.5)),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Akan Datang",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- JUDUL ---
                  Text(
                    event.title,
                    style: TextStyle(
                      fontSize: 26, 
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade900,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // --- INFO UTAMA ---
                  _buildInfoRow(Icons.calendar_month, "Tanggal Pelaksanaan", event.date),
                  SizedBox(height: 16),
                  _buildInfoRow(Icons.location_on, "Lokasi", event.location),
                  
                  SizedBox(height: 32),
                  Divider(),
                  SizedBox(height: 16),

                  // --- DESKRIPSI ---
                  Text(
                    "Deskripsi Kegiatan",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 12),
                  // If admin provided a description, show it; otherwise show a default message
                  Text(
                    (event.description != null && event.description.trim().isNotEmpty)
                        ? event.description
                        : "Assalamu'alaikum Warahmatullahi Wabarakatuh.\n\n"
                          "Mari hadiri kegiatan ${event.title} yang insya Allah akan dilaksanakan pada tanggal ${event.date} bertempat di ${event.location}. \n\n"
                          "Siapkan infaq terbaik anda dan ajak keluarga serta sahabat untuk bersama-sama memakmurkan masjid dan menuntut ilmu.",
                    style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  
                  SizedBox(height: 20),

                  // --- TOMBOL CARI RUTE ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.directions, color: Colors.white),
                      label: Text("Cari Rute", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (event.latitude == null || event.longitude == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lokasi acara belum tersedia')));
                          return;
                        }

                        try {
                          LocationPermission permission = await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                          }
                          if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Izin lokasi dibutuhkan untuk mencari rute')));
                            return;
                          }

                          final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                          final start = LatLng(pos.latitude, pos.longitude);
                          final goal = LatLng(event.latitude!, event.longitude!);

                          Navigator.push(context, MaterialPageRoute(builder: (_) => RouteScreen(start: start, goal: goal)));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
                        }
                      },
                    ),
                  ),

                  SizedBox(height: 16),

                  // --- TOMBOL SHARE (Contoh Aksi) ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.share, color: Colors.white),
                      label: Text("Bagikan Informasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Fitur bagikan akan segera hadir!"))
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.teal, size: 24),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}