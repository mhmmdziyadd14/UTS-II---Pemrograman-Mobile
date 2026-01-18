import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import 'map_picker.dart';
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
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ZisProvider>(context, listen: false).fetchEvents();
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: ColorScheme.light(primary: Colors.teal)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => controller.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  void _clearForm() {
    _titleController.clear();
    _dateController.clear();
    _locController.clear();
    _descController.clear();
    _latitude = null;
    _longitude = null;
  }

  void _showEditDialog(ReligiousEvent event) {
    final titleCtrl = TextEditingController(text: event.title);
    final dateCtrl = TextEditingController(text: event.date);
    final locCtrl = TextEditingController(text: event.location);
    final descCtrl = TextEditingController(text: event.description);
    double? editLat = event.latitude;
    double? editLon = event.longitude;

    final _editFormKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              ),
              padding: EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)))),
                    SizedBox(height: 12),
                    Text('Edit Kegiatan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Form(
                      key: _editFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: titleCtrl,
                            decoration: InputDecoration(
                              labelText: "Nama Kegiatan",
                              prefixIcon: Icon(Icons.event_note, color: Colors.teal),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Harus diisi' : null,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: dateCtrl,
                            readOnly: true,
                            onTap: () => _selectDate(context, dateCtrl),
                            decoration: InputDecoration(
                              labelText: "Tanggal",
                              prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Harus diisi' : null,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: locCtrl,
                            decoration: InputDecoration(
                              labelText: "Lokasi",
                              prefixIcon: Icon(Icons.location_on, color: Colors.teal),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              filled: true,
                              fillColor: Colors.white,
                              suffixIcon: IconButton(
                                icon: Icon(Icons.map),
                                onPressed: () async {
                                  final res = await Navigator.push<MapPickerResult?>(
                                    context,
                                    MaterialPageRoute(builder: (_) => MapPickerScreen(initialLat: editLat, initialLon: editLon)),
                                  );
                                  if (res != null) {
                                      locCtrl.text = (res.placeName != null && res.placeName!.isNotEmpty) ? res.placeName! : res.address;
                                      editLat = res.lat;
                                      editLon = res.lon;
                                  }
                                },
                              ),
                            ),
                            validator: (val) => val == null || val.isEmpty ? 'Harus diisi' : null,
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            controller: descCtrl,
                            maxLines: 4,
                            decoration: InputDecoration(
                              labelText: "Deskripsi",
                              prefixIcon: Icon(Icons.description, color: Colors.teal),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text('Batal', style: TextStyle(color: Colors.teal)),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                  onPressed: () async {
                                    if (_editFormKey.currentState?.validate() ?? false) {
                                      Navigator.pop(ctx);
                                      final updatedEvent = ReligiousEvent(
                                        id: event.id,
                                        title: titleCtrl.text,
                                        date: dateCtrl.text,
                                        location: locCtrl.text,
                                        description: descCtrl.text,
                                        latitude: editLat,
                                        longitude: editLon,
                                      );
                                      bool ok = await Provider.of<ZisProvider>(context, listen: false).updateEvent(updatedEvent);
                                      if (ok) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Perubahan disimpan'), backgroundColor: Colors.green));
                                      else ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan perubahan')));
                                    }
                                  },
                                  child: Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(dynamic id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Hapus Kegiatan?"),
        content: Text("Data yang dihapus tidak dapat dikembalikan."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<ZisProvider>(context, listen: false).deleteEvent(id.toString());
            },
            child: Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ZisProvider>(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- FORM ---
          Text("Tambah Kegiatan Baru", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
          SizedBox(height: 15),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Nama Kegiatan",
                        prefixIcon: Icon(Icons.event_note, color: Colors.teal),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                      validator: (val) => val!.isEmpty ? "Harus diisi" : null,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context, _dateController),
                      decoration: InputDecoration(
                        labelText: "Tanggal",
                        prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                      validator: (val) => val!.isEmpty ? "Harus diisi" : null,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _locController,
                      decoration: InputDecoration(
                        labelText: "Lokasi",
                        prefixIcon: Icon(Icons.location_on, color: Colors.teal),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.map, color: Colors.teal),
                          onPressed: () async {
                            final res = await Navigator.push<MapPickerResult?>(
                              context,
                              MaterialPageRoute(builder: (_) => MapPickerScreen(initialLat: _latitude, initialLon: _longitude)),
                            );
                            if (res != null) {
                              setState(() {
                                _locController.text = (res.placeName != null && res.placeName!.isNotEmpty) ? res.placeName! : res.address;
                                _latitude = res.lat;
                                _longitude = res.lon;
                              });
                            }
                          },
                        ),
                      ),
                      validator: (val) => val!.isEmpty ? "Harus diisi" : null,
                    ),
                    SizedBox(height: 15),
                    TextFormField(
                      controller: _descController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Deskripsi",
                        prefixIcon: Icon(Icons.description, color: Colors.teal),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      ),
                    ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading 
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            final newEvent = ReligiousEvent(
                              title: _titleController.text,
                              date: _dateController.text,
                              location: _locController.text,
                              description: _descController.text,
                              latitude: _latitude,
                              longitude: _longitude,
                            );
                            bool success = await provider.addEvent(newEvent);
                            setState(() => _isLoading = false);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Berhasil Disimpan!"), backgroundColor: Colors.green));
                              _clearForm();
                            }
                          }
                        },
                        child: Text("SIMPAN KEGIATAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 40),

          // --- TABEL DATA ---
          Text("Daftar Kegiatan", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
          SizedBox(height: 10),
          
          provider.eventList.isEmpty 
          ? Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada data kegiatan.")))
          : Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 2,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.teal.shade50),
                  columns: [
                    DataColumn(label: Text("Nama", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Tanggal", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Lokasi", style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text("Aksi", style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: provider.eventList.map((event) {
                    return DataRow(cells: [
                      DataCell(Text(event.title)),
                      DataCell(Text(event.date)),
                      DataCell(Text(event.location)),
                      DataCell(
                        Row(
                          children: [
                            IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _showEditDialog(event)),
                            IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _showDeleteDialog(event.id)),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}