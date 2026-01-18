import 'package:flutter/material.dart';
import '../../services/quran_service.dart';

class SurahDetailScreen extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const SurahDetailScreen({Key? key, required this.surahNumber, required this.surahName}) : super(key: key);

  @override
  _SurahDetailScreenState createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  final QuranService _quranService = QuranService();
  Map<String, dynamic>? _surahData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() async {
    final data = await _quranService.getSurahDetail(widget.surahNumber);
    if (mounted) {
      setState(() {
        _surahData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Surah ${widget.surahName}"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _surahData == null
              ? Center(child: Text("Gagal memuat data surah."))
              : Column(
                  children: [
                    // Bismillah Header (kecuali At-Taubah / Surah 9)
                    if (widget.surahNumber != 9)
                      Container(
                        padding: EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          border: Border(bottom: BorderSide(color: Colors.teal.shade100)),
                        ),
                        child: Center(
                          child: Text(
                            "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        ),
                      ),
                    
                    // List Ayat
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.all(16),
                        itemCount: (_surahData!['arabic']['ayahs'] as List).length,
                        separatorBuilder: (ctx, i) => Divider(height: 30, thickness: 1),
                        itemBuilder: (context, index) {
                          final arabAyah = _surahData!['arabic']['ayahs'][index];
                          final indoAyah = _surahData!['translation']['ayahs'][index];
                          final int ayahNumber = index + 1;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Nomor Ayat
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Ayat $ayahNumber",
                                      style: TextStyle(
                                        color: Colors.teal.shade900, 
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              
                              // Teks Arab
                              Text(
                                arabAyah['text'],
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  height: 2.0, // Spasi baris agar nyaman dibaca
                                  color: Colors.black87,
                                  fontFamily: 'Amiri',
                                ),
                              ),
                              SizedBox(height: 15),
                              
                              // Terjemahan
                              Text(
                                indoAyah['text'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[800],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}