import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../models/zis_model.dart';
import '../models/event_model.dart';

class ApiService {
  // GANTI IP INI SESUAI IP LAPTOP (ipconfig)
  static const String baseUrl = "http://192.168.1.6:3000";

  // --- Auth ---
  Future<User?> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/users?username=$username&password=$password');
      print("Mencoba login ke: $url");
      
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return User.fromJson(data[0]);
        }
      }
    } catch (e) {
      print("Error Login: $e");
    }
    return null;
  }

  // --- ZIS ---
  Future<List<ZisTransaction>> getZisTransactions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/zis_transactions'));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => ZisTransaction.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error Get ZIS: $e");
    }
    return [];
  }

  Future<bool> createZis(ZisTransaction zis) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/zis_transactions'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(zis.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error Create ZIS: $e");
      return false;
    }
  }

  // UPDATE ZIS STATUS
  Future<bool> updateZisStatus(String id, String status) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/zis_transactions/$id'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({'status': status}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Update ZIS Status: $e");
      return false;
    }
  }

  // --- Events ---
  Future<List<ReligiousEvent>> getEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events'));
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => ReligiousEvent.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error Get Events: $e");
    }
    return [];
  }

  Future<bool> createEvent(ReligiousEvent event) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(event.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      print("Error Create Event: $e");
      return false;
    }
  }

  // UPDATE EVENT (BARU)
  Future<bool> updateEvent(ReligiousEvent event) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/events/${event.id}'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(event.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Error Update Event: $e");
      return false;
    }
  }

  // DELETE EVENT (BARU)
  Future<bool> deleteEvent(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/events/$id'));
      return response.statusCode == 200;
    } catch (e) {
      print("Error Delete Event: $e");
      return false;
    }
  }
}