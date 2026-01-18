import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/zis_model.dart';
import '../../providers/zis_provider.dart';

class ZisFormScreen extends StatefulWidget {
  @override
  _ZisFormScreenState createState() => _ZisFormScreenState();
}

class _ZisFormScreenState extends State<ZisFormScreen> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Infaq';
  bool _isSubmitting = false; // Flag khusus untuk loading tombol submit

  @override
  void initState() {
    super.initState();
    // Memastikan data diambil setelah frame pertama dirender
    // Ini solusi agar riwayat langsung muncul saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ZisProvider>(context, listen: false).fetchZis();
    });
  }

  // --- DIALOG SUKSES ---
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.all(20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade50,
              ),
              child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 70),
            ),
            SizedBox(height: 20),
            Text(
              "Alhamdulillah!",
              style: TextStyle(
                fontSize: 22, 
                fontWeight: FontWeight.bold, 
                color: Colors.teal.shade800
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Pembayaran $_selectedType Anda berhasil dicatat.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ZisProvider>(
      builder: (context, provider, child) {
        // Hitung total dana (aman dari null)
        int totalAmount = provider.zisList.fold(0, (sum, item) => sum + item.amount);

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- KARTU TOTAL DANA (Opsional, bisa dihapus jika ingin riwayat saja) ---
              // Namun untuk user, melihat total kontribusi mereka sendiri bagus.
              // Jika ini total global dan sensitif, bisa disembunyikan.
              // Di sini saya biarkan agar user tau progress dana.
              /* Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(...) 
              ),
              SizedBox(height: 25),
              */
              
              // --- FORM INPUT ---
              Text("Salurkan ZIS", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
              SizedBox(height: 15),
              
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          items: ['Zakat', 'Infaq', 'Shadaqah'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedType = val);
                          },
                          decoration: InputDecoration(
                            labelText: "Jenis Pembayaran",
                            prefixIcon: Icon(Icons.category, color: Colors.teal),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Nominal (Rp)",
                            prefixIcon: Icon(Icons.attach_money, color: Colors.teal),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Nominal harus diisi";
                            if (int.tryParse(val) == null) return "Masukkan angka valid";
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        
                        // Tombol Submit
                        SizedBox(
                          width: double.infinity,
                          child: _isSubmitting 
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() => _isSubmitting = true); // Mulai loading submit

                                try {
                                  final newZis = ZisTransaction(
                                    type: _selectedType,
                                    amount: int.parse(_amountController.text),
                                    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                    status: 'pending',
                                  );

                                  // Kirim ke backend via Provider
                                  // Tambahkan timeout agar tidak stuck loading selamanya
                                  bool success = await provider.addZis(newZis).timeout(
                                    Duration(seconds: 10), 
                                    onTimeout: () => false
                                  );
                                  
                                  if (mounted) {
                                    setState(() => _isSubmitting = false); // Stop loading submit

                                    if (success) {
                                      _showSuccessDialog();
                                      _amountController.clear();
                                      // Refresh data agar tabel update
                                      provider.fetchZis(); 
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text("Gagal mengirim data. Cek koneksi server."),
                                        backgroundColor: Colors.red,
                                      ));
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    setState(() => _isSubmitting = false);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text("Error: $e"),
                                      backgroundColor: Colors.red,
                                    ));
                                  }
                                }
                              }
                            },
                            child: Text("BAYAR SEKARANG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // --- TABEL RIWAYAT TRANSAKSI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Riwayat Transaksi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
                  IconButton(
                    icon: Icon(Icons.refresh, color: Colors.teal),
                    onPressed: () => provider.fetchZis(), // Tombol refresh manual
                    tooltip: "Refresh Data",
                  )
                ],
              ),
              SizedBox(height: 10),
              
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  // Menggunakan properti isLoading dari provider
                  child: (provider.isLoading == true)
                  ? Container(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : provider.zisList.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.history, size: 40, color: Colors.grey[300]),
                              SizedBox(height: 10),
                              Text("Belum ada data transaksi", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.teal.shade50),
                          columns: [
                            DataColumn(label: Text("Tanggal", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Jenis", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Nominal", style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: provider.zisList.map((item) {
                            return DataRow(cells: [
                              DataCell(Text(item.date)),
                              DataCell(Text(item.type)),
                              DataCell(Text(NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(item.amount))),
                              DataCell(
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: item.status == 'verified' ? Colors.green.shade100 : Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Text(
                                    item.status.toUpperCase(),
                                    style: TextStyle(
                                      color: item.status == 'verified' ? Colors.green.shade800 : Colors.orange.shade800,
                                      fontSize: 10, 
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                )
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}