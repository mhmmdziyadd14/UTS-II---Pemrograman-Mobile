import 'package:flutter/material.dart';
import '../../services/quran_service.dart';
import 'surah_detail_screen.dart';

class QuranScreen extends StatefulWidget {
  @override
  _QuranScreenState createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final QuranService _quranService = QuranService();
  List<dynamic> _surahs = [];
  List<dynamic> _filteredSurahs = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSurahs();
  }

  void _fetchSurahs() async {
    final data = await _quranService.getAllSurahs();
    if (mounted) {
      setState(() {
        _surahs = data;
        _filteredSurahs = data; // Inisialisasi _filteredSurahs dengan semua data
        _isLoading = false;
      });
    }
  }

  void _filterSurahs(String query) {
    if (query.isEmpty) {
      // Jika pencarian kosong, kembalikan ke semua surah
      setState(() {
        _filteredSurahs = _surahs;
      });
    } else {
      final filtered = _surahs.where((surah) {
        final title = surah['englishName'].toString().toLowerCase();
        final titleIndo = surah['name'].toString().toLowerCase();
        final number = surah['number'].toString(); // Tambahkan pencarian berdasarkan nomor
        
        return title.contains(query.toLowerCase()) || 
               titleIndo.contains(query.toLowerCase()) ||
               number == query;
      }).toList();

      setState(() {
        _filteredSurahs = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header & Search
          Container(
            padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Al-Quran Digital",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 5),
                Text(
                  "Baca dan pelajari ayat suci",
                  style: TextStyle(color: Colors.teal.shade100),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _searchController,
                  onChanged: _filterSurahs,
                  decoration: InputDecoration(
                    hintText: "Cari Surah (nama atau nomor)...",
                    prefixIcon: Icon(Icons.search, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ],
            ),
          ),

          // List Surah
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _surahs.isEmpty 
                  ? Center(child: Text("Gagal memuat data dari API.\nPeriksa koneksi internet Anda.", textAlign: TextAlign.center))
                  : _filteredSurahs.isEmpty
                      ? Center(child: Text("Surah tidak ditemukan"))
                      : ListView.builder(
                          padding: EdgeInsets.all(10),
                          itemCount: _filteredSurahs.length,
                          itemBuilder: (context, index) {
                            final surah = _filteredSurahs[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 10),
                              elevation: 1,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade50,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.teal.shade200),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    "${surah['number']}",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                                  ),
                                ),
                                title: Text(
                                  surah['englishName'],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Text(
                                  "${surah['englishNameTranslation']} • ${surah['numberOfAyahs']} Ayat",
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                trailing: Text(
                                  surah['name'], // Nama Arab
                                  style: TextStyle(
                                    fontFamily: 'Amiri', // Font Arab (jika tersedia)
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade800,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SurahDetailScreen(
                                        surahNumber: surah['number'],
                                        surahName: surah['englishName'],
                                      ),
                                    ),
                                  );
                                },
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