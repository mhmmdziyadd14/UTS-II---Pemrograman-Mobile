import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/zis_model.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';

class ApiService {
  // GANTI 192.168.x.x dengan IP Laptop kamu yang didapat dari ipconfig
  final String baseUrl = "http://192.168.1.6:3000"; 
  String? _activeBase;

  // Contoh: Kirim Zakat (Client)
  Future<bool> submitZis(Map<String, dynamic> data) async {
    final parsed = Uri.parse(baseUrl);
    final hosts = <String>{parsed.host, '10.0.2.2', '127.0.0.1', 'localhost'};
    for (final host in hosts) {
      final tryBase = Uri(scheme: parsed.scheme, host: host, port: parsed.hasPort ? parsed.port : null).toString();
      try {
        final uri = Uri.parse('$tryBase/zis_transactions');
        print('[ApiService] Trying POST $uri');
        final resp = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data),
        );
        print('[ApiService] Response ${resp.statusCode} from $uri');
        if (resp.statusCode == 201 || resp.statusCode == 200) return true;
      } catch (e) {
        print('[ApiService] submitZis failed for $host: $e');
      }
    }
    return false;
  }

  // Wrapper to accept model
  Future<bool> createZis(ZisTransaction zis) async {
    return submitZis(zis.toJson());
  }

  // Create event
  Future<bool> createEvent(ReligiousEvent event) async {
    final parsed = Uri.parse(baseUrl);
    final hosts = <String>{parsed.host, '10.0.2.2', '127.0.0.1', 'localhost'};
    for (final host in hosts) {
      final tryBase = Uri(scheme: parsed.scheme, host: host, port: parsed.hasPort ? parsed.port : null).toString();
      try {
        final uri = Uri.parse('$tryBase/events');
        print('[ApiService] Trying POST $uri');
        final resp = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(event.toJson()),
        );
        print('[ApiService] Response ${resp.statusCode} from $uri');
        if (resp.statusCode == 201 || resp.statusCode == 200) return true;
      } catch (e) {
        print('[ApiService] createEvent failed for $host: $e');
      }
    }
    return false;
  }

  // Get events
  Future<List<dynamic>> getEvents() async {
    final parsed = Uri.parse(baseUrl);
    final hosts = <String>{parsed.host, '10.0.2.2', '127.0.0.1', 'localhost'};
    for (final host in hosts) {
      final tryBase = Uri(scheme: parsed.scheme, host: host, port: parsed.hasPort ? parsed.port : null).toString();
      try {
        final uri = Uri.parse('$tryBase/events');
        print('[ApiService] Trying GET $uri');
        final resp = await http.get(uri);
        print('[ApiService] Response ${resp.statusCode} from $uri');
        if (resp.statusCode == 200) return jsonDecode(resp.body);
      } catch (e) {
        print('[ApiService] getEvents failed for $host: $e');
      }
    }
    return [];
  }

  // Simple login implementation expecting {"username":"..","password":".."}
  Future<User?> login(String username, String password) async {
    final parsed = Uri.parse(baseUrl);
    final builtCandidates = <String>[];
    if (_activeBase != null) builtCandidates.add(_activeBase!);
    // prefer provided baseUrl, then local loopbacks likely to work depending on emulator/device
    builtCandidates.add(baseUrl);
    builtCandidates.add(Uri(scheme: parsed.scheme, host: '127.0.0.1', port: parsed.hasPort ? parsed.port : null).toString());
    builtCandidates.add(Uri(scheme: parsed.scheme, host: '10.0.2.2', port: parsed.hasPort ? parsed.port : null).toString());
    builtCandidates.add(Uri(scheme: parsed.scheme, host: 'localhost', port: parsed.hasPort ? parsed.port : null).toString());

    for (final base in builtCandidates) {
      if (base == null) continue;
      // First try json-server-style GET /users?username=..&password=..
      try {
        final uri = Uri.parse('$base/users?username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}');
        print('[ApiService] GET $uri');
        final qResp = await http.get(uri).timeout(Duration(seconds: 8));
        print('[ApiService] GET $uri -> ${qResp.statusCode} ${qResp.body}');
        if (qResp.statusCode == 200) {
          final list = _safeJsonDecode(qResp.body);
          if (list is List && list.isNotEmpty && list[0] is Map<String, dynamic>) {
            _activeBase = base; // cache working base
            print('[ApiService] active base set to $_activeBase via GET /users');
            return User.fromJson(list[0] as Map<String, dynamic>);
          }
        }
      } catch (e) {
        print('[ApiService] GET /users error for base $base: $e');
      }

      // Then try POST /login (some backends expect POST)
      try {
        final uri = Uri.parse('$base/login');
        print('[ApiService] POST $uri body=${jsonEncode({"username": username, "password": "***"})}');
        final response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"username": username, "password": password}),
        ).timeout(Duration(seconds: 8));
        print('[ApiService] POST $uri -> ${response.statusCode} ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final parsed = _safeJsonDecode(response.body);
          // Accept several shapes: direct user map, { "user": {...} }, { "token": "..", "user": {...} }, or {"data": {...}}
          if (parsed is Map<String, dynamic>) {
            if (parsed.containsKey('user') && parsed['user'] is Map<String, dynamic>) {
              _activeBase = base;
              print('[ApiService] active base set to $_activeBase via POST /login');
              return User.fromJson(parsed['user'] as Map<String, dynamic>);
            }
            if (parsed.containsKey('data') && parsed['data'] is Map<String, dynamic>) {
              _activeBase = base;
              print('[ApiService] active base set to $_activeBase via POST /login');
              return User.fromJson(parsed['data'] as Map<String, dynamic>);
            }
            // If the map itself looks like a user, try to parse
            try {
              _activeBase = base;
              print('[ApiService] active base set to $_activeBase via POST /login');
              return User.fromJson(parsed);
            } catch (_) {}
          }
          // If response is a list, take first element
          if (parsed is List && parsed.isNotEmpty && parsed[0] is Map<String, dynamic>) {
            _activeBase = base;
            print('[ApiService] active base set to $_activeBase via POST /login');
            return User.fromJson(parsed[0] as Map<String, dynamic>);
          }
        }
      } catch (e) {
        print('[ApiService] POST /login failed for base $base: $e');
      }
    }

    return null;
  }

  dynamic _safeJsonDecode(String src) {
    try {
      return jsonDecode(src);
    } catch (_) {
      return null;
    }
  }

  // Contoh: Ambil Data Zakat (Admin)
  Future<List<dynamic>> getZisTransactions() async {
    final parsed = Uri.parse(baseUrl);
    final hosts = <String>{parsed.host, '10.0.2.2', '127.0.0.1', 'localhost'};
    for (final host in hosts) {
      final tryBase = Uri(scheme: parsed.scheme, host: host, port: parsed.hasPort ? parsed.port : null).toString();
      try {
        final uri = Uri.parse('$tryBase/zis_transactions');
        print('[ApiService] Trying GET $uri');
        final resp = await http.get(uri);
        print('[ApiService] Response ${resp.statusCode} from $uri');
        if (resp.statusCode == 200) return jsonDecode(resp.body);
      } catch (e) {
        print('[ApiService] getZisTransactions failed for $host: $e');
      }
    }
    return [];
  }
}