import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _darkModeKey = "dark_mode";
  static const String _saveToHistoryKey = "save_to_history";
  static const String _showGradcamKey = "show_gradcam";

  bool _darkMode = false;
  bool _saveToHistory = true;
  bool _showGradcam = true;

  bool get darkMode => _darkMode;
  bool get saveToHistory => _saveToHistory;
  bool get showGradcam => _showGradcam;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(_darkModeKey) ?? false;
    _saveToHistory = prefs.getBool(_saveToHistoryKey) ?? true;
    _showGradcam = prefs.getBool(_showGradcamKey) ?? true;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    notifyListeners();
  }

  Future<void> toggleSaveToHistory(bool value) async {
    _saveToHistory = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_saveToHistoryKey, value);
    notifyListeners();
  }

  Future<void> toggleShowGradcam(bool value) async {
    _showGradcam = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showGradcamKey, value);
    notifyListeners();
  }
}