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
  String _selectedType = 'Infaq';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Bayar Zakat, Infaq & Shadaqah", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          DropdownButtonFormField(
            value: _selectedType,
            items: ['Zakat', 'Infaq', 'Shadaqah'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (val) => setState(() => _selectedType = val.toString()),
            decoration: InputDecoration(labelText: "Jenis Pembayaran", border: OutlineInputBorder()),
          ),
          SizedBox(height: 15),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Nominal (Rp)", border: OutlineInputBorder()),
          ),
          SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(vertical: 15)
            ),
            onPressed: () async {
              if (_amountController.text.isNotEmpty) {
                final newZis = ZisTransaction(
                  type: _selectedType,
                  amount: int.parse(_amountController.text),
                  date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  status: 'pending',
                );

                bool success = await Provider.of<ZisProvider>(context, listen: false).addZis(newZis);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Pembayaran Berhasil!")));
                  _amountController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal mengirim data")));
                }
              }
            },
            child: Text("Bayar Sekarang", style: TextStyle(color: Colors.white, fontSize: 16)),
          )
        ],
      ),
    );
  }
}