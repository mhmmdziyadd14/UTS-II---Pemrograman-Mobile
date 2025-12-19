import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/zis_provider.dart';

class ZisMonitorScreen extends StatefulWidget {
  @override
  _ZisMonitorScreenState createState() => _ZisMonitorScreenState();
}

class _ZisMonitorScreenState extends State<ZisMonitorScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<ZisProvider>(context, listen: false).fetchZis()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ZisProvider>(builder: (context, zisProvider, child) {
      if (zisProvider.isZisLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final totalAmount = zisProvider.zisList.fold<int>(0, (sum, item) => sum + item.amount);

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            color: Colors.indigo[50],
            child: Column(
              children: [
                const Text("Total Dana Terkumpul", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                Text(
                  "Rp $totalAmount",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: zisProvider.zisList.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = zisProvider.zisList[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.type == 'Zakat' ? Colors.green : Colors.blue,
                    child: const Icon(Icons.attach_money, color: Colors.white),
                  ),
                  title: Text("${item.type} - Rp ${item.amount}"),
                  subtitle: Text(item.date),
                  trailing: Chip(
                    label: Text(item.status),
                    backgroundColor: item.status == 'verified' ? Colors.green[100] : Colors.orange[100],
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}