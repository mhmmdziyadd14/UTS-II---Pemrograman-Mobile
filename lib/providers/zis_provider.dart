import 'package:flutter/material.dart';
import '../models/zis_model.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class ZisProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ZisTransaction> _zisList = [];
  List<ReligiousEvent> _eventList = [];
  bool _isZisLoading = false;
  bool _isEventsLoading = false;

  List<ZisTransaction> get zisList => _zisList;
  List<ReligiousEvent> get eventList => _eventList;
  bool get isZisLoading => _isZisLoading;
  bool get isEventsLoading => _isEventsLoading;

  // --- ZIS Actions ---
  Future<void> fetchZis() async {
    if (_zisList.isNotEmpty) return; // already loaded
    _isZisLoading = true;
    notifyListeners();
    final data = await _apiService.getZisTransactions();
    _zisList = data.map<ZisTransaction>((e) {
      if (e is ZisTransaction) return e;
      if (e is Map<String, dynamic>) return ZisTransaction.fromJson(e);
      return ZisTransaction.fromJson(Map<String, dynamic>.from(e));
    }).toList();
    _isZisLoading = false;
    notifyListeners();
  }

  Future<bool> addZis(ZisTransaction zis) async {
    bool success = await _apiService.createZis(zis);
    if (success) await fetchZis();
    return success;
  }

  // --- Event Actions ---
  Future<void> fetchEvents() async {
    if (_eventList.isNotEmpty) return; // already loaded
    _isEventsLoading = true;
    notifyListeners();
    final data = await _apiService.getEvents();
    _eventList = data.map<ReligiousEvent>((e) {
      if (e is ReligiousEvent) return e;
      if (e is Map<String, dynamic>) return ReligiousEvent.fromJson(e);
      return ReligiousEvent.fromJson(Map<String, dynamic>.from(e));
    }).toList();
    _isEventsLoading = false;
    notifyListeners();
  }

  Future<bool> addEvent(ReligiousEvent event) async {
    bool success = await _apiService.createEvent(event);
    if (success) await fetchEvents();
    return success;
  }
}