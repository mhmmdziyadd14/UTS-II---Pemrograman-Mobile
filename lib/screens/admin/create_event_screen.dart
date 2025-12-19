import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/zis_provider.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();
  final _locController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text("Tambah Kegiatan Baru", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: "Nama Kegiatan", border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? "Harus diisi" : null,
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(labelText: "Tanggal (YYYY-MM-DD)", border: OutlineInputBorder(), hintText: "2024-12-25"),
              validator: (val) => val!.isEmpty ? "Harus diisi" : null,
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _locController,
              decoration: InputDecoration(labelText: "Lokasi", border: OutlineInputBorder()),
              validator: (val) => val!.isEmpty ? "Harus diisi" : null,
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(labelText: "Deskripsi (opsional)", border: OutlineInputBorder()),
            ),
            SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final newEvent = ReligiousEvent(
                    title: _titleController.text,
                    date: _dateController.text,
                    location: _locController.text,
                    description: _descController.text,
                  );

                  bool success = await Provider.of<ZisProvider>(context, listen: false).addEvent(newEvent);
                  
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Kegiatan berhasil dibuat")));
                    _titleController.clear();
                    _dateController.clear();
                    _locController.clear();
                    _descController.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal membuat kegiatan")));
                  }
                }
              },
              child: Text("Simpan Kegiatan", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}