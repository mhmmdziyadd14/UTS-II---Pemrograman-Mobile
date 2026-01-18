import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart'; // Untuk kompas
import '../../services/prayer_service.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';

class QiblaScreen extends StatefulWidget {
  @override
  _QiblaScreenState createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  final PrayerService _prayerService = PrayerService();
  
  // Koordinat Jakarta Pusat (Contoh)
  final double lat = -6.1754;
  final double long = 106.8272;

  Map<String, dynamic>? _prayerData;
  bool _isLoading = true;
  String? _currentPrayerName;
  String? _nextPrayerName;
  Duration _timeUntilNextPrayer = Duration.zero;
  Timer? _timer;
  double? _deviceHeading; // degrees
  StreamSubscription<CompassEvent>? _compassSub;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Update timer setiap detik
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_prayerData != null) {
        _updateNextPrayerTimer();
      }
    });
    // Subscribe to device compass heading (if available)
    _compassSub = FlutterCompass.events?.listen((event) {
      final heading = event.heading;
      if (heading == null) return;
      if (mounted) setState(() => _deviceHeading = heading);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _compassSub?.cancel();
    super.dispose();
  }

  void _fetchData() async {
    final data = await _prayerService.getPrayerTimesFromApi(lat, long);
    if (mounted) {
      setState(() {
        _prayerData = data;
        _isLoading = false;
        if (data != null) {
          _determinePrayerStatus(data);
        }
      });
    }
  }

  void _determinePrayerStatus(Map<String, dynamic> timings) {
    final now = DateTime.now();
    final prayerKeys = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    
    String current = 'Isha';
    String next = 'Fajr';
    
    for (int i = 0; i < prayerKeys.length; i++) {
      String key = prayerKeys[i];
      DateTime time = _parseTime(timings[key]);

      if (now.isAfter(time) || now.isAtSameMomentAs(time)) {
        current = key;
        next = (i + 1 < prayerKeys.length) ? prayerKeys[i + 1] : 'Fajr';
      } else {
        if (i == 0) { // Sebelum Subuh
            current = 'Isha'; // Masih dianggap Isya hari sebelumnya (secara logika sederhana)
            next = 'Fajr';
        }
        break; 
      }
    }
    
    setState(() {
      _currentPrayerName = current;
      _nextPrayerName = next;
    });
    _updateNextPrayerTimer();
  }

  void _updateNextPrayerTimer() {
    if (_nextPrayerName == null || _prayerData == null) return;

    final now = DateTime.now();
    DateTime nextTime = _parseTime(_prayerData![_nextPrayerName]);

    // Jika next prayer adalah Fajr dan sekarang sudah lewat Isya (tengah malam)
    if (_nextPrayerName == 'Fajr' && now.hour > 20) {
       nextTime = nextTime.add(Duration(days: 1));
    }

    setState(() {
      _timeUntilNextPrayer = nextTime.difference(now);
    });
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    return DateTime(
      now.year, now.month, now.day,
      int.parse(timeStr.split(':')[0]),
      int.parse(timeStr.split(':')[1]),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "Waktu Tiba!";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Helper Translate Nama Sholat
  String _translatePrayer(String key) {
    switch(key) {
      case 'Fajr': return 'Subuh';
      case 'Dhuhr': return 'Dzuhur';
      case 'Asr': return 'Ashar';
      case 'Maghrib': return 'Maghrib';
      case 'Isha': return 'Isya';
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final qibla = _prayerService.getQiblaDirection(lat, long);

    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator()) 
        : RefreshIndicator(
            onRefresh: () async { _fetchData(); },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // --- HEADER INFO SHOLAT BERIKUTNYA ---
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade800, Colors.teal.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(color: Colors.teal.withOpacity(0.4), blurRadius: 10, offset: Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Menuju ${_translatePrayer(_nextPrayerName ?? '-')}",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _formatDuration(_timeUntilNextPrayer),
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 36, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // Kompas Mini (menggunakan heading perangkat bila tersedia)
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.15),
                            border: Border.all(color: Colors.amber, width: 2),
                          ),
                          child: Transform.rotate(
                            // rotate by (deviceHeading - qibla.direction) in radians
                            angle: ((_deviceHeading ?? 0) - qibla.direction) * (math.pi / 180),
                            child: Icon(Icons.explore, size: 40, color: Colors.white),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Kiblat: ${qibla.direction.toStringAsFixed(1)}°",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 20),
                  
                  // --- LIST JADWAL SHOLAT ---
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Jadwal Hari Ini",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                DateFormat('d MMM yyyy').format(DateTime.now()),
                                style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        
                        if (_prayerData == null)
                          Container(
                            padding: EdgeInsets.all(20),
                            alignment: Alignment.center,
                            child: Text("Gagal mengambil data. Tarik untuk refresh."),
                          )
                        else 
                          Column(
                            children: [
                              _buildPrayerCard("Subuh", _prayerData!['Fajr'], 'Fajr'),
                              _buildPrayerCard("Dzuhur", _prayerData!['Dhuhr'], 'Dhuhr'),
                              _buildPrayerCard("Ashar", _prayerData!['Asr'], 'Asr'),
                              _buildPrayerCard("Maghrib", _prayerData!['Maghrib'], 'Maghrib'),
                              _buildPrayerCard("Isya", _prayerData!['Isha'], 'Isha'),
                            ],
                          )
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildPrayerCard(String name, String timeStr, String key) {
    bool isCurrent = _currentPrayerName == key;
    bool isNext = _nextPrayerName == key;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrent ? Colors.teal : (isNext ? Colors.teal.shade50 : Colors.white),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
        border: isNext ? Border.all(color: Colors.teal, width: 2) : null,
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        leading: Icon(
          isCurrent ? Icons.play_circle_filled : (isNext ? Icons.access_time : Icons.circle_outlined),
          color: isCurrent ? Colors.amber : (isNext ? Colors.teal : Colors.grey),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: isCurrent ? Colors.white : Colors.black87,
            fontWeight: isCurrent || isNext ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isCurrent ? Colors.white.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isCurrent ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            timeStr,
            style: TextStyle(
              color: isCurrent ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}