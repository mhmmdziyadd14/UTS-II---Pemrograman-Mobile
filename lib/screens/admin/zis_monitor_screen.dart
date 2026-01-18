import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/zis_provider.dart';

class ZisMonitorScreen extends StatefulWidget {
  @override
  _ZisMonitorScreenState createState() => _ZisMonitorScreenState();
}

class _ZisMonitorScreenState extends State<ZisMonitorScreen> {
  @override
  void initState() {
    super.initState();
    // Ambil data terbaru saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ZisProvider>(context, listen: false).fetchZis();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ZisProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchZis(),
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BAGIAN 1: TOTAL STATISTIK ---
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Text("Total Dana ZIS", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      SizedBox(height: 5),
                      Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(provider.totalZis),
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      
                      // Grid 3 Kolom untuk Rincian
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniStat("Zakat", provider.totalZakat, Colors.orange.shade100, Colors.orange.shade900),
                          _buildMiniStat("Infaq", provider.totalInfaq, Colors.green.shade100, Colors.green.shade900),
                          _buildMiniStat("Shadaqah", provider.totalShadaqah, Colors.blue.shade100, Colors.blue.shade900),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // --- BAGIAN 2: DAFTAR RIWAYAT ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Riwayat Transaksi Masuk",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade900),
                      ),
                      Text(
                        "${provider.zisList.length} Data",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 10),

                provider.zisList.isEmpty
                  ? Container(
                      height: 300,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 60, color: Colors.grey.shade300),
                          SizedBox(height: 10),
                          Text("Belum ada data transaksi.", style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      shrinkWrap: true, // Agar bisa discroll dalam SingleChildScrollView
                      physics: NeverScrollableScrollPhysics(), // Scroll ikut parent
                      itemCount: provider.zisList.length,
                      itemBuilder: (context, index) {
                        final item = provider.zisList[index];
                        
                        // Tentukan warna ikon
                        Color color = Colors.grey;
                        IconData icon = Icons.money;
                        if (item.type.toLowerCase() == 'zakat') { color = Colors.orange; icon = Icons.volunteer_activism; }
                        else if (item.type.toLowerCase() == 'infaq') { color = Colors.green; icon = Icons.mosque; }
                        else if (item.type.toLowerCase() == 'shadaqah') { color = Colors.blue; icon = Icons.handshake; }

                        return Card(
                          margin: EdgeInsets.only(bottom: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Container(
                            height: 76,
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: color.withOpacity(0.1),
                                  child: Icon(icon, color: color),
                                ),
                                SizedBox(width: 12),
                                // Title + subtitle
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.type, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      SizedBox(height: 4),
                                      Text(item.date, style: TextStyle(color: Colors.grey[600])),
                                    ],
                                  ),
                                ),
                                // Trailing: amount and status left of the menu icon
                                Container(
                                  width: 140,
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      // Column with amount and badge (stacked)
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(item.amount),
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          SizedBox(height: 6),
                                          _buildStatusBadge(item.status),
                                        ],
                                      ),
                                      SizedBox(width: 10),
                                      // action menu at the far right
                                      PopupMenuButton<String>(
                                        padding: EdgeInsets.zero,
                                        icon: Icon(Icons.more_vert, size: 22),
                                        onSelected: (value) async {
                                          final provider = Provider.of<ZisProvider>(context, listen: false);
                                          final messenger = ScaffoldMessenger.of(context);
                                          messenger.showSnackBar(SnackBar(content: Text('Mengubah status...'), duration: Duration(days: 1)));
                                          bool ok = await provider.updateZisStatus(item.id.toString(), value);
                                          messenger.hideCurrentSnackBar();
                                          messenger.showSnackBar(SnackBar(content: Text(ok ? 'Status diubah menjadi ${value.toUpperCase()}' : 'Gagal mengubah status')));
                                        },
                                        itemBuilder: (ctx) => [
                                          PopupMenuItem(value: 'pending', child: Text('Pending')),
                                          PopupMenuItem(value: 'success', child: Text('Success')),
                                          PopupMenuItem(value: 'ditolak', child: Text('Ditolak')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget kecil untuk kotak rincian Zakat/Infaq/Shadaqah
  Widget _buildMiniStat(String label, int amount, Color bgColor, Color textColor) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.8), fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(
              NumberFormat.compact(locale: 'id_ID').format(amount), // Format singkat (misal 1jt, 500rb)
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  // helper: choose color for status text/border
  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // helper: choose background color for status badge
  Color _statusColorBg(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green.shade50;
      case 'pending':
        return Colors.orange.shade50;
      case 'ditolak':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  // helper: build a compact status badge widget
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _statusColorBg(status),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _statusColor(status), width: 0.6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, color: _statusColor(status), fontWeight: FontWeight.w700),
      ),
    );
  }
}