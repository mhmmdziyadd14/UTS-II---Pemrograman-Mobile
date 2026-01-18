import 'package:flutter/material.dart';
import '../models/zis_model.dart';
import '../models/event_model.dart';
import '../services/api_service.dart';

class ZisProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<ZisTransaction> _zisList = [];
  List<ReligiousEvent> _eventList = [];
  bool _isLoading = false;

  List<ZisTransaction> get zisList => _zisList;
  List<ReligiousEvent> get eventList => _eventList;
  bool get isLoading => _isLoading;

  // --- Getter untuk Total ZIS ---
  int get totalZis => _zisList.fold(0, (sum, item) => sum + item.amount);
  int get totalZakat => _zisList.where((item) => item.type.toLowerCase() == 'zakat').fold(0, (sum, item) => sum + item.amount);
  int get totalInfaq => _zisList.where((item) => item.type.toLowerCase() == 'infaq').fold(0, (sum, item) => sum + item.amount);
  int get totalShadaqah => _zisList.where((item) => item.type.toLowerCase() == 'shadaqah').fold(0, (sum, item) => sum + item.amount);

  // --- ZIS Actions ---
  Future<void> fetchZis() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _apiService.getZisTransactions().timeout(
        Duration(seconds: 3),
        onTimeout: () => throw Exception("Timeout"),
      );
      _zisList = result.cast<ZisTransaction>(); 
    } catch (e) {
      print("Gagal fetch ZIS: $e");
      if (_zisList.isEmpty) _zisList = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addZis(ZisTransaction zis) async {
    _zisList.insert(0, zis); 
    notifyListeners();
    try {
      bool success = await _apiService.createZis(zis).timeout(
        Duration(seconds: 3),
        onTimeout: () => false,
      );
      return success;
    } catch (e) {
      return false;
    }
  }

  // UPDATE ZIS STATUS (ADMIN)
  Future<bool> updateZisStatus(String id, String status) async {
    try {
      bool success = await _apiService.updateZisStatus(id, status).timeout(
        Duration(seconds: 3),
        onTimeout: () => false,
      );
      if (success) {
        int index = _zisList.indexWhere((z) => z.id.toString() == id.toString());
        if (index != -1) {
          final old = _zisList[index];
          _zisList[index] = ZisTransaction(
            id: old.id,
            type: old.type,
            amount: old.amount,
            date: old.date,
            status: status,
          );
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      print("Error updateZisStatus provider: $e");
      return false;
    }
  }

  // --- Event Actions ---
  Future<void> fetchEvents() async {
    _isLoading = true;
    notifyListeners();
    try {
      final result = await _apiService.getEvents().timeout(Duration(seconds: 3));
      _eventList = result.cast<ReligiousEvent>();
    } catch (e) {
      print("Gagal fetch events: $e");
      if (_eventList.isEmpty) _eventList = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addEvent(ReligiousEvent event) async {
    _eventList.insert(0, event);
    notifyListeners();
    try {
      bool success = await _apiService.createEvent(event);
      if (success) await fetchEvents(); // Refresh untuk mendapatkan ID baru
      return success;
    } catch (e) {
      return false;
    }
  }

  // UPDATE EVENT
  Future<bool> updateEvent(ReligiousEvent event) async {
    try {
      bool success = await _apiService.updateEvent(event);
      if (success) {
        int index = _eventList.indexWhere((e) => e.id.toString() == event.id.toString());
        if (index != -1) {
          _eventList[index] = event;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // DELETE EVENT
  Future<bool> deleteEvent(String id) async {
    // Optimistic Delete
    ReligiousEvent? removedItem;
    int? removedIndex;
    
    removedIndex = _eventList.indexWhere((e) => e.id.toString() == id);
    if (removedIndex != -1) {
      removedItem = _eventList[removedIndex];
      _eventList.removeAt(removedIndex);
      notifyListeners();
    }

    try {
      bool success = await _apiService.deleteEvent(id);
      if (!success && removedItem != null) {
        // Rollback jika gagal
        _eventList.insert(removedIndex!, removedItem);
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      if (removedItem != null) {
        _eventList.insert(removedIndex!, removedItem);
        notifyListeners();
      }
      return false;
    }
  }
}