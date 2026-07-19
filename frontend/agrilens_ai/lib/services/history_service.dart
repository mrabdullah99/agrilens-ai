import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prediction_result.dart';
import '../models/history_entry.dart';

class HistoryService with ChangeNotifier {
  static final HistoryService instance = HistoryService._internal();
  HistoryService._internal() {
    loadHistory();
  }

  static const String _historyKey = "prediction_history";
  List<HistoryEntry> _entries = [];

  List<HistoryEntry> get entries => _entries;

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      
      _entries = historyJson.map((item) {
        final result = PredictionResult.fromJson(jsonDecode(item));
        return HistoryEntry(result: result, timestamp: result.timestamp);
      }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  Future<void> savePrediction(PredictionResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      
      final resultJson = jsonEncode(result.toJson());
      historyJson.insert(0, resultJson); 
      
      await prefs.setStringList(_historyKey, historyJson);
      
      // Update local list
      _entries.insert(0, HistoryEntry(result: result, timestamp: result.timestamp));
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving prediction: $e");
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      _entries.clear();
      notifyListeners();
    } catch (e) {
      debugPrint("Error clearing history: $e");
    }
  }
}



